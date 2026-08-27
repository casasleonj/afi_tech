# Project Decisions

## Context architecture
- AGENTS.md is the concise project-wide agent contract.
- .context/ contains detailed methodology and operational state.
- Complete conversations should not be transferred when structured context is sufficient.
- Git is authoritative for repository and code history.
- Obsidian will be evaluated later as a durable human knowledge layer.
- MCP will be evaluated later as an integration/access layer.

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
- `handoffs/latest.md` is a pointer; handoff history is dated immutable files.
- `research/*.md` stays versioned.
- Minimal `.gitignore`; `CONVENTIONS.md` covers language, handoff naming, and
  ownership; `CLAUDE.md` is a symlink to `AGENTS.md`.

Deliberately rejected for now: a plural `TASKS.md`, an ADR directory, an MCP
layer, lock files, per-agent worktrees, and enforcement scripts/hooks.
Rationale: avoid over-architecting a project with no product code yet; revisit
only if real multi-agent use shows a concrete need. The fuller analysis this
decision narrows is `.context/research/context-layer-architecture-claude.md`.
