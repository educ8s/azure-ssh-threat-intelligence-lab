# Milestones 7–9: Monitoring and SIEM pipeline

> Status: Cowrie events were confirmed in `Cowrie_CL` on 24 November, according
> to the project checklist. The exact DCR transform and deployed rule exports
> are not included in this checkout.

## Data flow

```text
Cowrie JSON logs
    → Azure Monitor Agent (AMA)
    → Data Collection Rule (DCR)
    → Log Analytics workspace
    → Microsoft Sentinel
```

The Terraform configuration currently defines a Log Analytics workspace.
AMA/DCR setup and Sentinel onboarding are recorded as completed in
[`tasks.md`](../tasks.md), but their exported configuration should be added to
the repository only after sanitization.

## Verification checklist

- Confirm AMA is healthy on the VM.
- Confirm the DCR targets the VM and the intended Cowrie log source.
- Confirm fresh records appear in `Cowrie_CL`.
- Check ingestion volume and retention against the cost estimate.
- Confirm Sentinel is connected to the same workspace.
- Export analytics rules as JSON and verify that no tenant-specific identifiers
  or secrets are included.

## Analytics

The checklist records a scheduled brute-force rule with a threshold of more than
20 failed logins per source IP per hour, IP entity mapping, and MITRE technique
T1110. Export that rule to `sentinel/` from the deployed Sentinel configuration;
do not use an assumed table schema as a substitute for the live rule.

Other planned detections include suspicious commands, decoy-file access, and
suspicious successful logins. These remain incomplete in the roadmap.
