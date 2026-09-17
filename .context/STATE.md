# Current State

## Project
afi_tech es el repositorio canónico y activo del sistema multiagente. El
entorno anterior dejó de existir; el entorno actual se construye
progresivamente y debe reflejarse en este repositorio.

## Repository
`https://github.com/casasleonj/afi_tech.git` — default branch `main`.
Git is the single source of truth for repository and code history.

## Architecture authority
- `docs/architecture/HERMES_CONTEXTO_MAESTRO_v3.0.md` is the architectural
  authority.
- `docs/architecture/HERMES_INSTRUCCION_MAESTRA_AUTONOMA_v2.0.md` governs
  execution and yields to the architectural authority on conflict.
- The authority documents are preserved user-provided design inputs. Their
  statements about a Hostinger VPS or partial implementation are historical or
  target-design context, not verified facts about the new runtime.
- Runtime facts are evidenced in dated audit files and handoffs; do not infer
  them from this durable snapshot.

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
  No separate vault or MCP layer is active. The repository does include the
  deliberately minimal `scripts/verify-context.sh` validation gate and its CI
  workflow (`DECISIONS.md`).

## Current phase
Establish a reproducible baseline for the new environment, correct stale
context, and then advance capability-by-capability through the approved cycle:
inspect → implement/configure → test → measure → persist → Git/PR/CI.

## Out of scope for this file
Ephemeral runtime facts — agent availability, rate limits, auth status, whether
the working tree is clean or pushed — do NOT belong here. They are point-in-time
and unverifiable by a later reader. Record them, dated, in the relevant handoff.
