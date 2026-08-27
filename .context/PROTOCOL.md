# Shared Agent Context & Verification Protocol

## 1. Purpose

This protocol defines how Hermes, Claude Code, OpenCode, and Codex collaborate
without unnecessarily transferring conversation history or wasting context
tokens.

The objective is continuity across agents and sessions while preserving
accuracy, traceability, security, and the ability to challenge previous work.

This document is a reference, consulted by section when doing significant work
or when a rule is unclear. It is not required reading in full at the start of
every session; `AGENTS.md` carries the always-on rules and the session
bootstrap list.

The protocol is a methodology, not a substitute for technical security
controls. Sandboxing, permissions, authentication, network restrictions, and
approval mechanisms must enforce security-sensitive constraints where required.

## 2. Context model

Separate three concepts:

### Conversation
Short-lived interaction context. Do not persist complete conversations merely
to preserve continuity.

### Operational context
Current project state required to continue work:
- STATE.md
- TASK.md
- DECISIONS.md
- CONVENTIONS.md
- handoffs/latest.md

### Durable knowledge
Research, architecture knowledge, procedures, and human-facing documentation
that deserves long-term preservation. Obsidian may later serve this role.

Operational context should remain concise. Durable knowledge should not be
copied wholesale into every agent prompt.

## 3. Context integrity and verification

Operational context is only useful if it is trustworthy. Before relying on
`.context/` files or a handoff to act:

- Check that the files being read are internally consistent (STATE.md,
  TASK.md, DECISIONS.md, and handoffs/latest.md do not contradict each other).
- Treat operational context as a claim about project state, not as the state
  itself. Verify it against the actual repository (`git status`, current
  files, current code) when the claim is load-bearing for the task at hand.
- If operational context conflicts with the verified repository state,
  trust the repository (Section 4) and flag the stale context rather than
  silently acting on it.
- If a file appears truncated, corrupted, or edited outside expected
  structure, say so explicitly instead of proceeding as if it were complete.
- Do not treat the mere existence of a file, decision record, or handoff as
  proof of correctness; it is evidence of what a prior agent believed or did,
  subject to the same verification standards as any other source (Section 6).

## 4. Source of truth

Use this hierarchy:

1. Explicit user decisions and requirements.
2. Verified current project/repository state.
3. Authoritative technical or domain sources.
4. Confirmed project decisions and documented conventions.
5. Verified historical/session information.
6. Inferences and hypotheses.

If sources conflict, do not silently select the preferred answer. Identify the
conflict, investigate it, and record the remaining uncertainty when unresolved.

For code, the actual repository and verified runtime behavior take precedence
over stale documentation or agent memory.

## 5. Truthfulness

Never fabricate:
- facts
- sources
- citations
- documentation
- APIs
- commands
- versions
- test results
- benchmarks
- industry practices
- precedents
- tool capabilities
- implementation results

Every substantive claim should be classified implicitly or explicitly as one
of:
- verified fact
- directly observed behavior
- documented behavior
- inference
- assumption
- hypothesis
- estimate
- unknown

Do not turn an inference into a fact merely because it is plausible.

If verification is reasonably possible, verify before making the claim.

## 6. Evidence hierarchy

Prefer:

1. Primary authoritative evidence:
   official documentation, specifications, standards, source code, official
   repositories, official APIs, legislation, regulations, government sources,
   official vendor documentation.

2. Strong secondary evidence:
   peer-reviewed research, recognized technical organizations, professional
   institutions, established engineering publications.

3. Community evidence:
   GitHub issues/discussions, Stack Overflow, Reddit, forums, community
   documentation, practitioner reports.

Community evidence is valuable for discovering real-world behavior, edge cases,
failures, and conventions, but it is not automatically authoritative.

When possible, corroborate important claims using independent evidence.

Do not select sources merely because they support the initial hypothesis.

## 7. Technical and software verification

For a library, framework, API, SDK, CLI, protocol, platform, or infrastructure:

1. Identify the relevant version.
2. Check current official documentation.
3. Check release notes/changelog when version differences may matter.
4. Inspect official source code or repository when documentation is insufficient.
5. Verify the installed environment when practical.
6. Test important commands or behavior when practical.
7. Distinguish documented behavior from experimentally observed behavior.
8. Report version-specific limitations.

Never invent an API because it resembles an API from another tool.

When a command could modify data, infrastructure, credentials, or production,
verify its purpose and scope before execution.

## 8. Research methodology

For consequential research:

1. Define the actual question.
2. Identify assumptions and ambiguities.
3. Search primary sources first.
4. Search independent secondary sources where useful.
5. Search community/practitioner evidence for real-world behavior.
6. Investigate competing approaches.
7. Deliberately search for evidence that could disprove the initial hypothesis.
8. Identify limitations, costs, risks, failure modes, and edge cases.
9. Compare evidence.
10. Produce a conclusion with confidence and remaining uncertainty.
11. Preserve material evidence and reasoning in structured form.

Do not stop at the first plausible answer.

## 9. Industry precedent

When deciding architecture, operations, governance, security, business processes,
or other consequential matters:

Investigate how recognized organizations and established practitioners solve
comparable problems in the relevant domain.

Depending on the domain, relevant precedents may include major vendors or
organizations such as SAP, Microsoft, Google, AWS, IBM, Oracle, or equivalent
leaders.

Use precedent as evidence, not authority.

For each important precedent ask:
- Is the problem genuinely comparable?
- What constraints existed?
- Why was the approach selected?
- What trade-offs exist?
- What failure modes are known?
- Does the same reasoning apply to this project?

Never copy an enterprise architecture merely because a large company uses it.
A large or recognized organization's practice is one data point, not proof of
correctness, and it must clear the same comparability and trade-off questions
as any other precedent.

## 10. Bias and ambiguity elimination

Every significant result must be deliberately challenged.

Search for:
- unsupported assumptions
- confirmation bias
- selection bias
- authority bias
- ambiguous terminology
- ambiguous requirements
- contradictory evidence
- missing alternatives
- hidden dependencies
- overlooked costs
- security weaknesses
- operational failure modes
- unnecessary complexity

When ambiguity materially affects the outcome, resolve it through evidence or
ask for clarification rather than silently choosing an interpretation. Record
how it was resolved (evidence used, or who clarified it) so the same ambiguity
is not silently re-resolved differently later.

## 11. Iterative improvement

For significant work:

Iteration 1:
- produce the best supported result.

Review:
- attack the result as a skeptical reviewer;
- identify weaknesses and missing evidence.

Iteration 2:
- improve the result based on the review.

Repeat:
- deliberately search for additional relevant improvements.

Stopping condition:
"No relevant improvement found after deliberate critical review."

This is not a fixed number of iterations. Do not repeat mechanically merely to
consume tokens.

A result may still contain uncertainty. "No relevant improvement found" does
not mean "certain" or "perfect."

## 12. Independent multi-agent analysis

Use independent analysis when a problem is complex, consequential, ambiguous,
or benefits from multiple perspectives.

Before comparison, avoid unnecessarily revealing one agent's conclusions,
reasoning, or intermediate results to another agent that is meant to produce
an independent view — premature sharing collapses independence and turns a
second opinion into an echo of the first.

Process:
1. Give each participating agent the same question, task, or evidence.
2. Each agent works from that shared input without seeing another agent's
   in-progress reasoning or conclusion.
3. Each agent records its own conclusion together with the evidence and
   reasoning behind it, classified per Section 5.
4. Only after independent results exist should they be compared (Section 13).

Independent analysis is not required for routine, low-consequence, or
unambiguous work; use judgment about when the extra tokens are justified.

## 13. Convergence

- Compare independent results on their conclusions and underlying reasoning,
  not merely on final wording.
- Investigate the evidence and assumptions behind each point of agreement
  before treating it as confirmed — do not assume agreement implies the
  reasoning was independent or correct.
- Treat convergence as increased confidence, not proof. Independent agents can
  share the same blind spot, the same stale source, or the same bias.
- Never manufacture consensus by silently discarding a dissenting result,
  averaging incompatible conclusions, or rephrasing disagreement away.
- A converged result still passes through critical iteration (Section 11)
  before being treated as final.

## 14. Disagreement handling

- When independent analyses disagree, first identify whether the cause is
  different evidence, different assumptions, different scope, or an actual
  error in one analysis.
- Investigate the disagreement using the evidence hierarchy (Section 6) and,
  where relevant, precedent research (Section 9) before selecting a side.
- Do not resolve disagreement by seniority, agent identity, model, or majority
  vote alone; resolve it with evidence and reasoning.
- If the disagreement cannot be resolved with available evidence, present both
  positions with their supporting evidence and confidence levels, and record
  the disagreement as unresolved rather than picking one arbitrarily.
- Record material disagreements in DECISIONS.md or a handoff so a later agent
  does not silently re-diverge or assume the disagreement was already settled.

## 15. Handoffs

After significant work, add a dated handoff file under `.context/handoffs/`
(naming per CONVENTIONS.md) and update `.context/handoffs/latest.md` to point to
it. Handoff files are immutable; `latest.md` is only a pointer. Each handoff
file contains:

- **Task**: what was requested.
- **Result**: what was produced or changed.
- **Decisions**: what was decided and why, referencing DECISIONS.md rather
  than restating it when already recorded there.
- **Files changed**: concrete paths.
- **Verification**: what was checked and how (commands run, tests executed,
  documentation consulted, environment verified).
- **Risks/problems**: known issues, limitations, side effects.
- **Remaining work**: what is not done.
- **Recommended next step**: a concrete next action.

Traceability requirement: a handoff must let a later agent reconstruct
important conclusions from evidence, reasoning, alternatives considered,
verification performed, and remaining uncertainty — without replaying the full
conversation. Link to `.context/research/` or `DECISIONS.md` for supporting
detail instead of duplicating it inline.

Keep handoffs concise; they are operational context (Section 2), not
conversation transcripts.

## 16. Session continuity

- At the start of a session or task, read STATE.md, TASK.md, DECISIONS.md,
  CONVENTIONS.md, and handoffs/latest.md before acting.
- Treat this operational context as the current understanding of project
  state, subject to the integrity check in Section 3 — verify it against the
  repository when the task depends on it being accurate.
- Do not assume a prior session's unresolved uncertainty or disagreement
  (Section 14) was resolved simply because time has passed; check
  DECISIONS.md and handoffs for an explicit resolution.
- Update STATE.md, TASK.md, DECISIONS.md, and handoffs/latest.md when they no
  longer reflect reality. Operational context that is stale but trusted is
  more harmful than context that is simply absent.

## 17. Token efficiency

- Read the minimum context required to act correctly (AGENTS.md, Section 2).
- Prefer structured operational context over full conversation transcripts;
  do not transfer complete conversations when structured context is
  sufficient.
- Do not copy durable knowledge (research, architecture documents) wholesale
  into every agent prompt; reference it and let the receiving agent read it
  only if needed.
- Summarize before transferring when a full document is not required for the
  next step.
- Efficiency must never come at the cost of skipping required verification,
  evidence gathering, or critical iteration. A cheaper wrong answer is not
  efficient; it produces rework.

## 18. Memory limits

- Keep operational context files structured and compact (CONVENTIONS.md);
  they are meant to be read in full at the start of a session.
- When a file grows beyond what current continuity needs, move resolved or
  historical material into `.context/research/` or a dated handoff file
  rather than deleting the evidence outright, or summarize and archive it.
- Do not persist full conversation transcripts in any context or memory file
  (Section 2); persist conclusions, decisions, and pointers to evidence
  instead.
- Never persist credentials, tokens, or other secrets in any context or
  memory file, regardless of size constraints (Section 19).

## 19. Security

- Never persist credentials, tokens, private keys, passwords, or other
  secrets in `.context/`, handoffs, decision records, or any file committed
  to the repository.
- Before staging or committing, check for accidental inclusion of secrets,
  including in files that look unrelated to credentials.
- Work within the project repository unless explicitly authorized to act
  outside it.
- This protocol is a methodology, not a security control (Section 1); rely on
  sandboxing, permissions, authentication, network restrictions, and approval
  mechanisms for actual enforcement.
- Verify the purpose and scope of a command before executing it if it could
  modify data, infrastructure, credentials, or production (Section 7).
- Never rewrite git history or force-push without explicit authorization.
- Keep commits focused and descriptive.

## 20. Completion criteria

Work is complete only when all of the following hold:

- The result has been verified against the applicable sections above
  (source of truth, evidence hierarchy, technical/software verification,
  research methodology) rather than presented on first plausible draft.
- The result has been through at least one deliberate critical review
  (Section 11) that found no further relevant improvement.
- Where independent analyses were used, convergence and disagreement have
  been assessed (Sections 13–14) rather than silently merged.
- Material uncertainty and unresolved disagreement are explicitly reported,
  not hidden or smoothed over.
- A handoff exists for significant work (Section 15).

A plausible first result is not sufficient for significant work.
"No relevant improvement found" is a stopping condition, not a claim of
certainty or perfection.
