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
   Use the official GitHub catalog/install flow only when that release exposes
   it; otherwise use the supported `hermes mcp add`, `hermes mcp test` and
   `hermes mcp configure` flow. Record the exact supported command as evidence.
2. Install/enable it only on the real runtime through that verified Hermes
   command/configuration path.
3. Select only repository/branch read, PR create/read, CI/status read and
   review/comment read operations.
4. Complete OAuth or GitHub App credential authorization outside chat. Prefer a
   GitHub App installation token or another short-lived renewable credential.
5. Restart/reload Hermes only when the real runtime's documented procedure says
   it is required.
6. Use `hermes mcp list` and a controlled repository probe to verify discovery.

Do not copy PATs, device codes, OAuth tokens or private keys into Telegram,
commands, `afi_tech`, handoffs or audit evidence.

## 3. Acceptance and removal

Run `docs/evals/GITHUB_DELIVERY_E2E.md`. Compare official MCP results to the
bridge on security, permissions, autonomy, complexity, reliability, maintenance,
CI integration and traceability. Remove the bridge via reviewed PR if the MCP
covers the bridge case without losing a measured benefit.
