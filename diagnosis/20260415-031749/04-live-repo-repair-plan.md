# Live Repo Repair Plan

## Preconditions

- Repo: /home/rowan/womanvshorseVA
- Audit stayed non-mutating. No repo or product-code edits were made by this diagnosis run.

## Triage Order

- package_first_count: 0
- subject_repo_follow_up_count: 3
- host_or_manual_prerequisite_count: 0

## Package Changes Required First

- None recorded.

## Post-Update Repair Actions

- Route 2 workflow-layer finding(s) into `scafforge-repair` for deterministic managed-surface refresh.

### REMED-012

- linked_report_id: CONFIG010
- action_type: safe Scafforge package change
- should_scafforge_repair_run: yes
- carry_diagnosis_pack_into_scafforge_first: no
- target_repo: subject repo
- summary: Backfill the rendered asset starter surfaces from the current package during managed repair and keep them aligned to the canonical finish contract.

### REMED-013

- linked_report_id: CONFIG011
- action_type: safe Scafforge package change
- should_scafforge_repair_run: yes
- carry_diagnosis_pack_into_scafforge_first: no
- target_repo: subject repo
- summary: Disable blender_agent for non-Blender routes even if Blender happens to be installed on the current host.

## Ticket Follow-Up

### REMED-010

- linked_report_id: EXEC-GODOT-006
- action_type: generated-repo remediation ticket/process repair
- should_scafforge_repair_run: only after managed workflow repair converges
- carry_diagnosis_pack_into_scafforge_first: no
- target_repo: subject repo
- summary: Make smoke_test fail when Godot export/load output contains parse or script-load errors, and reject PASS smoke artifacts whose command blocks record non-zero exit codes or non-`none` failure classifications before release closeout.
- assignee: implementer
- suggested_fix_approach: Make smoke_test fail when Godot export/load output contains parse or script-load errors, and reject PASS smoke artifacts whose command blocks record non-zero exit codes or non-`none` failure classifications before release closeout.

### REMED-011

- linked_report_id: EXEC-GODOT-009
- action_type: generated-repo remediation ticket/process repair
- should_scafforge_repair_run: only after managed workflow repair converges
- carry_diagnosis_pack_into_scafforge_first: no
- target_repo: subject repo
- summary: Validate GDScript method calls against the declared base type and move draw/redraw or viewport-rect logic onto compatible CanvasItem-derived nodes before treating headless load as trustworthy.
- assignee: implementer
- suggested_fix_approach: Validate GDScript method calls against the declared base type and move draw/redraw or viewport-rect logic onto compatible CanvasItem-derived nodes before treating headless load as trustworthy.

### REMED-002

- linked_report_id: EXEC-REMED-001
- action_type: generated-repo remediation ticket/process repair
- should_scafforge_repair_run: only after managed workflow repair converges
- carry_diagnosis_pack_into_scafforge_first: no
- target_repo: subject repo
- summary: For remediation tickets with `finding_source`, require the review artifact to record the exact command run, include raw command output, and state the explicit PASS/FAIL result before the review counts as trustworthy closure.
- assignee: implementer
- suggested_fix_approach: For remediation tickets with `finding_source`, require the review artifact to record the exact command run, include raw command output, and state the explicit PASS/FAIL result before the review counts as trustworthy closure.

## Reverification Plan

- After package-side fixes land, run one fresh audit on the subject repo before applying another repair cycle.
- After managed repair, rerun the public repair verifier and confirm restart surfaces, ticket routing, and any historical trust restoration paths match the current canonical state.
- Do not treat restart prose alone as proof; the canonical manifest and workflow state remain the source of truth.

