# Current analysis findings

> This page contains only findings stated in the repository's project notes.
> Add query text, time range, record counts, and sanitized evidence before
> presenting these as a formal analysis.

## Authentication activity

- The checklist reports a coordinated set of three source IPs in
  `109.160.32.0/24` with identical attempt counts.
- The most frequently attempted password was reported as `123456`.
- Usernames associated with application targeting included `frappe` and
  `minecraft`.

The exact counts, observation window, query output, and enrichment sources are
not included in this checkout. Do not infer attribution or malicious intent
from an IP prefix alone.

## Detection and honeypot-awareness probes

No evidence or specific results for honeypot-detection probes are currently
recorded here. Add the event, timestamp, query, and supporting Cowrie records
when verified. Distinguish probe behavior from confirmed identification of the
honeypot.

## Reproducibility

Saved KQL should live under `kql/` with a comment header describing purpose,
required table/columns, and the query's time range. Check the actual table
schema before relying on column names; a schema-discovery query is provided.
