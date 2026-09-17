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

Evaluate GitHub's official `github/github-mcp-server` **inside the real Hermes
runtime**, before any custom integration. Enable only toolsets required to:

1. read repository metadata and branches;
2. create and read pull requests;
3. read CI/status checks;
4. read reviews and comments.

Do not enable repository administration, secrets, deployments, workflow writes,
merge, delete, or arbitrary code-write tools for the evaluation.

## Authentication policy

1. Prefer a GitHub App installation token or other short-lived credential that
   can be renewed non-interactively by the real runtime.
2. Use OAuth only when the official MCP's supported flow and credential storage
   are verified for the runtime.
3. Reject a permanent personal PAT by default. Any exception needs a documented
   scope, expiry, rotation owner, rollback and approval.
4. Secrets remain outside `afi_tech`; only names, required permissions and
   non-sensitive evidence are versioned.

Compatibility between the official MCP and a GitHub App token is **unverified**
until it is tested in the real runtime. Do not claim support from this design.

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
