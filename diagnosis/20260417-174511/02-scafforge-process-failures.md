# Scafforge Process Failures

## Scope

- Maps each validated finding back to the Scafforge-owned workflow surface that allowed it through.

## Failure Map

### EXEC-GODOT-006

- linked_report_1_finding: EXEC-GODOT-006
- implicated_surface: repo-scaffold-factory managed template surfaces
- ownership_class: generated repo execution surface
- workflow_failure: Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence.

## Ownership Classification

### EXEC-GODOT-006

- ownership_class: generated repo execution surface
- affected_surface: repo-scaffold-factory managed template surfaces

## Root Cause Analysis

### EXEC-GODOT-006

- root_cause: The repo is treating a contradictory smoke artifact as release proof. A Godot export or release-validation run can record parse/script-load failures or command-level failure markers while the artifact still says PASS, which lets a broken runtime state look releasable.
- safer_target_pattern: Make smoke_test fail when Godot export/load output contains parse or script-load errors, and reject PASS smoke artifacts whose command blocks record non-zero exit codes or non-`none` failure classifications before release closeout.
- how_the_workflow_allowed_it: Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence.

