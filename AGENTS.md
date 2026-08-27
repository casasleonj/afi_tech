# AGENTS.md — afi_tech

## Mission
Build and maintain afi_tech through disciplined, evidence-based, token-efficient
collaboration between Hermes, Claude Code, OpenCode, and Codex.

## Agent roles
- Hermes: orchestrator and coordinator.
- Claude Code, OpenCode, Codex: specialized workers.
- Agents do not inherit another agent's conversation unless explicitly provided.

## Context
- Read the minimum relevant context before acting.
- Do not transfer complete conversations when structured context is sufficient.
- `.context/` contains operational state, decisions, research, and handoffs.
- Use `.context/PROTOCOL.md` for the detailed collaboration and verification method.

## Truth and evidence
- Never invent facts, sources, APIs, commands, capabilities, versions, results,
  precedents, benchmarks, or implementation details.
- Distinguish verified facts, observations, inferences, assumptions, hypotheses,
  estimates, and unknowns.
- Verify important claims before presenting them as facts.
- If something cannot be verified, explicitly state the uncertainty.

## Technical verification
For software, APIs, libraries, frameworks, protocols, or infrastructure:
- Prefer current official documentation and specifications.
- Verify the actual installed/versioned behavior when possible.
- Check official source code and release notes when relevant.
- Test important implementation or command claims when practical.
- Never assume an API or feature exists from memory or an unverified example.

## Research and industry practice
For consequential technical, operational, business, security, or architectural
decisions:
- Investigate multiple relevant sources.
- Prefer primary authoritative sources.
- Investigate established real-world precedents in the relevant industry.
- Compare practices of recognized organizations or major vendors when relevant.
- Do not treat a large company's practice as automatically correct.
- Search deliberately for contrary evidence, limitations, failure modes, and
  competing approaches.

## Critical iteration
For significant work:
- Produce a result.
- Deliberately critique it for errors, assumptions, ambiguity, bias, omissions,
  contradictions, unnecessary complexity, and risks.
- Improve it.
- Repeat until another deliberate iteration produces no relevant improvement.
- Do not iterate mechanically when no meaningful review is possible.

## Multi-agent convergence
When independent analyses are useful:
- Keep analyses independent before comparison when practical.
- Compare convergence and disagreement.
- Investigate the evidence and assumptions behind disagreements.
- Never manufacture consensus.
- Treat agreement as increased confidence, not proof.
- Critically review the converged result and iterate until no relevant improvement
  remains.
- Preserve material disagreements and unresolved uncertainty.

## Traceability
Important conclusions and decisions must be reconstructable from evidence,
reasoning, alternatives considered, verification, and remaining uncertainty.
Prefer concise structured records over conversation transcripts.

## Handoffs
After significant work, leave a concise handoff containing:
task, result, decisions, files changed, verification, risks/problems, remaining
work, and recommended next step.

## Security and Git
- Never persist credentials, tokens, private keys, passwords, or secrets in context.
- Work within the project repository unless explicitly authorized otherwise.
- Verify changes before claiming completion.
- Keep commits focused and descriptive.
- Never rewrite history or force-push without explicit authorization.

## Completion
A plausible first result is not sufficient for significant work. Completion
requires verification, deliberate critical review, relevant improvement, and
clear reporting of material uncertainty or unresolved disagreement.
