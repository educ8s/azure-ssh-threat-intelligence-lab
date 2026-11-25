# Milestones 1–3: Networking and VM administration

> Status: Network and VM deployment milestones are marked complete in
> [`tasks.md`](../tasks.md). This page records the design currently represented
> by the repository; add command output and screenshots after sanitizing them.

## Addressing and resources

| Resource | Configuration |
|---|---|
| Resource group | `rg-honeypot-lab` |
| Region | East US |
| Virtual network | `10.0.0.0/16` |
| Subnet | `10.0.1.0/24` |
| Public IP | Standard, static |
| VM | Ubuntu Server 24.04 |

The VM has a public address for the Cowrie bait service. The real SSH daemon
uses port 2222 and is restricted to the admin source IP list.

## Network security rules

| Direction | Port/destination | Source | Purpose |
|---|---|---|---|
| Inbound | TCP 22 | Any | Public Cowrie bait service |
| Inbound | TCP 2222 | `admin_source_ips` | Key-only administrator access |
| Outbound | TCP 443 to `AzureMonitor` | VM subnet | Send monitoring data |
| Outbound | TCP 443 to `AzureActiveDirectory` | VM subnet | Agent authentication |
| Outbound | TCP 80/443 to Internet | VM subnet | Updates and image downloads |
| Outbound | All other traffic | Any | Denied by the NSG |

The Terraform source is the source of truth for the configured rules. Azure
NSGs do not filter by country; use narrowly scoped IP prefixes for administration.
The real admin IP belongs in ignored local Terraform variables, never in this
document or a screenshot.

## Host access and validation

- The real SSH service is on port 2222; password authentication and root login
  are disabled.
- Keep an existing admin session open until a new connection on port 2222 has
  been verified.
- The Ubuntu host firewall is default-deny inbound and permits admin SSH on
  port 2222.
- Validate the NSG and host firewall independently, then verify the public port
  22 endpoint reaches Cowrie rather than the host SSH daemon.

## Evidence to add

- Sanitized VM and NSG configuration screenshots.
- Successful key-based admin SSH test on port 2222.
- Firewall and connectivity test results.

Do not include public IPs, private keys, subscription identifiers, or Terraform
state in screenshots or documentation.
