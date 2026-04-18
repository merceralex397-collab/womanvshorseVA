# Scafforge Process Failures

## Scope

- Maps each validated finding back to the Scafforge-owned workflow surface that allowed it through.

## Failure Map

### BOOT003

- linked_report_1_finding: BOOT003
- implicated_surface: managed bootstrap tool and bootstrap-facing workflow guidance
- ownership_class: generated repo source and configuration surfaces
- workflow_failure: The generated bootstrap freshness contract cannot detect host drift for this repo.

### EXEC-GODOT-006

- linked_report_1_finding: EXEC-GODOT-006
- implicated_surface: repo-scaffold-factory managed template surfaces
- ownership_class: generated repo execution surface
- workflow_failure: Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence.

### EXEC-REMED-001

- linked_report_1_finding: EXEC-REMED-001
- implicated_surface: repo-scaffold-factory managed template surfaces
- ownership_class: generated repo execution surface
- workflow_failure: Remediation review artifact does not contain runnable command evidence.

### EXEC-REMED-001

- linked_report_1_finding: EXEC-REMED-001
- implicated_surface: repo-scaffold-factory managed template surfaces
- ownership_class: generated repo execution surface
- workflow_failure: Remediation review artifact does not contain runnable command evidence.

### FINISH002

- linked_report_1_finding: FINISH002
- implicated_surface: scafforge-audit diagnosis contract
- ownership_class: managed workflow contract surface
- workflow_failure: Repo claims ready or finished state, but the finish contract forbids placeholder output and finish-owning tickets are still open.

### FINISH004

- linked_report_1_finding: FINISH004
- implicated_surface: ticket-pack-builder and ticket contract surfaces
- ownership_class: managed workflow contract surface
- workflow_failure: Interactive consumer-facing repo still relies on a weak generic finish bar instead of explicit interaction-proof requirements.

## Ownership Classification

### EXEC-GODOT-006

- ownership_class: generated repo execution surface
- affected_surface: repo-scaffold-factory managed template surfaces

### EXEC-REMED-001

- ownership_class: generated repo execution surface
- affected_surface: repo-scaffold-factory managed template surfaces

### EXEC-REMED-001

- ownership_class: generated repo execution surface
- affected_surface: repo-scaffold-factory managed template surfaces

### BOOT003

- ownership_class: generated repo source and configuration surfaces
- affected_surface: managed bootstrap tool and bootstrap-facing workflow guidance

### FINISH002

- ownership_class: managed workflow contract surface
- affected_surface: scafforge-audit diagnosis contract

### FINISH004

- ownership_class: managed workflow contract surface
- affected_surface: ticket-pack-builder and ticket contract surfaces

## Root Cause Analysis

### BOOT003

- root_cause: The recorded bootstrap fingerprint is the empty-hash sentinel even though the repo exposes meaningful bootstrap surfaces. That means the generated workflow was hashing an incomplete input set and can leave bootstrap status stale after moving machines or fixing host prerequisites.
- safer_target_pattern: Hash stack-sensitive repo surfaces plus host-side prerequisite signals so bootstrap becomes stale when the machine setup changes, then rerun environment_bootstrap after package repair installs the stronger freshness model.
- how_the_workflow_allowed_it: The generated bootstrap freshness contract cannot detect host drift for this repo.

### EXEC-GODOT-006

- root_cause: The repo is treating a contradictory smoke artifact as release proof. A Godot export or release-validation run can record parse/script-load failures or command-level failure markers while the artifact still says PASS, which lets a broken runtime state look releasable.
- safer_target_pattern: Make smoke_test fail when Godot export/load output contains parse or script-load errors, and reject PASS smoke artifacts whose command blocks record non-zero exit codes or non-`none` failure classifications before release closeout.
- how_the_workflow_allowed_it: Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence.

### EXEC-REMED-001

- root_cause: A ticket created from a validated finding is being reviewed on prose alone, so the audit cannot confirm that the original failing command or canonical acceptance command was actually rerun after the fix.
- safer_target_pattern: For remediation tickets with `finding_source`, require the review artifact to record the exact command run, include raw command output, and state the explicit PASS/FAIL result before the review counts as trustworthy closure.
- how_the_workflow_allowed_it: Remediation review artifact does not contain runnable command evidence.

### EXEC-REMED-001

- root_cause: A ticket created from a validated finding is being reviewed on prose alone, so the audit cannot confirm that the original failing command or canonical acceptance command was actually rerun after the fix.
- safer_target_pattern: For remediation tickets with `finding_source`, require the review artifact to record the exact command run, include raw command output, and state the explicit PASS/FAIL result before the review counts as trustworthy closure.
- how_the_workflow_allowed_it: Remediation review artifact does not contain runnable command evidence.

### FINISH002

- root_cause: The restart narrative or workflow state signals completion while the canonical finish contract still requires non-placeholder visuals, audio, or content proof.
- safer_target_pattern: Either close or supersede the open finish tickets with real content proof, or update the restart narrative to stop claiming finished-product ready state until the finish bar is met.
- how_the_workflow_allowed_it: Repo claims ready or finished state, but the finish contract forbids placeholder output and finish-owning tickets are still open.

### FINISH004

- root_cause: Older Scafforge-generated finish contracts and finish-validation tickets could prove only that a build exists, not that the shipped interaction loop and visible user-facing state were actually demonstrated. That leaves low-quality interactive products able to look complete through generic prose.
- safer_target_pattern: Replace generic machine-generated finish_acceptance_signals with repo-specific interactive proof requirements, and require FINISH-VALIDATE-001 to demand user-observable interaction evidence in addition to load/export proof.
- how_the_workflow_allowed_it: Interactive consumer-facing repo still relies on a weak generic finish bar instead of explicit interaction-proof requirements.

