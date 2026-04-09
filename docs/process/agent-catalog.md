# Agent Catalog

Prefix: `wvhva`

Visible entrypoint:

- `wvhva-team-leader`

Core hidden specialists:

- `wvhva-planner`
- `wvhva-plan-review`
- `wvhva-implementer`
- `wvhva-reviewer-code`
- `wvhva-reviewer-security`
- `wvhva-tester-qa`
- `wvhva-docs-handoff`
- `wvhva-backlog-verifier`
- `wvhva-ticket-creator`

Utility hidden specialists:

- `wvhva-utility-explore`
- `wvhva-utility-shell-inspect`
- `wvhva-utility-summarize`
- `wvhva-utility-ticket-audit`
- `wvhva-utility-github-research`
- `wvhva-utility-web-research`

Workflow contract:

- the team leader advances stages through ticket tools and workflow state, not by manually editing ticket files
- each major stage must leave a canonical artifact before the next stage begins
- read-only specialists return findings, artifacts, or blockers instead of mutating repo files
- per-ticket stage order stays sequential, and the repo defaults to one active lane unless bounded parallel work is explicitly justified
- the backlog verifier reads canonical artifact bodies through `ticket_lookup` before deciding whether old completion still holds
- the team leader runs the deterministic `smoke_test` tool between QA and closeout instead of delegating that stage to another agent
- post-migration, remediation, or reverification follow-up tickets are created only from current registered evidence through the guarded ticket flow
