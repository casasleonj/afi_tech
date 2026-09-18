# Hermes Handoff — Bridge Ready With Limitations

## Task
Complete the controlled GitHub Actions bridge test after the repository owner
enabled the required workflow setting; verify draft PR creation, idempotence and
CI behavior.

## Result
- The first pre-setting push failed to create a PR; this was recorded without
  inferring the inaccessible error detail.
- After the approved setting change, push `676013f` created exactly one Draft
  PR: [#2](https://github.com/casasleonj/afi_tech/pull/2).
- A reuse push at `1618401` retained exactly that one Draft PR and updated its
  head; no duplicate PR was created.
- Auto-PR and branch-push context CI succeeded for the reuse push.
- The PR-event context CI run concluded `action_required`, confirming human
  approval is required for that event. Branch-push CI is the automated signal.

## Decisions
- Bridge state is `READY_WITH_LIMITATIONS` and remains `TEMPORARY_BRIDGE` with
  `replacement_required: true`.
- Final Hermes-to-GitHub integration remains `NOT_READY`; bridge success cannot
  satisfy direct MCP, CI-read, review-read or PROTO-GIT E2E requirements.

## Files changed
- `docs/audits/2026-09-17_auto-pr-bridge-test.md`
- `.context/STATE.md`
- `.context/TASK.md`
- `.context/DECISIONS.md`
- `.context/handoffs/latest.md`
- `.context/handoffs/2026-09-17_hermes-bridge-ready-with-limitations.md`

## Verification
- GitHub public API read back exactly one open Draft PR #2 after the reuse push.
- Auto-PR run `35310163639` and branch-push context CI run `35310163674` both
  concluded `success` on commit `1618401`.
- Local context and bridge policy validation remain green.

## Risks/problems
- GitHub workflow permission settings and detailed Action logs still require an
  authenticated API identity to inspect directly.
- The real Hermes host has no exposed terminal/configuration channel from this
  session. No MCP installation was attempted in the sandbox.

## Remaining work
- Establish safe access to the real Hermes runtime; audit and install/test the
  official GitHub MCP there according to the versioned runbook and E2E gates.
- Compare MCP against bridge and remove bridge only if it no longer adds value.

## Recommended next step
Obtain host terminal/SSH access or reconfigure Hermes terminal execution so the
real `hermes` CLI and its `HERMES_HOME` can be audited without exposing secrets.
