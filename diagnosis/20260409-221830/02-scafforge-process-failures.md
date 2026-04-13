# Scafforge Process Failures

## Scope

- Maps each validated finding back to the Scafforge-owned workflow surface that allowed it through.

## Failure Map

### EXEC-GODOT-004

- linked_report_1_finding: EXEC-GODOT-004
- implicated_surface: generated repo implementation and validation surfaces
- ownership_class: generated repo execution surface
- workflow_failure: Godot headless validation fails.

### SKILL001

- linked_report_1_finding: SKILL001
- implicated_surface: project-skill-bootstrap and agent-prompt-engineering surfaces
- ownership_class: project skill or prompt surface
- workflow_failure: One or more repo-local skills still contain generic placeholder text instead of project-specific guidance.

## Ownership Classification

### EXEC-GODOT-004

- ownership_class: generated repo execution surface
- affected_surface: generated repo implementation and validation surfaces

### SKILL001

- ownership_class: project skill or prompt surface
- affected_surface: project-skill-bootstrap and agent-prompt-engineering surfaces

## Root Cause Analysis

### EXEC-GODOT-004

- root_cause: The project cannot complete a deterministic headless Godot load pass on the current host, indicating broken project configuration or scripts.
- safer_target_pattern: Run a deterministic `godot --headless --path . --quit` validation during audit and keep the repo blocked until it succeeds or returns an explicit environment blocker instead.
- how_the_workflow_allowed_it: Godot headless validation fails.

### SKILL001

- root_cause: project-skill-bootstrap or later managed-surface repair left baseline local skills in a scaffold placeholder state, so agents lose concrete stack and validation guidance.
- safer_target_pattern: Populate every baseline local skill with concrete repo-specific rules and validation commands; generated `.opencode/skills/` files must not retain template filler.
- how_the_workflow_allowed_it: One or more repo-local skills still contain generic placeholder text instead of project-specific guidance.

