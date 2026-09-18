# Git Delivery Capability Evidence

**Date:** 2026-09-17
**Scope:** `afi_tech` Git delivery capability in the accessible execution surface

## Verified

- GitHub CLI `gh` version `2.46.0` was installed in the accessible execution
  surface after explicit user authorization.
- `gh auth status` reported no authenticated GitHub API session.
- A dedicated ED25519 deploy key was generated locally with private-key mode
  `0600`; only its public component was provided for GitHub configuration.
- GitHub SSH host keys obtained from `ssh-keyscan github.com` matched GitHub's
  published API metadata before authentication was attempted.
- GitHub accepted the deploy key as `casasleonj/afi_tech`.
- The branch `docs/initial-environment-baseline` was pushed and remote read-back
  returned commit `0c300fad330dce1c2074dcb3f057dfee83e41f65`.
- A deploy key can authenticate Git transport but cannot authenticate the
  GitHub REST/GraphQL API used by `gh pr create`.

## Gap

The agent must be able to create PRs and then observe CI without persisting a
personal access token or exposing one in chat. The current Docker execution
surface cannot configure the active Hermes MCP client because it has no
`hermes` CLI/configuration path.

## Control selected — `TEMPORARY_BRIDGE`

`github/github-mcp-server` is the preferred upstream interactive integration
once the active Hermes host is accessible for OAuth. Until then,
`.github/workflows/auto-pr.yml` uses GitHub's ephemeral workflow token with
only `contents: read` and `pull-requests: write` to create a draft PR after an
approved `agent/`, `feature/`, `fix/`, `docs/` or `chore/` branch is pushed.
It cannot merge, approve/review, check out/modify code, manage secrets, use
`pull_request_target`, or change `main`. `dependabot/**` and all unlisted
automated branches are excluded.

## Measurement and acceptance

The control is accepted only when a pushed matching branch produces exactly one
draft PR, the `context-contract` workflow succeeds for that branch push, and no
write occurs outside the branch/PR metadata. A `pull_request` run induced by
`github.token` can require maintainer approval and is not the automated
acceptance signal. Failure is recorded and blocks claiming Git delivery as
operational.

## Rollback

Remove `.github/workflows/auto-pr.yml` by a reviewed PR. The deploy key may be
removed from repository deploy keys by the repository owner; that action is
human-controlled because it changes credentials.

## Retirement condition

Evaluate the official GitHub MCP only inside the real Hermes runtime, with
secure non-interactive authentication (prefer GitHub App or short-lived
credentials), limited toolsets, minimum permissions and read-only/lockdown
configuration where appropriate. It must prove it can create/query PRs, read
CI/status checks and read reviews/comments. Compare those results with this
bridge and remove the Action by reviewed PR if it adds no material value.
