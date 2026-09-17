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
