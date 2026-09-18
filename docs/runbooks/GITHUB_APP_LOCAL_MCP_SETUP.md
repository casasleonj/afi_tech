# Runbook — GitHub App + Official Local MCP

**Status:** `HOST_DOCKER_VERIFIED; APP_NOT_CREATED`

This procedure creates a dedicated GitHub App and evaluates GitHub's official
local stdio MCP server from the **host Hermes runtime**. It never configures an
MCP inside the terminal Docker sandbox.

## Preconditions

- Hermes host: `Epic`, user `cristof`.
- Hermes home: `/home/cristof/.hermes`.
- Target repository: `casasleonj/afi_tech` only.
- The disabled remote OAuth entry has been removed.
- Human authorization was granted to create this limited App and evaluate the
  official local MCP.

## 1. Read-only host Docker check

Run on the host:

```bash
command -v docker
docker version --format 'client={{.Client.Version}} server={{.Server.Version}}'
docker info --format 'root={{.DockerRootDir}}'
```

Do not pull an image or create an MCP entry until this output shows that the
`cristof` user can reach the Docker daemon.

**Evidence:** host Docker access passed (`/usr/bin/docker`, client/server
`28.5.1`, root `/var/lib/docker`); see
`docs/audits/2026-09-18_host-docker-capability.md`.

## 2. Create the dedicated GitHub App

In the GitHub account that owns `casasleonj/afi_tech`, open:

```text
Settings → Developer settings → GitHub Apps → New GitHub App
```

Set:

- **Name:** a globally unique `afi-tech-hermes-mcp-<suffix>` name.
- **Homepage URL:** `https://github.com/casasleonj/afi_tech`.
- **Webhook:** inactive; do not configure a webhook URL or secret.
- **Installation scope:** only the owning account; install it only on the
  selected repository `casasleonj/afi_tech`.

Repository permissions, exactly:

- Metadata: read-only (automatic).
- Contents: read-only.
- Pull requests: read and write.
- Issues: read-only.
- Actions: read-only.
- Checks: read-only.
- Commit statuses: read-only.

Do not grant administration, secrets, workflows, deployments, environments,
packages, members, organization access, contents write, review write or merge
permissions. Do not subscribe to events.

After creation, record only the non-secret **App ID** and installation ID in the
host operator's private operational notes. Do not commit either as a secret;
never send a private key through Telegram.

## 3. Protect the App key on the host

Generate the private key in GitHub, download it directly to the host, then move
it into a host-only directory:

```bash
install -d -m 700 /home/cristof/.hermes/secrets
mv "$HOME/Downloads/<downloaded-github-app-key>.pem" \
  /home/cristof/.hermes/secrets/afi-tech-github-app.pem
chmod 600 /home/cristof/.hermes/secrets/afi-tech-github-app.pem
stat -c '%a %U %n' /home/cristof/.hermes/secrets/afi-tech-github-app.pem
```

Expected last line begins `600 cristof`. Never place the PEM in `afi_tech`,
`~/.hermes/.env`, a command argument, terminal sandbox, or chat.

## 4. Pin and inspect the official MCP image

After the App and protected key exist, pull GitHub's official image once from
the host, inspect its immutable digest, and record the digest in the host MCP
configuration/run evidence. Do not configure a mutable `:latest` image for
long-lived runtime execution.

The official server receives only these values:

- `GITHUB_APP_ID` — non-secret App ID.
- `GITHUB_APP_INSTALLATION_ID` — non-secret installation ID.
- `GITHUB_APP_PRIVATE_KEY_PATH=/run/secrets/afi-tech-github-app.pem`.
- `GITHUB_TOOLSETS=repos,pull_requests,actions` initially.
- `GITHUB_LOCKDOWN_MODE=true`.

The host key is mounted read-only at `/run/secrets/afi-tech-github-app.pem`
inside the official MCP container. No host GitHub variable is forwarded to the
Hermes terminal sandbox.

## 5. Add, test, and restrict tools

Create the `mcp_servers.github` stdio entry through the real host `hermes mcp`
command using `docker run -i --rm`, the pinned official image digest, and the
read-only key mount. Add only the environment above. Do not put key material in
the config.

Run `hermes mcp test github`. Only after a successful tool listing, run:

```bash
hermes mcp configure github
```

Allow only the discovered operations needed for:

1. repository and branch read;
2. draft PR create/read;
3. CI/status read;
4. review/comment read.

Reject discovered tools that administer repositories, alter secrets/workflows,
write contents, submit reviews, approve, merge, delete or deploy.

## 6. Controlled reload and evidence

Only after the test and filter pass, inspect the changed user-systemd unit,
execute the necessary `systemctl --user daemon-reload`, and use the documented
Hermes MCP reload/restart mechanism. Then prove the GitHub MCP works from both
the host CLI and the Telegram-served `default` profile.

## Rollback

1. Disable/remove `mcp_servers.github` with `hermes mcp remove github`.
2. Reload/restart only if the tested Hermes procedure requires it.
3. Uninstall the GitHub App from `casasleonj/afi_tech` and delete its host key
   only after confirming the rollback decision. Revocation/deletion is a human
   approved security action; record non-sensitive evidence only.
