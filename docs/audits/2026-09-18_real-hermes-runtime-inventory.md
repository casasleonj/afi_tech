# Real Hermes Runtime Inventory

**Evidence source:** read-only commands executed by the host operator on `Epic`.
**Observed gateway timestamp:** 2026-09-18 (from systemd status output).

## Verified topology

```text
Host `Epic` / user `cristof`
→ Hermes Agent v0.21.3 (git installation)
→ user-systemd gateway service / Telegram
→ Docker terminal backend for agent command sandboxing
```

This is topology A: the real Hermes process is on the host and Docker is only
its terminal backend. GitHub MCP must be configured in the host configuration,
not under the sandbox's `/workspace` or `/root`.

## Verified runtime facts

- Hermes: `v0.21.3` (2026.9.14), upstream `d4625b59`.
- Install directory: `/home/cristof/.hermes/hermes-agent`.
- Host config: `/home/cristof/.hermes/config.yaml`.
- Host secret scope: `/home/cristof/.hermes/.env` (contents not inspected).
- Active profile: `default`, model shown as `gpt-5.6-terra`.
- Gateway: `hermes-gateway.service`, enabled and active as user systemd service;
  main PID `8660` runs the Hermes Python module.
- Terminal backend: `docker`.
- `mcp_servers`: empty; `hermes mcp list` reported no configured servers.
- Native MCP CLI supports HTTP/SSE URLs, stdio, OAuth/header auth, `mcp test`
  and connection timeout configuration.

## Warning requiring controlled handling

`hermes gateway status` reports that the user unit or its drop-ins changed on
disk and asks for `systemctl --user daemon-reload`. Do not reload/restart until
MCP configuration is validated and the exact unit change is inspected.

## Next controlled action

Add the official remote GitHub MCP to the host with OAuth, then test discovery
before selecting the minimal toolset or reloading the gateway. Authentication is
performed outside chat; no token, device code or `.env` content is recorded.
