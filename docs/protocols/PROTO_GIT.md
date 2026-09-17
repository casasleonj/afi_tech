# PROTO-GIT — Delivery and Merge Gate

## Scope

This protocol applies to every change that reaches GitHub. Git history and
`main` remain canonical; runtime caches and derived indexes cannot override them.

## Required path

1. Inspect environment and repository state.
2. Create an allowed isolated branch.
3. Implement through the assigned worker; keep scope bounded.
4. Run local validation and record results.
5. Push branch; obtain a draft PR through the bridge or final Hermes integration.
6. Verify CI/status checks and collect non-sensitive evidence.
7. Obtain independent technical review (Claude when available in the real
   runtime; otherwise record the limitation).
8. Correct technical defects on the same branch and repeat validation/CI.
9. Apply merge gate only after required checks and review are satisfied.
10. Merge only through an authorized GitHub path; never force-push or rewrite
    history without explicit approval.
11. Fetch `main`, run declared smoke verification, and persist a handoff,
    decision/state update and evidence.

## Merge gate

A merge is blocked unless all are true:

- PR scope and provenance are understood;
- required local tests and remote status checks are green;
- review findings are resolved or explicitly accepted by an authorized human;
- no secret, permission or policy regression is detected;
- rollback path is documented;
- the actor holds only the permission explicitly required to merge.

No bridge workflow is permitted to merge, approve, submit reviews, or modify
repository code. The final Hermes integration receives no merge tool/permission
until this gate has been separately exercised and approved.

## Rollback

- Before merge: close/revert the PR or delete the work branch only with an
  explicit documented decision.
- After merge: create a new revert PR; do not rewrite `main` history.
- Credential rollback: revoke the GitHub App installation or remove the bridge
  workflow by reviewed PR. Secret rotation/destruction remains human-controlled.

## Evidence

Each delivery records branch, commit IDs, local validation, PR identifier,
remote CI/status, review result, merge decision, post-merge smoke result and
remaining uncertainty. Never record secret values.
