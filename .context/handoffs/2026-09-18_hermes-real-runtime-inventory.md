# Hermes Handoff — Real Runtime Inventory

## Task
Identify the real Hermes runtime and verify native MCP support before any GitHub
MCP installation.

## Result
- Host operator commands demonstrated topology A: Hermes runs on host `Epic` as
  user `cristof`; Docker is `terminal.backend`, not Hermes's persistent runtime.
- Verified host installation/config/secret-scope paths, user-systemd Telegram
  gateway PID, active profile, MCP absence and supported MCP add/test command
  surface.
- Recorded the complete non-sensitive inventory in a dated audit.

## Decisions
- Configure GitHub MCP only at `/home/cristof/.hermes/config.yaml` through the
  real host CLI; do not configure sandbox paths or forward credentials to Docker.
- Use remote OAuth first, then test discovery and reduce tools before any
  gateway reload.
- Do not reload the gateway until its changed-on-disk unit warning is inspected
  and MCP configuration has passed its connection test.

## Files changed
- `docs/audits/2026-09-18_real-hermes-runtime-inventory.md`
- `.context/STATE.md`
- `.context/TASK.md`
- `.context/DECISIONS.md`
- `.context/handoffs/latest.md`
- `.context/handoffs/2026-09-18_hermes-real-runtime-inventory.md`

## Verification
- Host operator supplied outputs from `hermes --version`, config/env path,
  gateway status, MCP list, profile list and a secret-safe config-key probe.
- Results agree with prior sandbox isolation evidence.

## Risks/problems
- Gateway status reports a changed-on-disk user systemd unit; no reload/restart
  has occurred.
- OAuth completion must happen outside chat. No GitHub token, code or secret has
  been inspected or persisted.

## Remaining work
- Add official GitHub remote MCP with OAuth in the host runtime.
- Test discovery, select minimum toolset, then perform a controlled reload and
  CLI/Telegram read-only probes.

## Recommended next step
Run the exact host `hermes mcp add github ... --auth oauth` command supplied by
Hermes after this handoff, complete authorization outside chat, and return only
its non-sensitive terminal result.
