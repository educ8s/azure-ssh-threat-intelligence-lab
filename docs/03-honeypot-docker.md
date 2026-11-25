# Milestones 5–6.5: Docker, Cowrie, and decoy data

> Status: Docker and Cowrie milestones are marked complete in
> [`tasks.md`](../tasks.md). Exact Compose and Cowrie configuration files are
> not currently present in this checkout.

## Intended service boundary

- Cowrie listens on the public bait port through a container.
- The real host SSH service remains separate on port 2222 for administration.
- The container is intended to run as a non-root user with restricted
  capabilities, a read-only filesystem where supported, and resource limits.
- Cowrie records activity in JSON logs for collection by Azure Monitor.

## Decoy data

The roadmap records a customized fake filesystem, a planted shell history, fake
application configuration credentials, and traceable fake AWS keys. Never place
real credentials or private keys in the decoy filesystem or repository.

## Configuration and verification status

The requested sanitized Compose file, `cowrie.cfg`, and user database are not
present in this checkout. Add them under `docker/` and `cowrie/` after reviewing
them for secrets; do not treat this page as a substitute for the actual runtime
configuration.

When adding the files, document:

- Image/version and port mappings.
- User, capabilities, filesystem, and resource restrictions.
- Cowrie log path and persistent-volume behavior.
- Safe test login, command execution, and confirmation that JSON events appear.
