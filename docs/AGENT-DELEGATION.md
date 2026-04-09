# Agent Delegation

This document is the human-readable delegation map for the generated OpenCode team.
`opencode-team-bootstrap` must refresh it so it matches the actual agent files in `.opencode/agents/` for this repo.

## Team Composition

- visible coordinator: `wvhva-team-leader`
- planning lane: `wvhva-planner` and `wvhva-plan-review`
- implementation lane: `wvhva-lane-executor` and `wvhva-implementer`
- review lane: `wvhva-reviewer-code` and `wvhva-reviewer-security`
- QA lane: `wvhva-tester-qa`
- closeout lane: `wvhva-docs-handoff`
- trust-restoration lane: `wvhva-backlog-verifier` and `wvhva-ticket-creator`

## Delegation Chain

1. `wvhva-team-leader` resolves canonical state with `ticket_lookup`
2. `wvhva-planner` writes the planning artifact
3. `wvhva-plan-review` approves or rejects the plan
4. `wvhva-lane-executor` or `wvhva-implementer` performs the approved implementation lane
5. `wvhva-reviewer-code` and `wvhva-reviewer-security` return findings or approval evidence
6. `wvhva-tester-qa` runs QA and returns the QA artifact
7. `wvhva-team-leader` runs `smoke_test`, advances lifecycle state, and routes closeout
8. `wvhva-docs-handoff` synchronizes restart surfaces when closeout is ready

## Ownership Rules

- only the team leader advances ticket lifecycle state
- only the owning specialist or tool writes the stage artifact body
- read-only specialists return findings, blockers, or evidence; they do not mutate repo-tracked files
- write-capable specialists work only inside a claimed lease and only for the bounded lane they were assigned

## Escalation Path

Stop and escalate to the operator when:

- canonical workflow tools disagree and the contradiction rules in the team-leader prompt do not resolve the conflict
- `environment_bootstrap` still reports unresolved blockers after safe recovery commands were attempted
- the same ticket advance fails three times with the same blocker or error signature
- a dependency ticket is blocked and prevents the active ticket from moving
- no single legal next move can be resolved from `ticket_lookup.transition_guidance` and the canonical artifacts

## Restart Procedure

1. read `START-HERE.md`
2. read `docs/spec/CANONICAL-BRIEF.md` and `docs/process/workflow.md` when the current state is unclear
3. run `ticket_lookup` for the active ticket
4. trust `tickets/manifest.json` and `.opencode/state/workflow-state.json` over derived restart surfaces
5. resume from the next required stage instead of improvising a new delegation path