# Azure SSH Honeypot & Cloud SIEM Lab

> Repository name: `azure-ssh-threat-intelligence-lab`
> Status: **design complete, build in progress** (as of 17 November 2026)

## Overview

A deliberately exposed SSH honeypot running in Microsoft Azure, built entirely with **Terraform**. Bots and attackers find the server's public IP, try to log in, and run commands. **Cowrie**, an open-source SSH honeypot running in **Docker**, records everything they do inside a fake shell. The logs flow through the **Azure Monitor Agent** into a **Log Analytics Workspace**, where **Microsoft Sentinel** is used to hunt with **KQL**, build detection rules, and raise incidents.

One `terraform apply` builds the whole lab. One `terraform destroy` removes it in about a minute.

## Why I'm building it

This is a portfolio project for my move into cybersecurity (target role: **SOC Analyst**). It gives hands-on proof of three skills that are hard to show on a CV:

- **Cloud:** designing and running real infrastructure in Azure
- **Infrastructure as Code:** every resource defined, versioned, and rebuilt from Terraform
- **Security operations:** collecting real attack data in a SIEM, writing KQL, and turning findings into detections

It also puts the **AZ-900** fundamentals into practice: resource groups, VNets, NSGs, IaaS vs managed services, shared responsibility, cost management, tagging, and Azure Monitor.

## Architecture

```
Internet (bots / attackers)
        |
        |  TCP 22 (bait)                    Admin (me, Greece)
        v                                       |  TCP 2222, admin IPs only, SSH key
  [ Public IP ] --> [ NSG ] --> [ NIC ] <-------+
                                  |
                       Subnet 10.0.1.0/24  (VNet 10.0.0.0/16)
                                  |
                     [ Ubuntu 24.04 VM, Standard_B1s / B2s ]
                       - Docker + Cowrie on port 22 (fake SSH)
                       - Real sshd moved to port 2222
                       - Azure Monitor Agent (VM extension)
                                  |
                 Data Collection Rule (Cowrie JSON + Syslog)
                                  |
                                  v
                     [ Log Analytics Workspace ]
                                  |
                                  v
                     [ Microsoft Sentinel ]  ->  KQL hunting, analytics rules, incidents
```

## Azure resources (provisioned by Terraform)

All resources live in a single resource group, **`rg-honeypot-lab`**, so the lab has one lifecycle and clean cost tracking.

| # | Layer | Resource | Purpose |
|---|---|---|---|
| 1 | Networking | Virtual Network | Isolated private address space (`10.0.0.0/16`) |
| 2 | Networking | Subnet | Segment where the VM sits (`10.0.1.0/24`) |
| 3 | Networking | Network Security Group | Inbound 22 from anywhere (bait); inbound 2222 from my Greek admin IPs only; restricted outbound |
| 4 | Networking | Public IP (Standard, static) | The internet-facing address bots scan |
| 5 | Networking | Network Interface | Connects the VM to the subnet, public IP, and NSG |
| 6 | Compute | Linux VM (Ubuntu 24.04) | Runs Docker + Cowrie; `Standard_B1s`, scale up to `B2s` if needed |
| 7 | Compute | Managed OS Disk | The VM's virtual hard drive |
| 8 | Monitoring & SIEM | Log Analytics Workspace | Stores Cowrie JSON and Syslog events |
| 9 | Monitoring & SIEM | Microsoft Sentinel | SIEM layer on top of the workspace |
| 10 | Monitoring & SIEM | Data Collection Rule | Tells the Azure Monitor Agent which logs to collect and where to send them |

Plus the **Azure Monitor Agent VM extension**, installed inside the VM resource.

## Security design

| Layer | Control |
|---|---|
| Identity | MFA on my Azure account; SSH key only (no passwords) for real admin access |
| Network (inbound) | NSG: only port 22 open to the internet; port 2222 restricted to my admin IP list (Greece) |
| Network (outbound) | NSG: default-deny outbound; only the traffic the VM needs is allowed (see below) |
| Compute | Ubuntu kept patched; Cowrie runs in Docker as a non-root user, isolated from the host |
| Application | Cowrie presents a fake shell; attacker commands never run on the real system |
| Data | No real secrets or data on the VM; logs shipped off-box to Log Analytics |
| Perimeter | Azure's built-in DDoS protection on the public IP |

### NSG rules

**Inbound**

| Priority | Port | Source | Action | Purpose |
|---|---|---|---|---|
| 100 | TCP 22 | Any | Allow | Bait: Cowrie's fake SSH |
| 110 | TCP 2222 | `var.admin_source_ips` (my IP / Greek ISP prefixes) | Allow | My real admin SSH, key only |
| 4096 | Any | Any | Deny | Explicit catch-all (Azure denies by default too) |

**About "Greece only" on port 2222:** Azure NSGs can't filter by country. They only accept IP addresses, IP ranges, and Azure service tags. So "Greece only" is done with a Terraform variable, `admin_source_ips`, that holds:

- my current public IP as a `/32` (the strictest and recommended option), and/or
- the IP prefixes of my Greek ISP, so the rule keeps working when my home IP changes.

If my IP changes, I update the variable and run `terraform apply`. Country-level geo-filtering exists in Azure Firewall Premium and Azure Front Door, but both cost far more than this lab and Front Door doesn't handle SSH, so they're out of scope.

**Outbound** (prevents the VM being used to attack other systems)

| Priority | Port | Destination | Action | Purpose |
|---|---|---|---|---|
| 100 | TCP 443 | Service tag `AzureMonitor` | Allow | Azure Monitor Agent sends logs to Log Analytics |
| 110 | TCP 443 | Service tag `AzureActiveDirectory` | Allow | Agent authentication (managed identity) |
| 120 | TCP 80, 443 | Internet | Allow | Ubuntu updates and Docker image pulls |
| 130 | TCP 22, 23, 25, 445, 3389 | Any | Deny | Blocks outbound SSH/Telnet brute force, spam, SMB and RDP attacks |
| 4096 | Any | Any | Deny | Overrides Azure's default "allow all outbound" |

Notes:

- DNS to Azure's resolver (168.63.129.16) keeps working; NSGs don't block it.
- With 80/443 open, Cowrie can fetch files that attackers try to `wget` or `curl`, which captures malware samples for analysis. To stop even that, tighten rule 120 after setup (or open it only when patching).
- Every outbound deny rule hit shows up as attempted outbound attacks, which is itself useful detection data.

Shared responsibility: the VM is **IaaS** (I patch and configure it); Log Analytics and Sentinel are **managed services** (Microsoft runs the platform, I own the queries and data).

## Governance and cost

- **Tags on every resource:** `Project = honeypot-lab`, `Environment = Lab`, `Owner = Nick`, `CostCenter = Portfolio`, `AutoDelete = Yes`
- **Budget with alerts** on the subscription
- **Cost analysis** filtered by the `Project` tag
- **Burstable B-series VM**: mostly idle, bursts during attacks
- **`terraform destroy` whenever I'm not collecting data**
- No resource locks, on purpose, so the lab can be destroyed cleanly

## Detection and analysis plan

Planned KQL queries and Sentinel analytics rules:

- Top attacker IPs and countries by login attempts
- Most common usernames and passwords tried
- Successful fake logins followed by download commands (`wget`, `curl`)
- Activity over time (bursts vs quiet periods)
- Attacker geolocation map

Findings will be mapped to **MITRE ATT&CK**, for example:

- **T1110** Brute Force
- **T1083** File and Directory Discovery
- **T1552** Unsecured Credentials (with decoy data)

## Planned enhancements

- **Decoy data (honeytokens):** a believable fake filesystem in Cowrie (`.bash_history`, `.env` / config files with fake passwords, fake SSH keys) plus **Canarytokens** fake AWS keys that alert if an attacker tries to use them later
- **Sentinel analytics rules** that raise incidents automatically
- **One full incident investigation** written up SOC-style
- **Optional automation:** enrich attacker IPs with threat intelligence or send notifications
- **Optional log archive:** copy Cowrie logs to low-cost Blob storage (LRS, cool tier) before each destroy, to keep data across rebuilds
- **Findings write-up** after running the lab for 2 to 4 weeks

## Tech stack

Microsoft Azure · Terraform (azurerm provider) · Ubuntu 24.04 · Docker · Cowrie · Azure Monitor Agent · Data Collection Rules · Log Analytics · Microsoft Sentinel · KQL · Azure CLI

## Repository safety

- No secrets, keys, or sensitive `terraform.tfstate` content committed to Git
- Decoy credentials are fake and traceable; no real credentials are ever used
- The honeypot only observes; it never attacks back