# Milestone 0: Account Security and Cost Control

> Date: 18 November 2026
> Status: mostly done (Pricing Calculator estimate and admin IP still to do)

Before building anything, I secured the account and put cost controls in place. This lab invites attackers in on purpose, so the account that controls it has to be the hardest thing in the whole setup to break into.

---

## 1. Enabled MFA on the Microsoft account

**What I did**
- account.microsoft.com → Security → Manage how I sign in
- Password, backup email, phone and passkey were already set up, but **two-step verification was OFF**
- Turned it on with the **Microsoft Authenticator** app and saved the recovery code offline

**Why**
- The Azure account holds a payment card and will control a VM exposed to the internet. A takeover could mean crypto mining on my bill or my lab being used against others.
- Authenticator app over SMS: SMS codes can be stolen with SIM swapping.
- Recovery code: the spare key if I lose my phone.

**Concept:** defence in depth.

---

## 2. Reviewed the mandatory MFA enforcement notice

**What I saw**
Azure's "Multifactor authentication (Phase 2)" page: MFA is now required for Azure CLI, PowerShell, the mobile app and **IaC tools such as Terraform**.

**What I did**
Nothing. I already meet the requirement, and I skipped the "elevated access" steps.

**Why**
- `az login` before Terraform will now prompt for MFA. That's expected.
- Granting myself elevated access I don't need would break least privilege.

**Concept:** principle of least privilege.

---

## 3. Created the subscription

**What I did**
- Started the Azure free trial
- Confirmed one directory (Default Directory) and one subscription, **Azure subscription 1**, status **Active**, role **Owner**

**Azure hierarchy (AZ-900)**

| Level | What it is |
|---|---|
| Directory (tenant) | Identity system for users and logins (Microsoft Entra ID) |
| Management group | Folder for subscriptions (Tenant Root Group) |
| Subscription | Billing and access boundary |
| Resource group | Container for related resources (`rg-honeypot-lab`) |
| Resource | The VM, VNet, NSG, disk and so on |

**Note:** Owner is fine for a personal lab. In a company, most users get a narrower RBAC role (Contributor, Reader).

---

## 4. Hit free-trial VM size restrictions

**Problem**
The default VM size (`Standard_D2s_v3`) showed `NotAvailableForSubscription` in West Europe.

**Investigation** (Azure CLI in Cloud Shell)

```bash
az vm list-skus --size Standard_B2s --all --output table \
  --query "[].{Region:locationInfo[0].location, Restricted:restrictions[0].reasonCode}"
```

- `Standard_B2s` was blocked in every public region for the trial subscription
- The few rows with no restriction were internal or unreleased regions (EUAP, STG and so on), so not usable
- B-series v1 (`B1s`, `B2s`) isn't offered at all for new deployments in West Europe

**Fix**
- Upgraded the subscription to **pay-as-you-go** (Basic support plan, free)
- Found `Standard_B2ats_v2` (2 vCPU, 1 GiB, x64) available, about **$6.86/month**

**Side lesson:** Cloud Shell warned that the subscription wasn't registered to `Microsoft.CloudShell`. New subscriptions must register each **resource provider** before using it:

```bash
az provider register --namespace Microsoft.CloudShell
```

---

## 5. Created a budget (twice)

The upgrade removed the first budget, so I recreated it.

| Setting | Value |
|---|---|
| Name | `budget-honeypot-lab` |
| Scope | Azure subscription 1 |
| Amount | 50 per month, resets monthly |
| Alerts | Actual 50%, 80%, 100%; Forecasted 100% |
| Recipient | my email |

**Why**
- Cloud costs grow quietly. The budget is a smoke alarm.
- The **forecasted** alert warns before the limit is hit, which is the most useful one.
- **A budget only sends emails. It doesn't stop anything.** The real cost control is `terraform destroy` when I'm not collecting data.

**Lesson:** after any subscription change (upgrade, transfer), check that budgets and alerts still exist.

---

## 6. Region and VM size

| Item | Decision |
|---|---|
| VM size | `Standard_B2ats_v2` (replaces the planned B1s/B2s) |
| Region | East US (available; European regions blocked or unconfirmed) |
| Log Analytics | Same region as the VM, to avoid cross-region data costs |

**Why East US is fine:** admin latency doesn't matter, bots scan every IP range anyway, and it's one of the cheapest regions.

---

## 7. Tag plan

Applied to every resource:

| Tag | Value |
|---|---|
| Project | honeypot-lab |
| Owner | Nick |
| Environment | Lab |
| CostCenter | Portfolio |
| AutoDelete | Yes |

---

## Still to do

- [ ] Pricing Calculator estimate: VM, 30 GB disk, Standard static public IP, ~1 GB/day Log Analytics, Sentinel trial check
- [ ] Note my public IP as `x.x.x.x/32` for `admin_source_ips`
- [ ] Update README: B1s/B2s → B2ats_v2

---

## Key terms

| Term | Meaning |
|---|---|
| MFA | Second factor (phone) on top of the password |
| Tenant / directory | Identity system holding users (Entra ID) |
| Subscription | Billing and access container |
| RBAC | Assigning only the roles people need |
| Least privilege | Take only the access a task needs |
| Resource provider | Service a subscription must register before using it |
| SKU restriction | A VM size blocked for a subscription or region |
| Budget alert | Email at a spending threshold; doesn't stop spending |