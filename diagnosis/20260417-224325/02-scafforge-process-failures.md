# Scafforge Process Failures

## Scope

- Maps each validated finding back to the Scafforge-owned workflow surface that allowed it through.

## Failure Map

### WFLOW030

- linked_report_1_finding: WFLOW030
- implicated_surface: repo-scaffold-factory generated workflow, handoff, and tool contract surfaces
- ownership_class: managed workflow contract surface
- workflow_failure: Repo is in managed_blocked deadlock: all unresolved required follow-on stages are host-only, so the local agent has zero legal moves.

## Ownership Classification

### WFLOW030

- ownership_class: managed workflow contract surface
- affected_surface: repo-scaffold-factory generated workflow, handoff, and tool contract surfaces

## Root Cause Analysis

### WFLOW030

- root_cause: The repair cycle left managed_blocked active with only host-only required stages (project-skill-bootstrap, opencode-team-bootstrap, or agent-prompt-engineering) still incomplete, while ticket_update.ts blocks ALL ticket lifecycle mutations when managed_blocked is set. The local agent cannot complete host-only stages and cannot advance any ticket. This is a direct violation of the Scafforge contract: the repo must always expose one legal next move with one named owner.
- safer_target_pattern: Host-operator must: (1) run the required host-only stages (project-skill-bootstrap via Scafforge), (2) update repair_follow_on.completed_stages in workflow-state.json, and (3) set outcome to 'clean' or 'source_follow_up' once all stages are done. After that the local agent regains ticket mutation access.
- how_the_workflow_allowed_it: Repo is in managed_blocked deadlock: all unresolved required follow-on stages are host-only, so the local agent has zero legal moves.

