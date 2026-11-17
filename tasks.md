# Azure SSH Honeypot & Cloud SIEM Lab
## Cybersecurity Learning Roadmap

**Goal:** Build a functional Azure SSH honeypot, integrate it with Microsoft Sentinel, and develop practical SOC Analyst skills.

**Approach:** Learn → Build → Break → Troubleshoot → Document.

---

# Phase 1 — Infrastructure Fundamentals

## Milestone 1: Azure Networking

- [ ] Create an Azure account and understand the subscription structure.
- [ ] Create a Resource Group (`rg-honeypot-lab`).
- [ ] Create a Virtual Network (`10.0.0.0/16`).
- [ ] Create a subnet (`10.0.1.0/24`).
- [ ] Understand IPv4 addressing and CIDR notation.
- [ ] Understand public vs. private IP addresses.
- [ ] Learn TCP, UDP, ports and network protocols.
- [ ] Create a Network Security Group (NSG).
- [ ] Configure inbound security rules.
- [ ] Configure outbound security rules.
- [ ] Understand NSG priorities and default rules.
- [ ] Test network connectivity and firewall behavior.

**Completion criteria:** Understand how network traffic reaches an Azure VM and how an NSG filters that traffic.

## Milestone 2: Ubuntu VM Deployment

- [ ] Deploy Ubuntu Server 24.04 LTS.
- [ ] Select an appropriate VM size (e.g. Standard_B1s, subject to regional availability).
- [ ] Create an SSH key pair.
- [ ] Configure SSH key authentication.
- [ ] Assign a public IP address.
- [ ] Connect to the VM from your local computer.
- [ ] Update Ubuntu packages.
- [ ] Install basic administration tools.
- [ ] Learn Linux users and groups.
- [ ] Learn file permissions.
- [ ] Learn processes and services.
- [ ] Understand systemd.

**Completion criteria:** Successfully administer your Azure VM remotely using SSH keys.

## Milestone 3: Linux and Network Administration

- [ ] Learn Linux directory navigation and file management.
- [ ] Practice `ls`, `cd`, `find`, `grep`, `cat` and `less`.
- [ ] Learn `chmod`, `chown` and `sudo`.
- [ ] Understand `systemctl` and `journalctl`.
- [ ] Inspect authentication logs.
- [ ] Learn SSH server configuration.
- [ ] Understand listening ports using `ss`.
- [ ] Learn basic network commands: `ip`, `ping`, `curl` and `nc`.
- [ ] Learn basic packet inspection using `tcpdump`.
- [ ] Configure and test firewall rules.
- [ ] Troubleshoot deliberately broken network configurations.

**Completion criteria:** Diagnose common Linux administration and network connectivity problems independently.

---

# Phase 2 — Infrastructure Automation and Honeypot

## Milestone 4: Terraform

- [ ] Understand Infrastructure as Code (IaC).
- [ ] Install Terraform.
- [ ] Learn Terraform providers and resources.
- [ ] Understand variables, outputs and data sources.
- [ ] Understand Terraform state.
- [ ] Learn `terraform init`.
- [ ] Learn `terraform plan`.
- [ ] Learn `terraform apply`.
- [ ] Learn `terraform destroy`.
- [ ] Recreate the Resource Group using Terraform.
- [ ] Recreate the VNet and subnet.
- [ ] Recreate the NSG and security rules.
- [ ] Recreate the public IP, NIC and VM.
- [ ] Organize configuration into separate `.tf` files.
- [ ] Use variables and `.tfvars` files.
- [ ] Learn `terraform fmt` and `terraform validate`.
- [ ] Configure `.gitignore` to exclude sensitive files and state.
- [ ] Understand safe state management.

**Completion criteria:** Deploy and destroy the Azure infrastructure using Terraform.

## Milestone 5: Docker Fundamentals

- [ ] Understand containers and virtualization.
- [ ] Install Docker.
- [ ] Learn Docker images and containers.
- [ ] Run your first container.
- [ ] Understand Dockerfiles.
- [ ] Create a custom Dockerfile.
- [ ] Learn container port mapping.
- [ ] Understand Docker volumes and persistent storage.
- [ ] Learn Docker networking.
- [ ] Use Docker Compose.
- [ ] Inspect container logs.
- [ ] Run containers as non-root users.
- [ ] Learn container capabilities and resource limits.
- [ ] Practice hardening a container.

**Completion criteria:** Build, run, inspect and secure your own Docker container.

## Milestone 6: Cowrie SSH Honeypot

- [ ] Understand what honeypots are.
- [ ] Learn the difference between low-interaction and high-interaction honeypots.
- [ ] Understand how Cowrie works.
- [ ] Deploy Cowrie using Docker.
- [ ] Configure the fake SSH environment.
- [ ] Understand Cowrie authentication events.
- [ ] Connect to the honeypot using an SSH client.
- [ ] Generate test login attempts.
- [ ] Execute commands in the fake shell.
- [ ] Inspect Cowrie JSON logs.
- [ ] Understand session recordings.
- [ ] Understand how Cowrie handles downloaded files.
- [ ] Customize the fake filesystem.
- [ ] Distinguish authentication attempts from successful fake logins and command execution.

**Completion criteria:** Operate a Cowrie honeypot and understand the events it records.

---

# Phase 3 — Monitoring and SIEM

## Milestone 7: Azure Monitor and Log Analytics

- [ ] Understand Azure Monitor.
- [ ] Understand Log Analytics Workspaces.
- [ ] Create a Log Analytics Workspace.
- [ ] Understand Azure Monitor Agent (AMA).
- [ ] Install AMA on the VM.
- [ ] Understand Data Collection Rules (DCR).
- [ ] Configure a DCR.
- [ ] Understand Syslog and custom log collection.
- [ ] Collect Linux system logs.
- [ ] Configure Cowrie log ingestion.
- [ ] Verify that logs arrive in Log Analytics.
- [ ] Understand log retention and ingestion costs.

**Completion criteria:** Retrieve real Linux and honeypot events from Log Analytics.

## Milestone 8: Kusto Query Language (KQL)

- [ ] Understand what KQL is.
- [ ] Learn the `where` operator.
- [ ] Learn the `project` operator.
- [ ] Learn the `summarize` operator.
- [ ] Learn `count` and `sort by`.
- [ ] Learn `extend` and `distinct`.
- [ ] Learn `bin()` for time grouping.
- [ ] Learn `parse_json()` for structured logs.
- [ ] Understand joins.
- [ ] Query failed SSH authentication attempts.
- [ ] Identify the most active source IP addresses.
- [ ] Identify frequently attempted usernames.
- [ ] Analyze attacker activity over time.
- [ ] Build an attack timeline.
- [ ] Save useful queries in the GitHub repository.

**Completion criteria:** Write KQL queries that answer meaningful security questions using real honeypot data.

## Milestone 9: Microsoft Sentinel

- [ ] Understand what a SIEM is.
- [ ] Understand Microsoft Sentinel architecture.
- [ ] Connect Sentinel to your Log Analytics Workspace.
- [ ] Understand data connectors.
- [ ] Learn analytics rules.
- [ ] Understand alerts versus incidents.
- [ ] Create a brute-force detection rule.
- [ ] Create a suspicious login detection rule.
- [ ] Create a suspicious command execution detection rule.
- [ ] Configure incident generation.
- [ ] Investigate generated incidents.
- [ ] Understand entities and investigation graphs.
- [ ] Create a Sentinel workbook.
- [ ] Visualize attacker IPs and activity.

**Completion criteria:** Detect suspicious honeypot activity and generate incidents in Microsoft Sentinel.

---

# Phase 4 — SOC Analyst Skills

## Milestone 10: Threat Detection and MITRE ATT&CK

- [ ] Understand Indicators of Compromise (IoCs).
- [ ] Understand threat intelligence.
- [ ] Learn brute-force attack techniques.
- [ ] Identify suspicious usernames and passwords.
- [ ] Detect fake successful SSH logins.
- [ ] Identify suspicious commands.
- [ ] Investigate `wget` and `curl` activity.
- [ ] Understand file download behavior.
- [ ] Learn MITRE ATT&CK.
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

- [ ] Organize the GitHub repository.
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

**First task: Complete Milestone 1 — Azure Networking.**

Learn the fundamentals, build the network manually in Azure, test it and document what you learned before moving on to the VM.