# Reconstruction — New Hermes Installation Topology

**Status:** `TOPOLOGY_A_DEMONSTRATED; NO_REINSTALL_REQUIRED`
**Scope:** current/new environment only. This does not rely on any retired VPS
assumption.

## A. Real topology

```text
Host Epic / user cristof
├─ Hermes Agent v0.21.3 installed from git
│  └─ /home/cristof/.hermes/hermes-agent
├─ Hermes user-systemd gateway (PID 8660)
│  └─ Telegram adapter / default profile
├─ Host configuration and state
│  └─ /home/cristof/.hermes/
└─ Docker daemon
   └─ terminal.backend=docker → isolated command sandbox/workspace
```

This is scenario **A**: Hermes runs on the host and Docker is a terminal
sandbox. It is not a second Hermes runtime and it is not the persistence layer
for the host Hermes gateway.

## B. Evidence

| Fact | Verified evidence |
| --- | --- |
| Hermes installation | `hermes --version` reported v0.21.3, git install at `/home/cristof/.hermes/hermes-agent` |
| Host config | `hermes config path` → `/home/cristof/.hermes/config.yaml` |
| Host secret scope | `hermes config env-path` → `/home/cristof/.hermes/.env` |
| Gateway | `hermes-gateway.service`, active/enabled user-systemd service, main PID `8660` executing Hermes Python |
| Telegram-serving profile | `hermes profile list` showed active/default `default` profile and running gateway |
| Docker role | secret-safe config probe returned `terminal.backend = docker` |
| Sandbox isolation | the tool-command sandbox reported hostname `14d27a94be4f`, user `root`, no `hermes` executable and Docker-container mount evidence |
| Host Docker | host `cristof` can reach `/usr/bin/docker`, client/server 28.5.1, daemon root `/var/lib/docker` |

## C. One installation, not two

One active Hermes installation is demonstrated: the host checkout plus its
virtual environment, both components of the same git installation. One active
Hermes gateway process is demonstrated: PID 8660. The sandbox lacks a `hermes`
executable, so it is not a second configured Hermes instance.

No evidence supports accidental duplicate active Hermes installations. A
secret-safe PID/environment probe remains available below to rule out an
additional running process rather than merely relying on path evidence.

## D. Why GitHub MCP cannot be configured from the sandbox

The Docker backend is intentionally an isolated command-execution surface. It
does not share the host Hermes executable, host `HERMES_HOME`, host
`config.yaml`, host `.env`, host token storage or gateway process namespace.
Configuring an MCP there would configure nothing used by the Telegram gateway
and would be ephemeral/wrong-scope.

The correct host command path was proven when the operator ran `hermes mcp add`
from the host: it wrote `/home/cristof/.hermes/config.yaml`. Its connection
failure was a separate GitHub hosted-MCP OAuth client-registration limitation,
not evidence of a broken Hermes installation or Docker topology problem.

## E. Minimum safe correction

1. Do not reinstall Hermes or modify the sandbox installation.
2. Administer MCP only with host `hermes mcp ...` commands or its host config.
3. Keep `terminal.backend: docker` for isolated task execution.
4. Keep GitHub credentials out of `docker_forward_env` and out of sandbox
   sessions.
5. Run the official local GitHub MCP as a child of host Hermes with a
   least-privilege GitHub App key mounted only into that MCP child.

## F. Remaining read-only confirmation

Run the secret-safe script below on the host before enabling an MCP. It prints
only topology/process/configuration metadata; it never reads or prints `.env`
content or credential values:

```bash
python3 - <<'PY'
from pathlib import Path
import os

pid = '8660'
env = {}
for item in Path(f'/proc/{pid}/environ').read_bytes().split(b'\0'):
    if b'=' in item:
        key, value = item.split(b'=', 1)
        env[key.decode('utf-8', 'replace')] = value.decode('utf-8', 'replace')

print('pid =', pid)
print('exe =', os.path.realpath(f'/proc/{pid}/exe'))
print('cwd =', os.path.realpath(f'/proc/{pid}/cwd'))
print('HOME =', env.get('HOME', 'UNSET'))
print('HERMES_HOME =', env.get('HERMES_HOME', 'UNSET'))
print('docker_on_gateway_PATH =', any(
    (Path(p) / 'docker').is_file() for p in env.get('PATH', '').split(':') if p
))
print('config_exists =', Path('/home/cristof/.hermes/config.yaml').is_file())
print('env_exists =', Path('/home/cristof/.hermes/.env').is_file())
active = 0
for p in Path('/proc').iterdir():
    if not p.name.isdigit():
        continue
    try:
        command = (p / 'cmdline').read_bytes()
    except OSError:
        continue
    if b'/home/cristof/.hermes/hermes-agent/' in command:
        active += 1
print('hermes_install_process_count =', active)
PY
```

## G. Final intended architecture

```text
Telegram
→ host user-systemd hermes-gateway.service
→ default Hermes profile at /home/cristof/.hermes
→ mcp_github_* tools from an official local GitHub MCP child
→ GitHub App installation token limited to casasleonj/afi_tech

Hermes task tool calls
→ terminal.backend=docker
→ isolated sandbox, without GitHub App credential forwarding
```

No status can be marked `READY` until this flow is tested from both host Hermes
CLI and the Telegram gateway profile.
