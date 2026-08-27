# AGENTS.md — afi_tech

Common bootstrap for Hermes, Claude Code, OpenCode, and Codex.
Keep this file small and high-signal. The detailed method is
`.context/PROTOCOL.md` — the single source for the rules summarized here.

## Mission
Build and maintain afi_tech through disciplined, evidence-based, token-efficient
collaboration between the agents above.

## Roles
- Hermes: orchestrator and coordinator; owns the mutable snapshot files
  (`.context/STATE.md`, `TASK.md`, `DECISIONS.md`, `CONVENTIONS.md`).
- Claude Code, OpenCode, Codex: specialized workers. They add new immutable
  files (handoffs, research), update `handoffs/latest.md` to point to their
  handoff, and propose other snapshot changes in that handoff.
- No agent inherits another agent's conversation unless it is explicitly given.

## Session bootstrap
Read before acting (all small, all under `.context/`):
- `STATE.md` — durable project state.
- `TASK.md` — active task.
- `DECISIONS.md` — standing decisions and what was deliberately rejected.
- `CONVENTIONS.md` — how to write context and handoffs.
- `handoffs/latest.md` — pointer to the newest handoff; then open the file it
  names.

Consult `PROTOCOL.md` by section when doing significant work or when a rule is
unclear. It is a reference, not required reading in full every session.

## Non-negotiable rules
- Never fabricate facts, sources, APIs, commands, versions, results, benchmarks,
  or precedents. Mark what is verified vs. inferred vs. unknown.
- Verify load-bearing context against the actual repo (`git status`, files,
  code) before relying on it. If context conflicts with the repo, trust the repo
  and flag the stale context — do not act on it silently.
- Source-of-truth order: (1) explicit user decisions, (2) verified repo state,
  (3) authoritative technical/domain sources, (4) documented project decisions
  and conventions, (5) verified history, (6) inference.
- Git is the single source of truth for repository and code history.
- Never persist credentials, tokens, keys, or secrets in any tracked file.
- Never rewrite git history or force-push without explicit authorization.
- After significant work, leave a handoff (`PROTOCOL.md` §15) and update the
  snapshot files that no longer match reality.

## Completion
A plausible first draft is not done. Significant work needs verification, one
deliberate critical-review pass, and explicit reporting of remaining
uncertainty.
