# Active Task

Design and validate a shared context and handoff protocol for Hermes,
Claude Code, OpenCode, and Codex.

## Requirements
- Preserve continuity across agents and sessions.
- Avoid transferring complete conversations.
- Minimize unnecessary context and token usage.
- Never invent facts or unsupported technical details.
- Prefer authoritative and current evidence.
- Verify software against documentation and actual versions when practical.
- Investigate real-world industry precedents for consequential decisions.
- Deliberately search for bias, ambiguity, counterevidence, and failure modes.
- Iterate significant results until no relevant improvement is found.
- Compare independent analyses and verify convergence.
- Preserve uncertainty and material disagreement.
- Keep secrets out of persistent context.

## Status
- Protocol and lightweight context structure are in place (see `DECISIONS.md`,
  2026-08-27) and committed as `f6c35c2`, pushed to `origin/main`.
- The initial OpenCode → Claude Code handoff cycle has been executed and
  independently reviewed. Codex is unavailable in the current environment,
  so no Codex turn is required for this validation before adding any heavier
  layer.
