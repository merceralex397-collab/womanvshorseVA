# Scafforge Process Failures

## Scope

- Maps each validated finding back to the Scafforge-owned workflow surface that allowed it through.

## Failure Map

### WFLOW006

- linked_report_1_finding: WFLOW006
- implicated_surface: repo-scaffold-factory generated workflow, handoff, and tool contract surfaces
- ownership_class: managed workflow contract surface
- workflow_failure: The team leader prompt leaves workflow mechanics underspecified enough that weaker models can thrash or search for bypasses.

## Ownership Classification

### WFLOW006

- ownership_class: managed workflow contract surface
- affected_surface: repo-scaffold-factory generated workflow, handoff, and tool contract surfaces

## Root Cause Analysis

### WFLOW006

- root_cause: Without current transition guidance, acceptance-refresh routing, repair follow-on rules, artifact-ownership rules, and command boundaries, the coordinator has to infer the state machine and may start authoring artifacts, preserving stale ticket truth, or self-asserting repair completion.
- safer_target_pattern: Tell the team leader to route from `ticket_lookup.transition_guidance`, refresh canonical acceptance before reverification when the backlog verifier reports stale ticket truth, require current-cycle repair completion artifacts instead of self-asserted repair follow-on, leave stage artifacts to the owning specialist, and keep slash commands human-only.
- how_the_workflow_allowed_it: The team leader prompt leaves workflow mechanics underspecified enough that weaker models can thrash or search for bypasses.

