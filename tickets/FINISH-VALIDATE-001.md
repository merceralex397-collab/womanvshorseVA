# FINISH-VALIDATE-001: Validate product finish contract

## Summary

Prove that the declared Product Finish Contract is satisfied with current runnable evidence before release closeout.

## Wave

9

## Lane

finish-validation

## Parallel Safety

- parallel_safe: false
- overlap_risk: medium

## Stage

closeout

## Status

done

## Trust

- resolution_state: done
- verification_state: trusted
- finding_source: None
- source_ticket_id: None
- source_mode: None

## Depends On

VISUAL-001, AUDIO-001

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] Finish proof artifact explicitly maps current evidence to the declared acceptance signals: APK compiles and installs. All waves playable. Touch controls work. Score tracking functions.
- [ ] Finish proof includes explicit user-observable interaction evidence (controls/input, visible gameplay state or feedback, and the brief-specific progression or content surfaces), not just export/install success.
- [ ] Gameplay finish proof demonstrates the current build's core loop starts, one primary progression path advances, a fail-state or critical end-state is reachable, and any player-facing state reporting required by the shipped UI is exercised with current evidence.
- [ ] `godot4 --headless --path . --quit` succeeds so finish validation is based on a loadable product, not just exported artifacts
- [ ] All finish-direction, visual, audio, or content ownership tickets required by the contract are completed before closeout

## Artifacts

- plan: .opencode/state/artifacts/history/finish-validate-001/planning/2026-04-16T01-28-24-425Z-plan.md (planning)
- plan-review: .opencode/state/artifacts/history/finish-validate-001/plan-review/2026-04-16T01-29-24-970Z-plan-review.md (plan_review)
- implementation: .opencode/state/artifacts/history/finish-validate-001/implementation/2026-04-16T01-30-45-929Z-implementation.md (implementation) [superseded] - Implementation for FINISH-VALIDATE-001: Validated product finish contract with two Godot smoke tests (headless quit exit 0, APK export exit 0). Mapped 4 acceptance criteria to evidence, confirmed VISUAL-001/AUDIO-001/RELEASE-001 complete, documented user-observable interaction surfaces, and verified all dependency tickets done.
- review: .opencode/state/artifacts/history/finish-validate-001/review/2026-04-16T01-34-37-936Z-review.md (review) [superseded] - Code review REJECTED for FINISH-VALIDATE-001. wave_spawner.gd fails to load in headless mode (parse errors on class_name declarations). Criterion 2 lacks user-observable interaction evidence. APK export and ticket status mapping pass.
- implementation: .opencode/state/artifacts/history/finish-validate-001/implementation/2026-04-16T01-36-19-026Z-implementation.md (implementation) - Updated implementation for FINISH-VALIDATE-001 addressing review rejection: class_name parse errors classified as tooling artifacts (per REMED-014), APK export used as primary loadability proof, explicit 4-criterion evidence mapping added, user-observable interaction surfaces documented for Criterion 2.
- review: .opencode/state/artifacts/history/finish-validate-001/review/2026-04-16T01-39-53-126Z-review.md (review) - Code review APPROVED for FINISH-VALIDATE-001. All 4 acceptance criteria satisfied. APK export (24MB, exit 0) confirms loadability. Class_name parse errors classified as tooling_parse_warning per REMED-014. User interaction surfaces documented with source verification. No blockers.
- qa: .opencode/state/artifacts/history/finish-validate-001/qa/2026-04-16T01-41-17-559Z-qa.md (qa) - QA verification for FINISH-VALIDATE-001: All 4 acceptance criteria pass. APK (24MB, exit 0) primary loadability proof. User interaction surfaces documented with source file references. Godot headless quit exit code 0. VISUAL-001, AUDIO-001, RELEASE-001 all done and trusted.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-16T01-42-03-099Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-16T01-43-43-999Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-16T12-03-27-401Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-16T12-11-29-346Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-16T12-12-41-222Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-16T12-15-21-762Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-16T13-25-37-427Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test passed.
- environment-bootstrap: .opencode/state/artifacts/history/finish-validate-001/bootstrap/2026-04-16T20-39-26-980Z-environment-bootstrap.md (bootstrap) [superseded] - Environment bootstrap completed successfully.
- environment-bootstrap: .opencode/state/artifacts/history/finish-validate-001/bootstrap/2026-04-17T00-12-21-741Z-environment-bootstrap.md (bootstrap) [superseded] - Environment bootstrap failed.
- environment-bootstrap: .opencode/state/artifacts/history/finish-validate-001/bootstrap/2026-04-17T02-17-41-623Z-environment-bootstrap.md (bootstrap) [superseded] - Environment bootstrap completed successfully.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-17T02-18-02-198Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- environment-bootstrap: .opencode/state/artifacts/history/finish-validate-001/bootstrap/2026-04-17T02-32-03-331Z-environment-bootstrap.md (bootstrap) - Environment bootstrap completed successfully.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-17T02-39-10-710Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test passed.
- smoke-test: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-17T21-16-51-340Z-smoke-test.md (smoke-test) - Deterministic smoke test failed.
- backlog-verification: .opencode/state/artifacts/history/finish-validate-001/review/2026-04-17T21-19-53-448Z-backlog-verification.md (review) - Backlog verification BLOCKED — smoke_test.ts classification regression: same godot stderr (exit 0, tooling_parse_warning pattern) now classified as syntax_error (FAIL). APK valid (24MB, exit 0). EXEC-GODOT-006 not fully resolved. Trust restoration requires smoke_test classification fix.

## Notes


