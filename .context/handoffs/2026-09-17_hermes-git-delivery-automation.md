# Hermes Handoff — Git Delivery Automation

## Task
Close the verified Git delivery gap: a deploy key could push a branch but could
not create a PR through GitHub's API. Evaluate the official GitHub MCP and
provide a least-privilege path that works from the accessible environment.

## Result
- Installed GitHub CLI version `2.46.0` after user authorization; it has no
  GitHub API login in this environment.
- Generated and verified a repository deploy key, changed the local remote to
  SSH, and pushed `docs/initial-environment-baseline` at `0c300fa`.
- Verified the remote branch resolves to that exact commit.
- Confirmed the official upstream integration is `github/github-mcp-server` and
  that Hermes exposes a reviewed GitHub MCP catalog entry.
- Added a `TEMPORARY_BRIDGE` repository-owned workflow that opens a draft PR on
  only `agent/`, `feature/`, `fix/`, `docs/` or `chore/` pushes, using only
  GitHub's ephemeral workflow token, with per-branch concurrency and
  duplicate-PR recovery.
- Added a local contract verifier and documented the control, evidence,
  limitation, measurement and rollback.

## Decisions
- GitHub MCP is the preferred long-term interactive API integration, but its
  setup is deferred until the active Hermes host—not this Docker execution
  surface—is accessible for OAuth configuration.
- The temporary repository workflow is accepted because it has narrower
  permission than a user PAT and solves the current PR-creation gap. It creates
  drafts only; branch-push CI is the automated validation, while PR-event CI
  can require approval; review and merge remain explicit gates.
- The bridge cannot check out or modify code, approve/review, merge, use
  `pull_request_target`, access a secret/PAT, or operate outside its exact
  branch allowlist. Its removal is mandatory once the real Hermes GitHub
  integration meets the documented validation and comparison gate.

## Files changed
- `.github/workflows/auto-pr.yml`
- `.github/workflows/context.yml`
- `scripts/verify-auto-pr.sh`
- `scripts/test-verify-auto-pr.sh`
- `scripts/probe-hermes-github-runtime.sh`
- `scripts/verify-github-delivery-docs.sh`
- `README.md`
- `.context/STATE.md`
- `.context/TASK.md`
- `.context/DECISIONS.md`
- `.context/CONVENTIONS.md`
- `.context/handoffs/latest.md`
- `.context/handoffs/2026-09-17_hermes-git-delivery-automation.md`
- `docs/audits/2026-09-17_git-delivery-capability.md`
- `docs/design/GITHUB_DELIVERY_ARCHITECTURE.md`
- `docs/protocols/PROTO_GIT.md`
- `docs/evals/GITHUB_DELIVERY_E2E.md`
- `docs/runbooks/HERMES_GITHUB_RUNTIME.md`

## Verification
- `gh --version` returned `2.46.0`; `gh auth status` correctly showed no API
  login.
- GitHub host-key scan was compared against GitHub API metadata before SSH
  authentication.
- SSH authentication identified the deploy key as `casasleonj/afi_tech`.
- `git push -u origin HEAD` succeeded and `git ls-remote` read back `0c300fa`.
- Local workflow contract and context checks remain required before commit.
- Remote auto-PR/CI verification remains pending until the workflow commit is
  pushed.

## Risks/problems
- The accessible container does not include the active Hermes CLI/configuration,
  so an MCP installed here would not become available to the running agent.
- GitHub Actions organization/repository policy could deny workflow token PR
  writes; the remote run is the acceptance test.

## Remaining work
- Validate, commit and push the auto-PR workflow.
- Run a controlled temporary-branch, two-push test. Read back exactly one draft
  PR, its branch-push context-contract CI run, and any approval requirement.
- Configure the official GitHub MCP only when the active Hermes host access and
  OAuth callback path are available.

## Recommended next step
Push this workflow commit. Confirm that it creates one draft PR for the branch
and that the branch-push context-contract workflow completes successfully.
