# Active Task

Build the new multiagent environment progressively, with `afi_tech` as the
canonical active repository for its intention, architecture, protocols, state,
decisions, scripts, reproducible configuration, and evidence.

## Requirements
- Preserve continuity across agents and sessions.
- Close each significant advance as: inspect environment → implement/configure
  → test → measure → persist in `afi_tech` → Git/PR/CI → continue.
- Do not create a second repository unless a concrete, documented need proves
  that the canonical repository cannot serve the purpose.
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
- The former environment is retired and must not be treated as current runtime
  evidence.
- The initial baseline audit for the new accessible execution surface is
  recorded in `docs/audits/2026-09-17_initial-environment-baseline.md`.
- `TEMPORARY_BRIDGE`: a draft-PR workflow and branch-push CI are added and must
  be verified by a controlled two-push test before they become accepted delivery
  controls.
- The bridge is removed after an upstream GitHub MCP integration is validated
  in the real Hermes runtime against its documented retirement conditions.
- Next environment capability gate: audit Hermes, OpenCode and Claude Code in
  the actual target environment before configuring or installing any of them.
