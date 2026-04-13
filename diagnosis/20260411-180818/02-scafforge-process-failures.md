# Scafforge Process Failures

## Scope

- Maps each validated finding back to the Scafforge-owned workflow surface that allowed it through.

## Failure Map

### EXEC-REMED-001

- linked_report_1_finding: EXEC-REMED-001
- implicated_surface: repo-scaffold-factory managed template surfaces
- ownership_class: generated repo execution surface
- workflow_failure: Remediation review artifact does not contain runnable command evidence.

### WFLOW019

- linked_report_1_finding: WFLOW019
- implicated_surface: repo-scaffold-factory generated workflow, handoff, and tool contract surfaces
- ownership_class: managed workflow contract surface
- workflow_failure: The ticket graph contains stale or contradictory source/follow-up linkage.

## Ownership Classification

### EXEC-REMED-001

- ownership_class: generated repo execution surface
- affected_surface: repo-scaffold-factory managed template surfaces

### WFLOW019

- ownership_class: managed workflow contract surface
- affected_surface: repo-scaffold-factory generated workflow, handoff, and tool contract surfaces

## Root Cause Analysis

### EXEC-REMED-001

- root_cause: A ticket created from a validated finding is being reviewed on prose alone, so the audit cannot confirm that the original failing command or canonical acceptance command was actually rerun after the fix.
- safer_target_pattern: For remediation tickets with `finding_source`, require the review artifact to record the exact command run, include raw command output, and state the explicit PASS/FAIL result before the review counts as trustworthy closure.
- how_the_workflow_allowed_it: Remediation review artifact does not contain runnable command evidence.

### WFLOW019

- root_cause: The repo has follow-up tickets whose lineage, dependency edges, or parent linkage no longer agree with the current manifest. Without a canonical reconciliation path, agents get trapped between stale source-follow-up history and current evidence.
- safer_target_pattern: Use `ticket_reconcile` to atomically repair stale source/follow-up linkage, remove contradictory parent dependencies, and supersede invalidated follow-up tickets from current evidence.
- how_the_workflow_allowed_it: The ticket graph contains stale or contradictory source/follow-up linkage.

