# GitHub Delivery E2E Evaluation

**Final-capability status:** `NOT_READY` until every gate below is evidenced in
the real Hermes runtime. A passing bridge test changes only bridge status to
`READY_WITH_LIMITATIONS`.

## Bridge controlled test

1. Create a temporary `agent/auto-pr-bridge-probe-*` branch.
2. Push one non-sensitive evidence commit.
3. Verify exactly one open draft PR for `main ← branch`.
4. Make and push a second non-sensitive evidence commit.
5. Verify the same PR remains the only open PR for that branch.
6. Verify `context-contract` runs from the branch-push event.
7. Record whether GitHub also creates a `pull_request` run and whether it
   requires human approval.
8. Inspect workflow source and permissions to prove it cannot merge, approve,
   check out/modify code or access PATs/secrets.

## Final Hermes/MCP E2E test

Run only after auditing the real Hermes runtime and completing the minimal
GitHub MCP setup:

| Gate | Required evidence |
| --- | --- |
| Runtime inventory | Hermes version, execution mode, config path, provider, skills, MCP status, auth mode and Git/GitHub state; values secret-redacted |
| Least privilege | exact enabled MCP tools and identity permissions match `docs/design/GITHUB_DELIVERY_ARCHITECTURE.md` |
| Repository/branch read | Hermes reads target repo and a branch through MCP |
| PR read/write | Hermes creates and retrieves a controlled draft PR |
| CI read | Hermes reads check/status conclusion for that PR |
| Review read | Hermes reads a controlled review/comment |
| Worker loop | OpenCode changes branch; Hermes creates/reads PR; Claude independently reviews; correction push yields a new CI result |
| Merge gate | PROTO-GIT evidence is complete; merge capability remains disabled unless separately authorized |
| Main smoke | after an authorized merge, Hermes verifies declared smoke checks on `main` |
| Recovery | rollback test follows PROTO-GIT without rewriting history |

## Result labels

- `READY`: all final gates pass, reproducible configuration is versioned, and
  the bridge has been removed or justified by measured value.
- `READY_WITH_LIMITATIONS`: bridge is tested but final Hermes integration gates
  remain incomplete.
- `NOT_READY`: bridge test fails or final capability cannot perform its required
  operation.
