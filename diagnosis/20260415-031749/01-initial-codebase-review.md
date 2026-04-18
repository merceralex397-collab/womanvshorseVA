# Initial Codebase Review

## Scope

- subject repo: /home/rowan/womanvshorseVA
- diagnosis timestamp: 2026-04-15T03:17:49Z
- audit scope: managed workflow, restart, ticket, prompt, and execution surfaces
- verification scope: current repo state only

## Result State

- result_state: validated failures found
- finding_count: 5
- errors: 3
- warnings: 2

## Validated Findings

### Workflow Findings

### CONFIG010

- finding_id: CONFIG010
- summary: A managed game repo is missing canonical asset-pipeline starter surfaces.
- severity: warning
- evidence_grade: repo-state validation
- affected_files_or_surfaces: assets/briefs, assets/models, assets/sprites, assets/audio, assets/fonts, assets/themes, assets/previews, assets/workfiles, assets/licenses, assets/import-reports, assets/pipeline.json, assets/PROVENANCE.md, assets/briefs/README.md, .opencode/meta/asset-pipeline-bootstrap.json
- observed_or_reproduced: Legacy scaffold or repair runs did not propagate the deterministic asset route metadata and starter layout into the repo.
- evidence:
  - Missing asset starter surfaces: assets/briefs, assets/models, assets/sprites, assets/audio, assets/fonts, assets/themes, assets/previews, assets/workfiles, assets/licenses, assets/import-reports, assets/pipeline.json, assets/PROVENANCE.md, assets/briefs/README.md, .opencode/meta/asset-pipeline-bootstrap.json
  - Invalid asset starter surfaces: assets/pipeline.json, .opencode/meta/asset-pipeline-bootstrap.json
- remaining_verification_gap: None recorded beyond the validated finding scope.

### CONFIG011

- finding_id: CONFIG011
- summary: blender_agent is enabled for a repo whose current asset route does not require Blender-MCP.
- severity: warning
- evidence_grade: repo-state validation
- affected_files_or_surfaces: opencode.jsonc
- observed_or_reproduced: The generated OpenCode configuration is coupling Blender enablement to host discovery instead of the repo's canonical asset strategy.
- evidence:
  - Expected blender route: False
  - blender_agent.enabled = True
  - Preview pipeline route mode: single-route
  - Expected primary routes: {'characters': 'godot-native-authored', 'environments': 'godot-native-authored', 'props': 'godot-native-authored', 'ui': 'godot-native-authored', 'audio': 'godot-native-authored', 'vfx': 'godot-native-authored'}
- remaining_verification_gap: None recorded beyond the validated finding scope.

## Code Quality Findings

### EXEC-GODOT-006

- finding_id: EXEC-GODOT-006
- summary: Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence.
- severity: CRITICAL
- evidence_grade: repo-state validation
- affected_files_or_surfaces: project.godot, .opencode/state/artifacts/history/release-001/smoke-test/2026-04-10T11-36-40-894Z-smoke-test.md
- observed_or_reproduced: The repo is treating a contradictory smoke artifact as release proof. A Godot export or release-validation run can record parse/script-load failures or command-level failure markers while the artifact still says PASS, which lets a broken runtime state look releasable.
- evidence:
  - release_lane_started_or_done = True
  - repo_claims_completion = False
  - RELEASE-001: SCRIPT ERROR: Parse Error: Function "draw_circle()" not found in base self.

### EXEC-GODOT-009

- finding_id: EXEC-GODOT-009
- summary: GDScript calls APIs that are unavailable on the script's declared base type.
- severity: CRITICAL
- evidence_grade: repo-state validation
- affected_files_or_surfaces: project.godot, scripts/hud.gd, scripts/hud.gd, scripts/wave_spawner.gd
- observed_or_reproduced: The audit found script methods that only exist on CanvasItem-style nodes being called from scripts that extend incompatible bases such as Node or CanvasLayer, which guarantees runtime parse/load failure even before gameplay starts.
- evidence:
  - scripts/hud.gd: extends CanvasLayer but calls draw_circle()
  - scripts/hud.gd: extends CanvasLayer but calls queue_redraw()
  - scripts/wave_spawner.gd: extends Node but calls get_viewport_rect()

### EXEC-REMED-001

- finding_id: EXEC-REMED-001
- summary: Remediation review artifact does not contain runnable command evidence.
- severity: CRITICAL
- evidence_grade: repo-state validation
- affected_files_or_surfaces: tickets/manifest.json, .opencode/state/reviews/remed-001-review-backlog-verification.md
- observed_or_reproduced: A ticket created from a validated finding is being reviewed on prose alone, so the audit cannot confirm that the original failing command or canonical acceptance command was actually rerun after the fix.
- evidence:
  - ticket REMED-001 carries finding_source `EXEC-REMED-001`
  - review artifact: .opencode/state/reviews/remed-001-review-backlog-verification.md
  - missing raw command output evidence
  - missing explicit post-fix PASS/FAIL result

## Verification Gaps

- The diagnosis pack validates the concrete failures above. It does not claim broader runtime-path coverage than the current audit and supporting evidence actually exercised.

