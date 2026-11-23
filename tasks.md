# Azure SSH Honeypot & Cloud SIEM Lab
## Cybersecurity Learning Roadmap

**Goal:** Build a functional Azure SSH honeypot, integrate it with Microsoft Sentinel, and develop practical SOC Analyst skills.

**Approach:** Learn → Build → Break → Troubleshoot → Document.

---

# Phase 0 — Safety Guardrails

## Milestone 0: Account Security and Cost Control

- [x] Enable MFA on the Azure account.
- [x] Create a budget with alerts at 50%, 80% and 100%.
- [x] Define the tag plan: `Project`, `Owner`, `Environment`, `CostCenter`, `AutoDelete`.
- [x] Choose the Azure region and confirm `Standard_B1s` / `Standard_B2s` availability there.
- [x] Use the Azure Pricing Calculator to estimate VM, disk, public IP and log ingestion costs.
- [x] Find your current public IP and decide on `admin_source_ips` (your IP as `/32`, and/or your Greek ISP prefixes).

**Completion criteria:** The account is protected with MFA, spending is capped by alerts and you know roughly what the lab costs per month.

---

# Phase 1 — Infrastructure Fundamentals

## Milestone 1: Azure Networking

- [x] Create an Azure account and understand the subscription structure.
- [x] Create a Resource Group (`rg-honeypot-lab`).
- [x] Create a Virtual Network (`10.0.0.0/16`).
- [x] Create a subnet (`10.0.1.0/24`).
- [x] Create a Network Security Group (NSG).
- [x] Configure inbound security rules (2222 from `admin_source_ips` only; the 22-from-Any bait rule is added in Milestone 6 when Cowrie is running).
- [x] Configure outbound security rules (allow `AzureMonitor`, `AzureActiveDirectory`, 80/443; deny 22, 23, 25, 445, 3389; deny all else).
- [x] Test network connectivity and firewall behavior.

**Completion criteria:** Understand how network traffic reaches an Azure VM and how an NSG filters that traffic.

## Milestone 2: Ubuntu VM Deployment

- [x] Deploy Ubuntu Server 24.04 LTS.
- [x] Select an appropriate VM size (e.g. Standard_B1s, subject to regional availability).
- [x] Create an SSH key pair.
- [x] Configure SSH key authentication.
- [x] Assign a public IP address.
- [x] Connect to the VM from your local computer.
- [x] Move the real `sshd` to port 2222 (on Ubuntu 24.04, SSH uses `ssh.socket`: change the port there or disable socket activation, not only `sshd_config`).
- [x] Confirm you can log in on port 2222 **before** closing your session on port 22.
- [x] Disable password authentication and root login in `sshd_config`.
- [x] Update Ubuntu packages.
- [x] Install basic administration tools.

**Completion criteria:** Successfully administer your Azure VM remotely using SSH keys.

## Milestone 3: Linux and Network Administration

- [x] Inspect authentication logs.
- [x] Configure and test firewall rules.
- [ ] Troubleshoot deliberately broken network configurations.

**Completion criteria:** Diagnose common Linux administration and network connectivity problems independently.

---

# Phase 2 — Infrastructure Automation and Honeypot

## Milestone 4: Terraform

- [x] Install Terraform.
- [x] Create `.gitignore` for state, `.tfvars` and `.terraform/` **before** the first `terraform apply`.
- [x] Recreate the Resource Group using Terraform.
- [x] Recreate the VNet and subnet.
- [x] Recreate the NSG and security rules.
- [x] Recreate the public IP, NIC and VM.
- [x] Organize configuration into separate `.tf` files.
- [x] Use variables and `.tfvars` files (including `admin_source_ips`).
- [x] Apply the tag plan to every resource with a shared `tags` block.

**Completion criteria:** Deploy and destroy the Azure infrastructure using Terraform.

## Milestone 5: Docker Fundamentals

- [ ] Install Docker.
- [ ] Run your first container.
- [ ] Create a custom Dockerfile.
- [ ] Use Docker Compose.
- [ ] Inspect container logs.
- [ ] Run containers as non-root users.
- [ ] Harden the Cowrie container (non-root, read-only where possible, resource limits).

**Completion criteria:** Build, run, inspect and secure your own Docker container.

## Milestone 6: Cowrie SSH Honeypot

- [ ] Deploy Cowrie using Docker.
- [ ] Configure the fake SSH environment.
- [ ] Connect to the honeypot using an SSH client.
- [ ] Generate test login attempts.
- [ ] Execute commands in the fake shell.
- [ ] Inspect Cowrie JSON logs.
- [ ] Customize the fake filesystem.

**Completion criteria:** Operate a Cowrie honeypot and understand the events it records.

## Milestone 6.5: Decoy Data (Honeytokens)

- [ ] Customize Cowrie's fake filesystem so it looks like a real, used server.
- [ ] Plant a believable `.bash_history`.
- [ ] Plant fake config files with fake credentials (e.g. `/var/www/.env`, `config.php`).
- [ ] Plant fake SSH private keys in `/root/.ssh/`.
- [ ] Create fake AWS keys with Canarytokens.org and plant them.
- [ ] Use unique values per decoy so each one can be traced.
- [ ] Never use real credentials of any kind.
- [ ] Verify decoy file access appears in the Cowrie logs.

**Completion criteria:** Attackers who explore the fake system find believable decoys, and any decoy that is read or used can be detected.

---

# Phase 3 — Monitoring and SIEM

## Milestone 7: Azure Monitor and Log Analytics

- [ ] Check current Log Analytics and Sentinel pricing and any free trial.
- [ ] Create a Log Analytics Workspace.
- [ ] Set log retention to match your budget.
- [ ] Install AMA on the VM.
- [ ] Configure a DCR.
- [ ] Collect Linux system logs.
- [ ] Configure Cowrie log ingestion.
- [ ] Verify that logs arrive in Log Analytics.

**Completion criteria:** Retrieve real Linux and honeypot events from Log Analytics.

## Milestone 8: Kusto Query Language (KQL)

- [ ] Query failed SSH authentication attempts.
- [ ] Identify the most active source IP addresses.
- [ ] Identify frequently attempted usernames.
- [ ] Analyze attacker activity over time.
- [ ] Build an attack timeline.
- [ ] Save useful queries in the GitHub repository.

**Completion criteria:** Write KQL queries that answer meaningful security questions using real honeypot data.

## Milestone 9: Microsoft Sentinel

- [ ] Connect Sentinel to your Log Analytics Workspace.
- [ ] Create a brute-force detection rule.
- [ ] Create a suspicious login detection rule.
- [ ] Create a suspicious command execution detection rule.
- [ ] Create a decoy access detection rule (attacker reads a honeytoken file).
- [ ] Send Canarytokens alerts to your email (optionally into Sentinel).
- [ ] Configure incident generation.
- [ ] Investigate generated incidents.
- [ ] Create a Sentinel workbook.
- [ ] Visualize attacker IPs and activity.

**Completion criteria:** Detect suspicious honeypot activity and generate incidents in Microsoft Sentinel.

---

# Phase 4 — SOC Analyst Skills

## Milestone 10: Threat Detection and MITRE ATT&CK

- [ ] Identify suspicious usernames and passwords.
- [ ] Detect fake successful SSH logins.
- [ ] Identify suspicious commands.
- [ ] Investigate `wget` and `curl` activity.
- [ ] Map observed behavior to relevant ATT&CK techniques.
- [ ] Create at least three meaningful detection rules.
- [ ] Test detections using controlled honeypot activity.
- [ ] Document detection logic and expected results.

**Completion criteria:** Build and explain at least three working security detections based on observed behavior.

## Milestone 11: SOC Investigation

- [ ] Select an interesting honeypot session.
- [ ] Identify the source IP address.
- [ ] Enrich the IP with available threat intelligence.
- [ ] Analyze authentication attempts.
- [ ] Reconstruct the attack timeline.
- [ ] Examine executed commands.
- [ ] Investigate attempted downloads.
- [ ] Identify possible attacker objectives.
- [ ] Assess severity and potential impact.
- [ ] Map observed activity to MITRE ATT&CK.
- [ ] Document evidence and findings.
- [ ] Recommend defensive actions.
- [ ] Write a complete incident investigation report.

**Completion criteria:** Produce a professional incident investigation report based on actual honeypot activity.

---

# Phase 5 — Portfolio Project

## Milestone 12: Complete the GitHub Portfolio

- [ ] Organize the GitHub repository (`terraform/`, `docker/`, `cowrie/`, `kql/`, `sentinel/`, `docs/`).
- [ ] Keep milestone notes in `docs/`.
- [ ] Add a repository description and topics on GitHub.
- [ ] Write a comprehensive README.
- [ ] Document the project objectives.
- [ ] Create an architecture diagram.
- [ ] Document Azure infrastructure.
- [ ] Include Terraform configuration.
- [ ] Include Docker configuration.
- [ ] Include Cowrie configuration.
- [ ] Include useful KQL queries.
- [ ] Include Sentinel analytics rules.
- [ ] Include screenshots of real detections and incidents.
- [ ] Include the SOC investigation report.
- [ ] Document security decisions and limitations.
- [ ] Document deployment and teardown instructions.
- [ ] Review the repository for secrets and sensitive information.
- [ ] Publish final project findings.

**Completion criteria:** Someone reviewing your GitHub repository can understand the architecture, reproduce the lab and evaluate your security analysis skills.

---

# Recommended Daily Study Routine

For approximately 90 minutes per day:

| Activity | Time |
|---|---:|
| Learn theory and documentation | 20 min |
| Hands-on exercises | 50 min |
| Notes and documentation | 20 min |

# Learning Principles

1. Don't blindly copy commands. Understand what each command does.
2. Build everything yourself before asking AI to generate configurations.
3. Break things deliberately and practice troubleshooting.
4. Document mistakes and solutions.
5. Don't move to the next milestone until you understand the current one.
6. Keep Azure costs under control. Destroy resources when they are not needed.
7. Prioritize a working, documented project over unnecessary complexity.

# Final Objective

By completing these milestones, you will have:

- Practical Linux administration experience.
- Azure networking and infrastructure knowledge.
- Infrastructure as Code experience with Terraform.
- Containerization experience with Docker.
- Hands-on honeypot experience with Cowrie.
- Log collection and analysis experience.
- KQL querying skills.
- Microsoft Sentinel SIEM experience.
- Security detection and incident investigation experience.
- A documented cybersecurity portfolio project.

**First task: Complete Milestone 0 — Account Security and Cost Control.**

Then move to Milestone 1: learn the fundamentals, build the network manually in Azure, test it and document what you learned before moving on to the VM.