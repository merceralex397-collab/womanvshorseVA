# Scafforge Process Failures

## Scope

- Maps each validated finding back to the Scafforge-owned workflow surface that allowed it through.

## Failure Map

### EXEC-GODOT-006

- linked_report_1_finding: EXEC-GODOT-006
- implicated_surface: repo-scaffold-factory managed template surfaces
- ownership_class: generated repo execution surface
- workflow_failure: Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence.

### EXEC-GODOT-009

- linked_report_1_finding: EXEC-GODOT-009
- implicated_surface: generated repo implementation and validation surfaces
- ownership_class: generated repo execution surface
- workflow_failure: GDScript calls APIs that are unavailable on the script's declared base type.

### EXEC-REMED-001

- linked_report_1_finding: EXEC-REMED-001
- implicated_surface: repo-scaffold-factory managed template surfaces
- ownership_class: generated repo execution surface
- workflow_failure: Remediation review artifact does not contain runnable command evidence.

### FINISH004

- linked_report_1_finding: FINISH004
- implicated_surface: ticket-pack-builder and ticket contract surfaces
- ownership_class: managed workflow contract surface
- workflow_failure: Interactive consumer-facing repo still relies on a weak generic finish bar instead of explicit interaction-proof requirements.

### WFLOW026

- linked_report_1_finding: WFLOW026
- implicated_surface: repo-scaffold-factory generated workflow, handoff, and tool contract surfaces
- ownership_class: managed workflow contract surface
- workflow_failure: Current artifacts contain explicit verdict headings or labels, but the generated verdict extractor still reports them as unclear.

## Ownership Classification

### EXEC-GODOT-006

- ownership_class: generated repo execution surface
- affected_surface: repo-scaffold-factory managed template surfaces

### EXEC-GODOT-009

- ownership_class: generated repo execution surface
- affected_surface: generated repo implementation and validation surfaces

### EXEC-REMED-001

- ownership_class: generated repo execution surface
- affected_surface: repo-scaffold-factory managed template surfaces

### FINISH004

- ownership_class: managed workflow contract surface
- affected_surface: ticket-pack-builder and ticket contract surfaces

### WFLOW026

- ownership_class: managed workflow contract surface
- affected_surface: repo-scaffold-factory generated workflow, handoff, and tool contract surfaces

## Root Cause Analysis

### EXEC-GODOT-006

- root_cause: The repo is treating a contradictory smoke artifact as release proof. A Godot export or release-validation run can record parse/script-load failures or command-level failure markers while the artifact still says PASS, which lets a broken runtime state look releasable.
- safer_target_pattern: Make smoke_test fail when Godot export/load output contains parse or script-load errors, and reject PASS smoke artifacts whose command blocks record non-zero exit codes or non-`none` failure classifications before release closeout.
- how_the_workflow_allowed_it: Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence.

### EXEC-GODOT-009

- root_cause: The audit found script methods that only exist on CanvasItem-style nodes being called from scripts that extend incompatible bases such as Node or CanvasLayer, which guarantees runtime parse/load failure even before gameplay starts.
- safer_target_pattern: Validate GDScript method calls against the declared base type and move draw/redraw or viewport-rect logic onto compatible CanvasItem-derived nodes before treating headless load as trustworthy.
- how_the_workflow_allowed_it: GDScript calls APIs that are unavailable on the script's declared base type.

### EXEC-REMED-001

- root_cause: A ticket created from a validated finding is being reviewed on prose alone, so the audit cannot confirm that the original failing command or canonical acceptance command was actually rerun after the fix.
- safer_target_pattern: For remediation tickets with `finding_source`, require the review artifact to record the exact command run, include raw command output, and state the explicit PASS/FAIL result before the review counts as trustworthy closure.
- how_the_workflow_allowed_it: Remediation review artifact does not contain runnable command evidence.

### FINISH004

- root_cause: Older Scafforge-generated finish contracts and finish-validation tickets could prove only that a build exists, not that the shipped interaction loop and visible user-facing state were actually demonstrated. That leaves low-quality interactive products able to look complete through generic prose.
- safer_target_pattern: Replace generic machine-generated finish_acceptance_signals with repo-specific interactive proof requirements, and require FINISH-VALIDATE-001 to demand user-observable interaction evidence in addition to load/export proof.
- how_the_workflow_allowed_it: Interactive consumer-facing repo still relies on a weak generic finish bar instead of explicit interaction-proof requirements.

### WFLOW026

- root_cause: The repo-local workflow parser does not cover the real artifact verdict forms already present in downstream review and QA artifacts, including markdown-emphasized labels, compact stage headings such as `## QA PASS`, and plain `**Overall**: PASS` labels. Those explicit verdicts then look unparseable and block review or QA transitions even though the artifact body is clear.
- safer_target_pattern: Keep one shared artifact verdict extractor that accepts the real artifact family in use: plain and markdown-emphasized verdict labels, compact `QA/Review + verdict` headings, and `Overall: PASS/FAIL` labels. Route ticket_lookup and ticket_update through that shared parser instead of treating explicit review or QA verdicts as unclear.
- how_the_workflow_allowed_it: Current artifacts contain explicit verdict headings or labels, but the generated verdict extractor still reports them as unclear.

