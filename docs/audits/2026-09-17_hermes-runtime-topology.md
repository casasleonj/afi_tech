# Hermes Runtime Topology Audit

**Date:** 2026-09-17
**Mode:** read-only

## Conclusion

**Topology A is demonstrated:**

```text
Hermes real on host
→ Docker terminal sandbox for agent command execution
```

It is not evidenced that Hermes runs inside the terminal sandbox or that the
sandbox holds the persistent Hermes configuration.

## Verified evidence

- Desktop-level process discovery observed a running `hermes` process, PID
  `8660`, alongside host `systemd`, `dockerd` and `containerd` processes.
- The command terminal ran in Docker container `752f32601d7b` (container
  hostname), with overlay filesystem and `/.dockerenv` present.
- The sandbox has no `hermes` executable, no Docker CLI/socket, and cannot see
  host PID `8660` through `/proc`.
- Sandbox mounts identify it as
  `/home/cristof/.hermes/sandboxes/docker/default/`; `/workspace` and `/root`
  are sandbox-specific writable paths.
- Only selected non-config Hermes assets are bind-mounted into the sandbox as
  read-only paths under `/root/.hermes/` (skills, attachments and caches).

## Unknown — requires real-host access

- Hermes host/user/home, actual `HERMES_HOME`, `config.yaml` and `.env` paths.
- Hermes process command line, parent/service manager, gateway process and
  controlled restart/reload mechanism.
- Provider/model/auth state, installed MCP servers, environment PATH and MCP
  logs.
- Whether the host configuration exposes the GitHub toolset to Telegram.

## Safety decision

Do not install/configure GitHub MCP in the sandbox. The final integration gate
remains `NOT_READY` until real-host audit and Telegram-path testing complete.

## Host diagnostic required

When a safe host command channel exists, execute the versioned procedure in
`docs/runbooks/HERMES_GITHUB_RUNTIME.md` and persist redacted results here as a
new dated audit; never copy `.env`, tokens, private keys or OAuth/device codes.
