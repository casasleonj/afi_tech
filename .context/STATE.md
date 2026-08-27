# Current State

## Project
afi_tech. Early phase: the shared agent-context system is being built before any
product code. The repository currently contains only context files and a README.

## Repository
git@github.com:casasleonj/afi_tech.git — default branch `main`.
Git is the single source of truth for repository and code history.

## Context architecture (agreed, lightweight)
- `AGENTS.md` (root): small common bootstrap. Optional `CLAUDE.md` symlink for
  tools that load that filename.
- `.context/PROTOCOL.md`: detailed method, consulted by section on demand.
- `.context/STATE.md` / `TASK.md` / `DECISIONS.md` / `CONVENTIONS.md`: mutable
  operational snapshot, owned by Hermes.
- `.context/handoffs/`: dated, immutable handoff files; `latest.md` is a pointer
  to the newest one.
- `.context/research/`: versioned analysis and evidence.
- Obsidian may later open this repo as a read-only view for durable human notes.
  No separate vault, no MCP layer, no enforcement tooling for now
  (`DECISIONS.md`).

## Current phase
Validate the context and handoff protocol in real multi-agent use before adding
any heavier layer.

## Out of scope for this file
Ephemeral runtime facts — agent availability, rate limits, auth status, whether
the working tree is clean or pushed — do NOT belong here. They are point-in-time
and unverifiable by a later reader. Record them, dated, in the relevant handoff.
