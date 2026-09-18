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
- The bridge passed its controlled two-push idempotence test and is
  `READY_WITH_LIMITATIONS`; it does not satisfy the final Hermes GitHub gate.
- The real-host audit/install gate remains pending a secure host command channel;
  do not treat sandbox files as Hermes runtime configuration.
- Host command access is now established through the operator. The generic
  hosted GitHub OAuth route failed because GitHub rejects dynamic client
  registration; remove the disabled entry. Next: evaluate the official local
  stdio GitHub MCP with a least-privilege GitHub App, then restrict its toolset
  before a controlled gateway reload and Telegram test.
- Human authorization for that App/MCP evaluation is recorded. The immediate
  host Docker capability gate passed. Next: create the repository-scoped App
  and protect its key; setup details and rollback are versioned in
  `docs/runbooks/GITHUB_APP_LOCAL_MCP_SETUP.md`.
- Before any GitHub App key or MCP image setup, complete the secret-safe host
  PID/environment probe documented in
  `docs/audits/2026-09-18_new-installation-topology-reconstruction.md` to
  close the topology evidence record.
- Next environment capability gate: audit Hermes, OpenCode and Claude Code in
  the actual target environment before configuring or installing any of them.
