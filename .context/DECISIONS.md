# Project Decisions

## Context architecture
- AGENTS.md is the concise project-wide agent contract.
- .context/ contains detailed methodology and operational state.
- Complete conversations should not be transferred when structured context is sufficient.
- Git is authoritative for repository and code history.
- Obsidian will be evaluated later as a durable human knowledge layer.
- MCP will be evaluated later as an integration/access layer.

## Canonical repository and synchronized delivery (2026-09-17)
- `afi_tech` is the canonical and active repository for the project; it is not
  a legacy or read-only coordination repository.
- The prior environment is retired. The current environment is new and must be
  built progressively without assumptions carried from the retired runtime.
- Every significant advancement follows: inspect environment →
  implement/configure → test → measure → persist in `afi_tech` → Git/PR/CI →
  continue.
- `afi_tech` records architecture, protocols, operational snapshots,
  reproducible configuration, scripts, decisions, and non-secret evidence.
- Do not create a second repository unless a documented, concrete need proves
  that `afi_tech` cannot serve the purpose. Prefer directories and explicit
  ownership within this repository first.
- The authority documents live under `docs/architecture/`; the architectural
  document prevails over execution guidance if they conflict.

## Git delivery automation (2026-09-17)
- **Status: `TEMPORARY_BRIDGE`.** A GitHub Actions workflow creates a *draft*
  PR only when an `agent/`, `feature/`, `fix/`, `docs/` or `chore/` branch is
  pushed. It closes the verified gap where the deploy SSH key can push Git but
  cannot call GitHub's PR API. `main`, `dependabot/**` and all unlisted branch
  types are excluded.
- The workflow receives only `contents: read` and `pull-requests: write`, uses
  GitHub's ephemeral `github.token`, and never receives a PAT, deploy key, or
  repository secret.
- The workflow may create a PR only; review, CI status, readiness and merge
  remain separate explicit gates. It must not auto-merge, approve/review PRs,
  check out or modify code, use `pull_request_target`, or change `main`.
- `context-contract` runs for matching branch pushes, which is the automated CI
  acceptance signal. A `pull_request` event induced by `github.token` may wait
  for maintainer approval; it is supplementary and never a blocking implicit
  approval path.
- Per-branch workflow concurrency plus duplicate-PR recovery makes the
  list/create sequence idempotent across rapid pushes and races with a manual
  PR creation.
- `github/github-mcp-server` is the preferred upstream interactive integration
  for direct PR and Actions operations. Its local adoption is deferred until
  the active Hermes host is accessible for configuration and OAuth; this Docker
  execution surface has no `hermes` CLI/configuration to modify.
- **Retirement condition:** evaluate the official GitHub MCP in the real Hermes
  runtime with non-interactive authentication (prefer GitHub App or short-lived
  credentials), limited toolsets, minimum permissions and read-only/lockdown
  modes where appropriate. It must demonstrably create/query PRs, read
  CI/status checks and read reviews/comments. Compare it against this bridge;
  remove the Action through a reviewed PR if it no longer adds value.
- Final GitHub delivery remains `NOT_READY`. A passing bridge test produces
  only `READY_WITH_LIMITATIONS`; it cannot close this gate.
- The bridge completed its controlled test: one Draft PR was retained across a
  reuse push and branch-push CI succeeded. It is usable as
  `READY_WITH_LIMITATIONS` only while `replacement_required: true` remains.
- Runtime topology is **A**: Hermes host + Docker terminal sandbox. GitHub MCP
  configuration belongs only to the host `HERMES_HOME` once real-host evidence
  identifies it; sandbox `~/.hermes` paths are non-canonical for this purpose.
- Real host configuration is `/home/cristof/.hermes/config.yaml`; host `.env`
  remains secret scope. Native MCP supports OAuth and no server is enabled.
  Never forward a GitHub credential into the terminal Docker sandbox without a
  separately demonstrated need.
- GitHub's hosted MCP rejects Hermes generic dynamic OAuth registration. Do not
  retry it blindly. The primary candidate is GitHub's official local stdio MCP
  authenticated as a GitHub App installed only on `casasleonj/afi_tech`, with
  its host private key mounted read-only solely into that MCP child.
- Keep the confirmed host Hermes installation and `terminal.backend: docker`.
  The fact that sandbox commands cannot administer host MCP is expected
  isolation, not evidence that Hermes is split or requires reinstallation.

## Quality methodology
- Significant work requires deliberate self-critique and iterative improvement.
- Important decisions require evidence and relevant real-world precedent.
- Independent agent analyses may be compared for convergence.
- Consensus is not proof.
- Material disagreement must not be hidden.

## Lightweight context architecture (2026-08-27)
Keep the existing small structure and fix it rather than adopt a heavier design.

In scope:
- `AGENTS.md` is a small common bootstrap; `PROTOCOL.md` is an on-demand
  sectioned reference, not required reading in full each session.
- `STATE.md` holds only durable state; ephemeral runtime facts go in handoffs.
- `TASK.md` and `DECISIONS.md` stay as single files for now.
- `handoffs/latest.md` is a pointer without mutable claims about an exact Git
  HEAD; handoff history is dated immutable files. This prevents a pointer from
  becoming stale merely because the commit that records it changes HEAD.
- `scripts/verify-context.sh` and `.github/workflows/context.yml` are accepted
  as the minimal reproducible validation/CI gate for the context contract. They
  add no runtime service, dependency, hook, credential, or network permission.
- The byte-for-byte authority documents under `docs/architecture/` are exempt
  from whitespace checks because Markdown hard-break spaces are part of the
  supplied source. All other changed paths remain subject to whitespace checks.
- `research/*.md` stays versioned.
- Minimal `.gitignore`; `CONVENTIONS.md` covers language, handoff naming, and
  ownership; `CLAUDE.md` is a symlink to `AGENTS.md`.

Deliberately rejected for now: a plural `TASKS.md`, an ADR directory, an MCP
layer, lock files, per-agent worktrees, and enforcement beyond the minimal
context validation/CI gate above.
Rationale: avoid over-architecting a project with no product code yet; revisit
only if real multi-agent use shows a concrete need. The fuller analysis this
decision narrows is `.context/research/context-layer-architecture-claude.md`.
