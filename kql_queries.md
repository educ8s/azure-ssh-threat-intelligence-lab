// =====================================================================
// Cowrie Honeypot - KQL Hunting Queries (Microsoft Sentinel / Log Analytics)
// Table: Cowrie_CL  (custom log, SSH honeypot events)
// Author: Nick Koumaris
// =====================================================================


// ---------------------------------------------------------------------
// 1. Most active source IPs
// Ranks attacker IPs by number of connections. Use to spot the loudest
// attackers and coordinated subnets.
// ---------------------------------------------------------------------
Cowrie_CL
| where eventid == "cowrie.session.connect"
| summarize attempts = count() by src_ip
| sort by attempts desc


// ---------------------------------------------------------------------
// 2. Top attempted passwords
// Extracts the password from each failed login and ranks by frequency.
// ---------------------------------------------------------------------
Cowrie_CL
| where eventid == "cowrie.login.failed"
| extend password = extract(@"/(.*)\] failed", 1, message)
| summarize attempts = count() by password
| sort by attempts desc
| take 20


// ---------------------------------------------------------------------
// 3. Top attempted usernames
// Extracts the username from each failed login and ranks by frequency.
// ---------------------------------------------------------------------
Cowrie_CL
| where eventid == "cowrie.login.failed"
| extend username = extract(@"\[([^/]+)/", 1, message)
| summarize attempts = count() by username
| sort by attempts desc
| take 20


// ---------------------------------------------------------------------
// 4. Brute-force detection (basis for the Sentinel analytics rule)
// Any single IP with more than 20 failed logins in the window, with the
// first and last seen times. MITRE ATT&CK T1110 - Brute Force.
// ---------------------------------------------------------------------
Cowrie_CL
| where eventid == "cowrie.login.failed"
| summarize FailedAttempts = count(), StartTime = min(TimeGenerated), EndTime = max(TimeGenerated) by src_ip
| where FailedAttempts > 20


// ---------------------------------------------------------------------
// 5. Successful logins - decoy credential used
// Successful authentications on the decoy, excluding own test traffic
// (localhost / Docker gateway). MITRE ATT&CK T1078 - Valid Accounts.
// ---------------------------------------------------------------------
Cowrie_CL
| where eventid == "cowrie.login.success"
| where src_ip !in ("172.18.0.1", "127.0.0.1")
| project TimeGenerated, src_ip, message
| sort by TimeGenerated desc


// ---------------------------------------------------------------------
// 6. Malware delivery - file download / upload attempts
// Captured files fire file_download / file_upload; the command branch
// catches wget/curl/tftp/scp staging attempts. MITRE ATT&CK T1105 -
// Ingress Tool Transfer.
// ---------------------------------------------------------------------
Cowrie_CL
| where eventid in ("cowrie.session.file_download", "cowrie.session.file_upload")
    or (eventid == "cowrie.command.input" and message has_any ("wget", "curl", "tftp", "scp", "ftpget"))
| project TimeGenerated, src_ip, eventid, message
| sort by TimeGenerated desc


// ---------------------------------------------------------------------
// 7. Post-login behaviour - most common commands run
// Extracts the command from each command.input event and ranks by
// frequency. Use to profile recon, evasion probes, and payload staging.
// ---------------------------------------------------------------------
Cowrie_CL
| where eventid == "cowrie.command.input"
| extend cmd = extract(@"CMD: (.*)", 1, message)
| summarize times = count() by cmd
| sort by times desc
| take 25


// ---------------------------------------------------------------------
// 8. Client fingerprints (hassh)
// Groups attackers by SSH client fingerprint and counts distinct IPs
// per fingerprint. One hassh across many IPs indicates a shared toolkit.
// ---------------------------------------------------------------------
Cowrie_CL
| where eventid == "cowrie.client.kex"
| extend hassh = extract(@"fingerprint: (\w+)", 1, message)
| summarize distinct_IPs = dcount(src_ip), attempts = count() by hassh
| sort by distinct_IPs desc