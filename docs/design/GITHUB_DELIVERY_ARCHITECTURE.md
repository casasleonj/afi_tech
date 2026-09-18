# GitHub Delivery Architecture

**Status:** `NOT_READY` for the final Hermes integration.
**Bridge status:** `TEMPORARY_BRIDGE`; `replacement_required: true`.

## Target flow

```text
Hermes (real runtime)
  → GitHub integration with limited tools
  → isolated work branch
  → OpenCode change + local tests
  → push
  → Hermes creates/reads PR
  → CI/status checks
  → Claude independent review
  → correction loop when technical failures exist
  → explicit PROTO-GIT merge gate
  → smoke verification on main
  → handoff, evidence and state persisted in afi_tech
```

The GitHub Action bridge only creates a draft PR after push. It is not the final
architecture and cannot satisfy direct Hermes PR, CI or review operations.

## Final integration candidate

Evaluate GitHub's official `github/github-mcp-server` **from the real Hermes
runtime**, before any custom integration. The preferred candidate is its local
stdio server authenticated as a GitHub App installation: it is a child of the
host Hermes process and refreshes short-lived installation tokens. This does not
mean the terminal Docker sandbox is the MCP runtime.

GitHub's hosted endpoint is `https://api.githubcopilot.com/mcp/`, but generic
dynamic OAuth registration is rejected. It is therefore not an install path for
the current Hermes configuration unless a pre-registered OAuth App is supplied
and its client configuration is separately validated. Do not repeatedly retry
the generic `--auth oauth` flow.

Enable only toolsets required to:

1. read repository metadata and branches;
2. create and read pull requests;
3. read CI/status checks;
4. read reviews and comments.

Do not enable repository administration, secrets, deployments, workflow writes,
merge, delete, or arbitrary code-write tools for the evaluation.

## Authentication policy

1. Prefer a GitHub App installation token that the official local MCP server
   renews non-interactively in its host-process child.
2. Use hosted OAuth only with a deliberate, pre-registered GitHub OAuth App,
   pinned callback details and validated Hermes OAuth client settings.
3. Reject a permanent personal PAT by default. Any exception needs a documented
   scope, expiry, rotation owner, rollback and approval.
4. Secrets remain outside `afi_tech`; only names, required permissions and
   non-sensitive evidence are versioned.

Compatibility between the official local MCP and a GitHub App token is the
officially documented candidate, but remains **unverified in this runtime**
until the host test passes. Do not claim it works from this design.

## Minimum target permissions

The final identity should request only what the enabled tools need:

- Metadata: read.
- Contents: read for repository/branch context; Git push remains a separate,
  scoped delivery identity.
- Pull requests: read/write to create and query PRs.
- Issues: read for PR conversation comments where GitHub exposes them as issues.
- Checks and commit statuses: read.
- Actions: read, only if the selected official MCP tool requires it to inspect
  workflow runs.

Excluded by default: administration, secrets, deployments, environments,
repository settings, workflow writes, contents write through MCP, merge, review
submission and approval.

## Bridge comparison and retirement

| Dimension | `TEMPORARY_BRIDGE` Action | Final Hermes + GitHub MCP |
| --- | --- | --- |
| PR creation | draft only after allowed branch push | direct, task-aware operation |
| Authentication | ephemeral `github.token` | short-lived app/OAuth credential, validated in runtime |
| CI visibility | no direct Hermes read path | Hermes reads status/checks |
| Reviews | none | read only in initial scope |
| Merge | impossible | explicit gate; no enablement until PROTO-GIT passes |
| Maintenance | repository workflow | runtime configuration + upstream MCP |

Remove `.github/workflows/auto-pr.yml` through a reviewed PR after the final
integration passes `docs/evals/GITHUB_DELIVERY_E2E.md` and comparison shows the
bridge adds no material safety or reliability value.
