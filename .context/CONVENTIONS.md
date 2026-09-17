# Context Conventions

## Language
- Field keys / headings in handoffs, decisions, and research: English, matching
  `PROTOCOL.md` §15 (Task, Result, Decisions, Files changed, Verification,
  Risks/problems, Remaining work, Recommended next step).
- Body prose may be Spanish. Keep it concise and structured — no narrative.

## Files
- Keep `AGENTS.md` and the operational snapshot small and high-signal.
- No conversation transcripts in any tracked file.
- Never persist credentials or secrets.
- Record important decisions in `DECISIONS.md` with their rationale, including
  options that were deliberately rejected.
- Distinguish verified facts from inference and uncertainty.

## Handoffs
- One file per significant unit of work:
  `.context/handoffs/YYYY-MM-DD_<agent>-<slug>.md`
  (e.g. `2026-08-27_opencode-prueba-comunicacion.md`).
- Handoff files are immutable once written. Correct a handoff with a new
  handoff, not by editing the old one.
- Each handoff file contains all eight `PROTOCOL.md` §15 fields.
- `handoffs/latest.md` is a mutable pointer to the newest handoff: its filename,
  a one-line status, and the next step. It never claims a mutable exact Git HEAD,
  is never a historical record, and is never the only copy of a handoff.

## Environment evidence
- Record non-secret inspection evidence in a dated `docs/audits/` file or an
  immutable handoff. Mark every material statement as verified, inferred, or
  unknown.
- For significant work, preserve the closed delivery cycle: inspect →
  implement/configure → test → measure → persist → Git/PR/CI.
- A reproducibility script must have no undeclared runtime dependencies and must
  be runnable locally before it is proposed for CI.
- `docs/architecture/` contains byte-for-byte user-provided authority documents.
  Its Markdown hard-break whitespace is an explicit, narrow exception to
  `git diff --check`; the validation script excludes only this path.

## Ownership
- Hermes owns the mutable snapshot: `STATE.md`, `TASK.md`, `DECISIONS.md`,
  `CONVENTIONS.md`. Workers propose changes to these in their handoff rather
  than rewriting them.
- Any agent that writes a handoff also updates `handoffs/latest.md` to point to
  it (new pointer block + a line prepended to the list). This is the one
  snapshot file a worker edits directly.
- Workers otherwise only add new immutable files (handoffs, research).
- Workers may directly edit ordinary project documentation such as `README.md`,
  provided the change is small, within the current task scope, and recorded in
  the handoff. Hermes retains ownership of the mutable snapshot files above.
- Git is the single source of truth. Resolve any file-vs-repo conflict in favor
  of the repo and flag the stale file rather than acting on it silently.
