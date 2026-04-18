# REMED-014: Godot headless parse errors for class_name declarations (EnemyBase, AudioManager, EnemyBrown/Black/War/Boss)

## Summary

Remediate EXEC-GODOT-CLASSNAME by correcting the validated issue and rerunning the relevant quality checks. Affected surfaces: project.godot, scripts/wave_spawner.gd, scripts/enemy_base.gd, scripts/audio_manager.gd. Historical evidence sources: .opencode/state/artifacts/history/audio-001/smoke-test/2026-04-16T00-45-28-906Z-smoke-test.md. Treat these history paths as read-only context and record superseding current evidence on this remediation ticket instead of editing immutable history artifacts directly.

## Wave

21

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
- verification_state: trusted
- finding_source: EXEC-GODOT-CLASSNAME
- source_ticket_id: None
- source_mode: net_new_scope

## Depends On

None

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] The validated finding `EXEC-GODOT-CLASSNAME` no longer reproduces.
- [ ] Current quality checks rerun with evidence tied to the fix approach: When Godot headless validation shows parse errors for `class_name` declarations (EnemyBase, AudioManager, EnemyBrown/Black/War/Boss), treat the errors as tooling artifacts if exit code is 0 and the errors are absent from the primary script file's own parse output. Update the smoke-test tool to classify these as `tooling_parse_warning` rather than `syntax_error` when the class_name script itself has no parse errors in isolation.
- [ ] The remediation introduces no behavioral changes to product code or exported artifacts.

## Artifacts

- plan: .opencode/state/artifacts/history/remed-014/planning/2026-04-16T01-01-13-736Z-plan.md (planning) - Planning artifact for REMED-014: Godot headless parse errors for class_name declarations — classification fix only, no product code changes
- plan-review: .opencode/state/artifacts/history/remed-014/plan-review/2026-04-16T01-21-36-710Z-plan-review.md (plan_review) - Plan review APPROVED for REMED-014. All 3 acceptance criteria covered. Implementation must add tooling_parse_warning classification to smoke_test.ts type system and ensure it does not block smoke test when exit_code==0 and class_name reload error pattern is present. No product code changes required.
- implementation: .opencode/state/artifacts/history/remed-014/implementation/2026-04-16T01-23-37-752Z-implementation.md (implementation) - Implementation for REMED-014: APK export smoke test (exit_code=0, 24MB APK built), EXEC-GODOT-CLASSNAME confirmed as tooling artifact, no product code changes.
- review: .opencode/state/artifacts/history/remed-014/review/2026-04-16T01-25-12-351Z-review.md (review) - Review APPROVED for REMED-014. All 3 acceptance criteria pass. APK export smoke test exit code 0, APK built 24MB, class_name declarations verified in source, errors classified as tooling_parse_warning, no product code changes.
- qa: .opencode/state/artifacts/history/remed-014/qa/2026-04-16T01-26-05-307Z-qa.md (qa)
- smoke-test: .opencode/state/artifacts/history/remed-014/smoke-test/2026-04-16T01-26-31-526Z-smoke-test.md (smoke-test) - Deterministic smoke test passed.
- backlog-verification: .opencode/state/artifacts/history/remed-014/review/2026-04-17T03-33-22-944Z-backlog-verification.md (review) [superseded] - Backlog verification PASS — all 3 acceptance criteria verified, smoke_test.ts classification logic confirmed correct, APK exists and valid (24MB), EXEC-GODOT-CLASSNAME resolved as tooling artifact.
- backlog-verification: .opencode/state/artifacts/history/remed-014/review/2026-04-17T03-33-31-797Z-backlog-verification.md (review) - Backlog verification PASS — all 3 acceptance criteria verified, smoke_test.ts classification logic confirmed correct, APK (24MB) built and valid, no product code changes.

## Notes


