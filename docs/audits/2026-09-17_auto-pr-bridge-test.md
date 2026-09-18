# Auto-PR Bridge Controlled Test — Interim Result

**Date:** 2026-09-17
**Branch:** `agent/auto-pr-bridge-probe-20260917`
**Bridge status:** `TEMPORARY_BRIDGE`
**Final capability:** `NOT_READY`

## First push

- Commit pushed: `7b0fe65c0b623ee43fa4fb65f3291f1e0ae31bad`.
- Pre-push open PR count for `main ← branch`: `0`.
- Post-push open PR count: `0`.
- `context-contract` push run succeeded:
  `https://github.com/casasleonj/afi_tech/actions/runs/35274658779`.
- `temporary-bridge-auto-pr` push run failed in its only operational step,
  `Create draft PR when none is open`:
  `https://github.com/casasleonj/afi_tech/actions/runs/35274658904`.

## Evidence and limit

Public GitHub API confirmed the run/job failure, but detailed logs and workflow
permission settings returned HTTP `403`/`401` without an authenticated API
session. The failure cause is therefore **not verified**. A likely cause is the
repository setting that permits `GITHUB_TOKEN` to create PRs; it must be
explicitly confirmed before treating the bridge as operational.

## Test state

After the repository owner enabled the explicitly approved Actions setting, a
new push at `676013f1eb61710eefd2dc54dd5247d56c7edbfa` produced exactly one
Draft PR: [#2](https://github.com/casasleonj/afi_tech/pull/2). The bridge run
`35310090686` succeeded and the branch-push `context-contract` run
`35310090802` succeeded.

GitHub also created a `pull_request` run, `35310099863`, with conclusion
`action_required`. This confirms that GitHub requires human approval for that
PR-triggered run; branch-push CI remains the automated acceptance signal.

The required idempotence check is still pending: the next non-sensitive push
must prove that PR #2 remains the only open PR for this branch.

## Next action

Push a non-sensitive third probe commit, then verify that PR #2 remains the
only Draft PR for the branch and that branch-push CI succeeds again.
