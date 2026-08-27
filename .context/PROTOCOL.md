# Shared Agent Context & Verification Protocol

## 1. Purpose

This protocol defines how Hermes, Claude Code, OpenCode, and Codex collaborate
without unnecessarily transferring conversation history or wasting context
tokens.

The objective is continuity across agents and sessions while preserving
accuracy, traceability, security, and the ability to challenge previous work.

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

## 3. Source of truth

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

## 4. Truthfulness

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

## 5. Evidence hierarchy

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

## 6. Technical and software verification

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

## 7. Research methodology

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

## 8. Industry precedent

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

## 9. Bias and ambiguity elimination

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
ask for clarification rather than silently choosing an interpretation.

## 10. Iterative improvement

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

## 11. Independent multi-agent analysis

Use independent analysis when a problem is complex, consequential, ambiguous,
or benefits from multiple perspectives.

Before comparison, avoid unnecessarily revealing one agents