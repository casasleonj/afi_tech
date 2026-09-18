# Hermes Handoff — GitHub Remote OAuth Rejected

## Task
Add and test the official GitHub MCP in the real Hermes host.

## Result
- The host ran the supplied remote OAuth command against GitHub's hosted MCP.
- GitHub rejected Hermes' generic dynamic client registration with `404`.
- The command saved an explicitly **disabled** `github` MCP entry after the
  operator accepted its prompt. No OAuth token was acquired, no tool was
  discovered, and no gateway reload occurred.

## Correction
The prior recommendation to use generic `--auth oauth` was wrong for GitHub's
hosted MCP. Hermes' current official MCP documentation says GitHub is excluded
from its catalog precisely because hosted GitHub MCP requires each client host
to bring a GitHub OAuth App; generic dynamic client registration is rejected.
The official hosted URL has a trailing slash, but correcting that URL alone does
not solve the OAuth-client requirement.

## Decisions
- Treat the hosted generic OAuth route as incompatible with the present Hermes
  configuration; do not retry it.
- Prefer GitHub's official local stdio MCP and a repository-scoped GitHub App
  over a permanent personal PAT.
- Keep the bridge as `TEMPORARY_BRIDGE` until the direct runtime integration
  passes its documented E2E gates.

## Immediate recovery
On the real host run:

```bash
hermes mcp remove github
hermes mcp list
```

This removes only the disabled failed entry. Do not run `hermes mcp login github`
or restart the gateway.

## Verification
- The host terminal displayed `Registration failed: 404 404 page not found`.
- Hermes reported that it saved the entry disabled and instructed a later test.
- Hermes and GitHub official documentation independently identify generic
  dynamic registration as unsupported for this hosted GitHub MCP route.

## New preferred candidate
Evaluate GitHub's official local stdio MCP authenticated with a least-privilege
GitHub App installation. GitHub documents that this mode mints and refreshes
short-lived installation tokens and is unavailable on the hosted HTTP transport.
The stdio process must be launched by host Hermes; it is not the terminal Docker
sandbox. A host Docker container is acceptable only as that official MCP child,
with the GitHub App key mounted read-only and never forwarded to sandbox tools.

## Risks/problems
- A GitHub App private key can mint installation tokens for every repository and
  permission granted to that App; it requires host-only `0600` storage and a
  repository-only installation.
- The host gateway reports a changed user-systemd unit. Do not reload it until
  the MCP connection and selected tools are verified.

## Required approval / prerequisites
Do not install or configure it yet. The next step needs human approval to:
1. create a dedicated GitHub App and private key;
2. install it only on `casasleonj/afi_tech` with minimum permissions;
3. verify host Docker access and pull/pin GitHub's official image.

## Files changed
- `docs/audits/2026-09-18_github-mcp-remote-oauth-evaluation.md`
- `docs/audits/2026-09-18_real-hermes-runtime-inventory.md`
- `docs/design/GITHUB_DELIVERY_ARCHITECTURE.md`
- `docs/runbooks/HERMES_GITHUB_RUNTIME.md`
- `.context/{STATE,TASK,DECISIONS}.md`
- `.context/handoffs/latest.md`
- this handoff

## Status
- Bridge: `READY_WITH_LIMITATIONS`.
- Direct Hermes GitHub integration: `NOT_READY`.

## Remaining work
1. Remove the failed disabled MCP entry on the host.
2. Obtain explicit approval for the GitHub App and official local stdio MCP.
3. Verify host Docker, configure/test the MCP, filter tools, and reload only as
   required.
4. Prove repository/branch/PR/CI/review reads from both host CLI and Telegram,
   then execute the documented delivery E2E gates.

## Recommended next step
Run `hermes mcp remove github && hermes mcp list` on the host, then explicitly
approve or decline creation of the repository-scoped GitHub App and evaluation
of GitHub's official local stdio MCP server.
