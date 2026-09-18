# Runbook — Real Hermes GitHub Integration

## Purpose

This runbook is executed on the **real Hermes runtime**, never assumed to be the
Docker build container. It evaluates the official GitHub MCP before custom code.

## 1. Safe runtime inventory

```bash
bash scripts/probe-hermes-github-runtime.sh
```

Save only the redacted output as dated evidence under `docs/audits/`. The script
must not print `.env`, token values, credential files or secret-bearing config.

## 2. Official MCP evaluation

1. Run `hermes mcp list` and `hermes mcp --help` on the installed release.
2. Do **not** use generic remote OAuth against
   `https://api.githubcopilot.com/mcp/`: GitHub rejects dynamic client
   registration. If a disabled failed entry exists, remove it before continuing.
3. Prefer GitHub's official local stdio server with a GitHub App installation.
   Before any image pull or configuration change, verify host Docker access and
   inspect the official image/version and command contract.
4. Create/install a dedicated GitHub App only after human approval. Scope it to
   `casasleonj/afi_tech`; request metadata/read-only content, PR read/write,
   Actions/check/status read, and issue/comment read only. Exclude repository
   administration, secrets, deployments, workflows, contents write, merge and
   review submission.
5. Keep the App private key in a host-only `0600` secret file. Mount it
   read-only only into the official stdio MCP child. Do not put it in Git,
   Telegram, command arguments, `afi_tech`, or the terminal sandbox.
6. Add and test it only through the real Hermes host command/configuration
   path. Use discovery then `hermes mcp configure github` to select only
   repository/branch read, PR create/read, CI/status read and review/comment
   read operations.
7. Restart/reload Hermes only when the real runtime's documented procedure says
   it is required and only after the MCP connection/configuration test passes.
8. Use `hermes mcp list` and a controlled repository probe to verify discovery.

Do not copy PATs, device codes, OAuth tokens or private keys into Telegram,
commands, `afi_tech`, handoffs or audit evidence.

## 3. Acceptance and removal

Run `docs/evals/GITHUB_DELIVERY_E2E.md`. Compare official MCP results to the
bridge on security, permissions, autonomy, complexity, reliability, maintenance,
CI integration and traceability. Remove the bridge via reviewed PR if the MCP
covers the bridge case without losing a measured benefit.
