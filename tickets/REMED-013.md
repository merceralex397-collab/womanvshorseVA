# REMED-013: GDScript calls APIs that are unavailable on the script's declared base type

## Summary

Remediate EXEC-GODOT-009 by correcting the validated issue and rerunning the relevant quality checks. Affected surfaces: project.godot, scripts/hud.gd, scripts/wave_spawner.gd.

## Wave

20

## Lane

remediation

## Parallel Safety

- parallel_safe: false
- overlap_risk: low

## Stage

closeout

## Status

done

## Trust

- resolution_state: done
- verification_state: reverified
- finding_source: EXEC-GODOT-009
- source_ticket_id: REMED-002
- source_mode: split_scope

## Depends On

None

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] The validated finding `EXEC-GODOT-009` no longer reproduces.
- [ ] Current quality checks rerun with evidence tied to the fix approach: Validate GDScript method calls against the declared base type and move draw/redraw or viewport-rect logic onto compatible CanvasItem-derived nodes before treating headless load as trustworthy.

## Artifacts

- plan: .opencode/state/artifacts/history/remed-013/planning/2026-04-17T02-57-25-878Z-plan.md (planning) - Planning artifact for REMED-013: GDScript calls APIs unavailable on declared base type. Static analysis shows current code (hud.gd extends Control, wave_spawner.gd extends Node2D) already uses compatible APIs. Godot headless validation planned to confirm finding no longer reproduces.
- plan-review: .opencode/state/artifacts/history/remed-013/plan-review/2026-04-17T02-58-30-788Z-plan-review.md (plan_review) - Plan review APPROVED for REMED-013. Static analysis confirms hud.gd (extends Control) and wave_spawner.gd (extends Node2D) already use compatible APIs. Godot headless validation plan covers both acceptance criteria.
- implementation: .opencode/state/artifacts/history/remed-013/implementation/2026-04-17T03-00-07-858Z-implementation.md (implementation) - Implementation for REMED-013: Godot headless validation confirms EXEC-GODOT-009 does not reproduce. Exit code 0, no API-not-available errors, class_name parse errors classified as tooling_parse_warning per REMED-014. Both acceptance criteria pass.
- review: .opencode/state/artifacts/history/remed-013/review/2026-04-17T03-01-41-880Z-review.md (review) - Code review APPROVED for REMED-013. All 2 acceptance criteria pass. EXEC-GODOT-009 does not reproduce — hud.gd (extends Control) and wave_spawner.gd (extends Node2D) use compatible APIs. Godot headless exit code 0. Stderr class_name errors classified as tooling_parse_warning per REMED-014.
- qa: .opencode/state/artifacts/history/remed-013/qa/2026-04-17T03-08-27-116Z-qa.md (qa) - QA verification for REMED-013: Godot headless exit code 0, no API-not-available errors. Both acceptance criteria pass.
- smoke-test: .opencode/state/artifacts/history/remed-013/smoke-test/2026-04-17T03-09-07-900Z-smoke-test.md (smoke-test) - Deterministic smoke test passed.
- environment-bootstrap: .opencode/state/artifacts/history/remed-013/bootstrap/2026-04-17T22-43-23-485Z-environment-bootstrap.md (bootstrap) [superseded] - Environment bootstrap completed successfully.
- environment-bootstrap: .opencode/state/artifacts/history/remed-013/bootstrap/2026-04-17T22-54-03-771Z-environment-bootstrap.md (bootstrap) - Environment bootstrap completed successfully.
- backlog-verification: .opencode/state/artifacts/history/remed-013/review/2026-04-17T22-56-25-572Z-backlog-verification.md (review) - Backlog verification PASS — both acceptance criteria verified, EXEC-GODOT-009 does not reproduce, Godot headless exit code 0, API compatibility confirmed via static analysis. No reverification needed.
- reverification: .opencode/state/artifacts/history/remed-013/review/2026-04-17T22-56-48-700Z-reverification.md (review) - Trust restored using REMED-013.

## Notes


