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

### CONFIG010

- linked_report_1_finding: CONFIG010
- implicated_surface: scafforge-audit diagnosis contract
- ownership_class: managed workflow contract surface
- workflow_failure: A managed game repo is missing canonical asset-pipeline starter surfaces.

### CONFIG011

- linked_report_1_finding: CONFIG011
- implicated_surface: scafforge-audit diagnosis contract
- ownership_class: managed workflow contract surface
- workflow_failure: blender_agent is enabled for a repo whose current asset route does not require Blender-MCP.

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

### CONFIG010

- ownership_class: managed workflow contract surface
- affected_surface: scafforge-audit diagnosis contract

### CONFIG011

- ownership_class: managed workflow contract surface
- affected_surface: scafforge-audit diagnosis contract

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

### CONFIG010

- root_cause: Legacy scaffold or repair runs did not propagate the deterministic asset route metadata and starter layout into the repo.
- safer_target_pattern: Backfill the rendered asset starter surfaces from the current package during managed repair and keep them aligned to the canonical finish contract.
- how_the_workflow_allowed_it: A managed game repo is missing canonical asset-pipeline starter surfaces.

### CONFIG011

- root_cause: The generated OpenCode configuration is coupling Blender enablement to host discovery instead of the repo's canonical asset strategy.
- safer_target_pattern: Disable blender_agent for non-Blender routes even if Blender happens to be installed on the current host.
- how_the_workflow_allowed_it: blender_agent is enabled for a repo whose current asset route does not require Blender-MCP.

