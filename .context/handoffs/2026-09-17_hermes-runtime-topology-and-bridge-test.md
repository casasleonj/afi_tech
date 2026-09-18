# Hermes Handoff — Runtime Topology and Bridge Test

## Task
Determine whether Hermes itself runs in the Docker terminal sandbox or outside
it before configuring GitHub MCP; execute the first controlled bridge push and
record evidence.

## Result
- Demonstrated topology A: Hermes runs outside the Docker command sandbox.
- Observed host-level `hermes` process PID `8660`; the sandbox cannot execute
  `hermes`, access host PID `8660`, Docker socket or host configuration.
- Ran the first real auto-PR bridge push on
  `agent/auto-pr-bridge-probe-20260917`.
- Branch-push `context-contract` CI succeeded; bridge PR creation failed and
  created zero PRs. The bridge is not operational.

## Decisions
- Do not install GitHub MCP in this sandbox.
- Keep bridge status `TEMPORARY_BRIDGE`, `replacement_required: true`; final
  GitHub delivery stays `NOT_READY`.
- Complete the bridge test only after the repository owner explicitly enables
  the needed Actions setting; then resume the controlled second push.
- Real-host MCP audit/install remains pending a secure host command channel.

## Files changed
- `docs/audits/2026-09-17_hermes-runtime-topology.md`
- `docs/audits/2026-09-17_auto-pr-bridge-test.md`
- `.context/STATE.md`
- `.context/TASK.md`
- `.context/DECISIONS.md`
- `.context/handoffs/latest.md`
- `.context/handoffs/2026-09-17_hermes-runtime-topology-and-bridge-test.md`

## Verification
- Read-only desktop process discovery found host-level Hermes PID `8660`.
- Container mount, process visibility and executable checks verified sandbox
  isolation.
- GitHub public REST API verified zero PRs, one failed auto-PR job and one
  successful context-contract run for the first probe push.

## Risks/problems
- Detailed Actions logs and workflow-permission settings require authenticated
  GitHub API access; they were not inferred.
- No host terminal/SSH channel is currently available, so host configuration
  and Telegram MCP toolset cannot be changed or verified.

## Remaining work
- Repository owner enables the approved Actions setting; repeat second push and
  record idempotence/CI result.
- Obtain real Hermes host access; run the versioned audit, configure official
  GitHub MCP there, and complete final E2E evaluation.

## Recommended next step
Enable the approved GitHub Actions setting, then report completion so the
controlled bridge test can continue without modifying its permissions.
