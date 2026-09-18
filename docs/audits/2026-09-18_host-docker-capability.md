# Host Docker Capability Check for GitHub MCP

**Date:** 2026-09-18
**Evidence source:** commands executed by the host operator as `cristof` on
`Epic`.

## Result

```text
Docker executable: /usr/bin/docker
Docker client: 28.5.1
Docker server: 28.5.1
Docker root: /var/lib/docker
```

The real Hermes host user can reach a functioning Docker daemon. This satisfies
the prerequisite to evaluate GitHub's official local stdio MCP server as a
Docker child of host Hermes.

## Boundary preserved

This does not make the terminal Docker sandbox the Hermes runtime. The MCP will
be launched by host Hermes using the host Docker client. Its GitHub App private
key will be mounted read-only only into that official MCP container; it must not
be forwarded into terminal sandbox sessions.

## Next gate

Create a dedicated GitHub App, install it on `casasleonj/afi_tech` only, protect
its private key at the host path specified in
`docs/runbooks/GITHUB_APP_LOCAL_MCP_SETUP.md`, then pin the official MCP image
before adding any `mcp_servers.github` entry.
