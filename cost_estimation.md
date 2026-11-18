# Cost Estimate: 1-Month Run

> Source: Azure Pricing Calculator, 18 November 2026
> Region: East US · Currency: USD · Pay-as-you-go (MCA), Basic support

## Plan

The lab collects attack data for **one month (730 hours, 24/7)**, then the whole environment is removed with `terraform destroy`.

## Estimated cost for the month

| Item | Configuration | Cost (1 month) |
|---|---|---:|
| Virtual Machine | `Standard_B2ats_v2` (2 vCPU, 1 GiB, x64), Ubuntu, 730 h | $6.86 |
| Public IP | Standard (ARM), 1 static IPv4, 730 h | $3.65 |
| Managed Disk | Standard HDD S4, 32 GiB | $1.59 |
| Log Analytics | ~0.1 GB/day (~3 GB for the month), 31-day retention | $0.15 |
| Virtual Network + NSG | 1 VNet, no peering | $0.00 |
| Support | Basic | $0.00 |
| **Infrastructure total** | | **$12.25** |
| Microsoft Sentinel | ~3 GB analysed; $0 if the free trial covers the run | $0–10 |
| **Expected total** | | **~$12–22** |

Upfront cost: **$0.00**. Any remaining credit on the subscription is used first.

## Assumptions

- One honeypot produces about **0.1 GB of logs per day**.
- Retention stays at the free 31 days, so no long-term retention charges.
- Build and test time before the run (Milestones 1–9) is small, because resources are destroyed when not in use.
- Outbound bandwidth is negligible.

## Main risk: log volume

| Daily ingestion | Monthly Log Analytics cost (approx.) |
|---|---:|
| 0.1 GB/day (estimate) | ~$0.15 |
| 0.5 GB/day | ~$30 |
| 1 GB/day | ~$60–70 |

A very busy honeypot can cost more in logs than in compute.

## Cost controls

- Monthly budget: **50**, alerts at Actual 50/80/100% and **Forecasted 100%**
- Data Collection Rule collects only the Cowrie JSON log and the needed Syslog facilities
- Check Log Analytics usage after the first week (`Usage` table in KQL)
- Start the Sentinel free trial (if available) on the first day of the run
- `terraform destroy` at the end of the month, then confirm the resource group is gone and the bill drops to $0

## Design decisions driven by cost

| Decision | Reason |
|---|---|
| `B2ats_v2` instead of B1s/B2s | B-series v1 blocked or unavailable on the new subscription; cheapest modern x64 option |
| East US | Available for this subscription, low price, latency irrelevant for a honeypot |
| Log Analytics in the same region as the VM | Avoids cross-region transfer charges |
| Standard static IP | Basic public IPs were retired in September 2025 |
| No resource locks | Lets the lab be destroyed in one command |

*Estimates from the Azure Pricing Calculator. Actual billing depends on usage.*