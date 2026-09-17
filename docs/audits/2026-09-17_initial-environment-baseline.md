# Initial Environment Baseline

**Date:** 2026-09-17
**Scope:** accessible execution surface and canonical repository checkout
**Classification:** verified facts are limited to this environment; the retired environment is not evidence for the new one.

## Interpretation of authority documents

The user-provided architecture and execution documents are stored
byte-for-byte under `docs/architecture/`. Their references to a Hostinger VPS
and partial implementation are preserved as historical/design context. They do
not establish current runtime state; only dated audit evidence does that.

## Verified

- `/workspace` existed and was empty before bootstrap.
- `https://github.com/casasleonj/afi_tech.git` was reachable anonymously.
- The remote default branch resolved to `main` at
  `01e410394498fa558b219dc4c3fb2a26e72e640d`.
- A canonical working checkout was created at `/workspace/afi_tech` from that
  remote, on branch `main` at the same commit.
- Before local work started, `git status --porcelain` was empty,
  `git fsck --no-reflogs --full --strict` succeeded, and `git diff --check`
  produced no output.
- The initial repository had no GitHub Actions workflows in its checkout.
- No global Git identity, credential helper, `GITHUB_TOKEN`, or
  `/root/.git-credentials` was present in the accessible execution surface.

## Unknown

- Whether this accessible execution surface is the final VPS/runtime target.
- Hermes, OpenCode, Claude Code, Docker, systemd, gateway, cron, Graphify,
  Knowledge Vault, Obsidian, VectorDB, GraphDB and Feature Flags status in the
  actual target environment.
- GitHub write, pull-request, branch-protection and Actions-management access.
  Anonymous reachability proves only public read access.

## Decisions

- Treat `afi_tech` as canonical and active, not as a legacy read-only context
  repository.
- Treat the former environment as retired. Do not carry its runtime facts into
  the new environment without a fresh inspection.
- Record authority documents inside `docs/architecture/` byte-for-byte from the
  user-provided sources.
- Exclude only `docs/architecture/` from whitespace validation: the supplied
  Markdown uses intentional hard-break spaces and must retain source fidelity.
- Keep the handoff pointer independent from a mutable exact Git HEAD to avoid
  the stale-pointer failure observed in the prior snapshot.

## Measurements

| Measure | Baseline |
| --- | --- |
| Workspace entries before clone | 0 |
| Canonical checkout | `/workspace/afi_tech` |
| Default branch | `main` |
| Baseline commit | `01e410394498fa558b219dc4c3fb2a26e72e640d` |
| Local CI workflow files before change | 0 |
| Configured GitHub credentials observed | 0 |

## Next gate

Inspect the actual target environment for Hermes, OpenCode and Claude Code.
Do not install or configure a component until its presence, version,
authentication method, service model and reproducibility requirements are known.
