# Hermes Handoff — Initial Environment Baseline

## Task
Establish `afi_tech` as the canonical active checkout for the new environment,
persist the governing architecture and execution instructions, correct stale
context snapshots, and add a local validation gate.

## Result
- Cloned the canonical remote into `/workspace/afi_tech` from `main` at
  `01e410394498fa558b219dc4c3fb2a26e72e640d`.
- Created branch `docs/initial-environment-baseline`.
- Persisted the two user-provided authority documents under `docs/architecture/`
  byte-for-byte.
- Reframed repository state, active task, decisions, conventions and README so
  `afi_tech` is explicitly canonical and synchronized with the new environment.
- Replaced the stale exact-HEAD claim in `handoffs/latest.md` with a pure pointer
  model.
- Added a baseline evidence document and local context-validation script plus a
  GitHub Actions workflow definition.
- Kept the authority documents byte-for-byte and documented their narrow
  Markdown whitespace exception in the validation contract.

## Decisions
- `afi_tech` remains the only repository unless a documented need proves
  otherwise; see `.context/DECISIONS.md`.
- No runtime component was installed or configured in this change.
- The authority documents describe target/historical VPS state; current runtime
  claims require dated audit evidence and are not inferred from those documents.
- An unauthenticated public remote cannot establish push, PR, ruleset or Actions
  administration capability. Those remain unknown, not unavailable.

## Files changed
- `README.md`
- `.context/STATE.md`
- `.context/TASK.md`
- `.context/DECISIONS.md`
- `.context/CONVENTIONS.md`
- `.context/handoffs/latest.md`
- `.context/handoffs/2026-09-17_hermes-initial-environment-baseline.md`
- `docs/architecture/HERMES_CONTEXTO_MAESTRO_v3.0.md`
- `docs/architecture/HERMES_INSTRUCCION_MAESTRA_AUTONOMA_v2.0.md`
- `docs/audits/2026-09-17_initial-environment-baseline.md`
- `scripts/verify-context.sh`
- `.github/workflows/context.yml`

## Verification
- Verified anonymous remote resolution with `git ls-remote --symref`.
- Verified initial cloned checkout with `git status --porcelain`,
  `git fsck --no-reflogs --full --strict`, and `git diff --check`.
- Verified both authority documents against their user-provided source files
  using `cmp -s`.
- Local validation and pre-commit review are required before commit.

## Risks/problems
- No GitHub credential or CLI authentication was found. A local commit can be
  created with the repository's existing `hermes <hermes@local>` identity, but
  pushing the branch, opening a PR and observing remote CI require an approved
  authenticated GitHub session.
- The actual runtime target has not been identified from this execution surface;
  no runtime inventory may be inferred from prior environments.

## Remaining work
- Run the validation script, review the full diff, commit the baseline branch,
  and attempt a non-interactive push to establish whether GitHub write access
  exists.
- If write access is unavailable, preserve the local commit and report the
  authentication gate without requesting or handling a secret in chat.
- Inspect Hermes, OpenCode and Claude Code in the actual target environment.

## Recommended next step
Run `bash scripts/verify-context.sh`, complete local review, commit the baseline
change, then verify GitHub write access by pushing the branch.
