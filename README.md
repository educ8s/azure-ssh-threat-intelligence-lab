# Azure SSH Honeypot & Cloud SIEM Lab

A deliberately exposed SSH honeypot in **Microsoft Azure**, built with **Terraform**. Bots and attackers find the public IP, try to log in and run commands. **Cowrie** (in Docker) records everything inside a fake shell. Logs flow through the **Azure Monitor Agent** into **Log Analytics**, where **Microsoft Sentinel** is used for KQL threat hunting, detection rules and incidents.

One `terraform apply` builds the lab. One `terraform destroy` removes it.

![Status](https://img.shields.io/badge/status-in%20progress-yellow)
![Azure](https://img.shields.io/badge/cloud-Azure-0078D4)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC)
![Sentinel](https://img.shields.io/badge/SIEM-Microsoft%20Sentinel-0078D4)

---

## Progress

**Overall:** `▓░░░░░░░░░░░░░░░░░░░` **3%** (6 of 191 tasks) · last updated 18 Nov 2026

| Phase | Milestone | Progress | Status |
|---|---|---|---|
| 0. Safety guardrails | M0 Account security & cost control | `▓▓▓▓▓▓▓▓▓░` 86% | 🟡 In progress |
| 1. Infrastructure | M1 Azure networking | `░░░░░░░░░░` 0% | ⬜ Next |
| | M2 Ubuntu VM deployment | `░░░░░░░░░░` 0% | ⬜ |
| | M3 Linux & network administration | `░░░░░░░░░░` 0% | ⬜ |
| 2. Automation & honeypot | M4 Terraform | `░░░░░░░░░░` 0% | ⬜ |
| | M5 Docker fundamentals | `░░░░░░░░░░` 0% | ⬜ |
| | M6 Cowrie SSH honeypot | `░░░░░░░░░░` 0% | ⬜ |
| | M6.5 Decoy data (honeytokens) | `░░░░░░░░░░` 0% | ⬜ |
| 3. Monitoring & SIEM | M7 Azure Monitor & Log Analytics | `░░░░░░░░░░` 0% | ⬜ |
| | M8 KQL | `░░░░░░░░░░` 0% | ⬜ |
| | M9 Microsoft Sentinel | `░░░░░░░░░░` 0% | ⬜ |
| 4. SOC skills | M10 Threat detection & MITRE ATT&CK | `░░░░░░░░░░` 0% | ⬜ |
| | M11 SOC investigation report | `░░░░░░░░░░` 0% | ⬜ |
| 5. Portfolio | M12 Final documentation | `░░░░░░░░░░` 0% | ⬜ |

Full checklist: [`tasks.md`](tasks.md)

---

## Why I'm building it

A portfolio project for my move into cybersecurity (target role: **SOC Analyst**). It shows three skills that are hard to prove on a CV:

- **Cloud:** designing and running real infrastructure in Azure
- **Infrastructure as Code:** every resource defined and rebuilt from Terraform
- **Security operations:** real attack data in a SIEM, KQL hunting, detections and an incident report

---

## Architecture

```
Internet (bots / attackers)
        |
        |  TCP 22 (bait)                  Admin (me)
        v                                     |  TCP 2222, admin IPs only, SSH key
  [ Public IP ] --> [ NSG ] --> [ NIC ] <-----+
                                  |
                       Subnet 10.0.1.0/24  (VNet 10.0.0.0/16)
                                  |
                 [ Ubuntu 24.04 VM, Standard_B2ats_v2 ]
                   - Docker + Cowrie on port 22 (fake SSH)
                   - Real sshd on port 2222
                   - Azure Monitor Agent
                                  |
                 Data Collection Rule (Cowrie JSON + Syslog)
                                  v
                     [ Log Analytics Workspace ]
                                  v
                     [ Microsoft Sentinel ]  ->  KQL, analytics rules, incidents
```

---

## Security design

- **Identity:** MFA on the Azure account (also required by Azure for CLI and IaC tools); SSH keys only for admin access
- **Inbound:** port 22 open as bait; port 2222 limited to my admin IPs
- **Outbound:** default-deny NSG, so the VM can't be used to attack others (only Azure Monitor, Entra ID and HTTP/S for updates allowed)
- **Isolation:** Cowrie runs in Docker as non-root; attacker commands never touch the real system
- **Data:** no real secrets on the VM; decoy credentials are fake and traceable

---

## Cost

| | |
|---|---|
| Region | East US |
| VM size | `Standard_B2ats_v2` (B1s/B2s were blocked on the new subscription) |
| Infrastructure | **~$12.25/month** (24/7) |
| Planned run | 1 month of data collection, then `terraform destroy` |
| Expected total | **~$12–22** |
| Guardrails | Monthly budget with 50/80/100% and forecast alerts |

Details: [`docs/01-cost-estimate.md`](docs/01-cost-estimate.md)

---

## Tech stack

Microsoft Azure · Terraform (azurerm) · Ubuntu 24.04 · Docker · Cowrie · Azure Monitor Agent · Data Collection Rules · Log Analytics · Microsoft Sentinel · KQL · Azure CLI

## Documentation

- [`project_description.md`](project_description.md): full design
- [`tasks.md`](tasks.md): learning roadmap
- [`docs/00-account-setup.md`](docs/00-account-setup.md): Milestone 0 notes
- [`docs/01-cost-estimate.md`](docs/01-cost-estimate.md): cost estimate

## Repository safety

No secrets, keys, `.tfvars` or Terraform state are committed. The honeypot only observes; it never attacks back.
