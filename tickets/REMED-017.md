# REMED-017: Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence

## Summary

Remediate EXEC-GODOT-006 by correcting the validated issue and rerunning the relevant quality checks. Affected surfaces: project.godot. Historical evidence sources: .opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-17T02-39-10-710Z-smoke-test.md. Treat these history paths as read-only context and record superseding current evidence on this remediation ticket instead of editing immutable history artifacts directly.

## Wave

24

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

- resolution_state: superseded
- verification_state: reverified
- finding_source: EXEC-GODOT-006
- source_ticket_id: REMED-016
- source_mode: split_scope

## Depends On

None

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] The validated finding `EXEC-GODOT-006` no longer reproduces.
- [ ] Current quality checks rerun with evidence tied to the fix approach: Make smoke_test fail when Godot export/load output contains parse or script-load errors, and reject PASS smoke artifacts whose command blocks record non-zero exit codes or non-`none` failure classifications before release closeout.
- [ ] When the finding cites `.opencode/state/artifacts/history/...`, treat those paths as read-only evidence sources and capture the fix on current writable repo surfaces or current ticket artifacts instead of mutating immutable history artifacts directly.

## Artifacts

- plan: .opencode/state/artifacts/history/remed-017/planning/2026-04-17T17-49-27-877Z-plan.md (planning) - Planning artifact for REMED-017: Reorder isGodotFatalDiagnosticOutput() before isClassNameReloadParseWarning() in classifyCommandFailure() so fatal script-load diagnostics with exit_code===0 are classified as syntax_error (blocking) instead of tooling_parse_warning (non-blocking), preventing false PASS smoke artifacts when Godot reports "Failed to load script" alongside class_name RELOAD parse errors.
- plan-review: .opencode/state/artifacts/history/remed-017/plan-review/2026-04-17T17-51-32-115Z-plan-review.md (plan_review) - Plan review APPROVED for REMED-017. All 3 acceptance criteria covered, fix approach sound, Godot 4 tooling patterns correct, no blocking risks.
- implementation: .opencode/state/artifacts/history/remed-017/implementation/2026-04-17T17-52-28-356Z-implementation.md (implementation) [superseded] - Implementation for REMED-017: reordered isGodotFatalDiagnosticOutput() before isClassNameReloadParseWarning() in classifyCommandFailure() so fatal script-load diagnostics with exit_code===0 are classified as syntax_error (blocking) instead of tooling_parse_warning (non-blocking). godot4 --headless --quit exits 0 with "Failed to load script" output confirmed.
- review: .opencode/state/artifacts/history/remed-017/review/2026-04-17T17-54-08-519Z-review.md (review) - Code review APPROVED for REMED-017. All 3 acceptance criteria pass. Reordering confirmed correct: isGodotFatalDiagnosticOutput() fires before isClassNameReloadParseWarning() in exit_code===0 branch. godot4 headless exit 0 with fatal script-load diagnostic now correctly classified as syntax_error, causing smoke test to fail as intended.
- qa: .opencode/state/artifacts/history/remed-017/qa/2026-04-17T17-56-37-738Z-qa.md (qa) [superseded] - QA verification for REMED-017: godot4 headless exit_code=0 with fatal script-load diagnostic classified as syntax_error (blocking), causing expected smoke test FAIL. Fix verified correct.
- smoke-test: .opencode/state/artifacts/history/remed-017/smoke-test/2026-04-17T17-56-53-669Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test passed.
- qa: .opencode/state/artifacts/history/remed-017/qa/2026-04-17T17-59-16-661Z-qa.md (qa) [superseded] - QA verification for REMED-017: FAIL — smoke_test classifies fatal script-load diagnostic as tooling_parse_warning (not syntax_error), smoke test PASSES despite EXEC-GODOT-006 still present.
- smoke-test: .opencode/state/artifacts/history/remed-017/smoke-test/2026-04-17T18-01-13-053Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test passed.
- implementation: .opencode/state/artifacts/history/remed-017/implementation/2026-04-17T18-18-09-702Z-implementation.md (implementation) - Fixed isGodotFatalDiagnosticOutput() pattern from /Failed to load script "res:\/\//i to /Failed to load script/i to correctly match Godot fatal script-load error. Now causes smoke test to FAIL on fatal diagnostics as intended.
- smoke-test: .opencode/state/artifacts/history/remed-017/smoke-test/2026-04-17T18-18-26-196Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test passed.
- smoke-test: .opencode/state/artifacts/history/remed-017/smoke-test/2026-04-17T18-25-15-676Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- qa: .opencode/state/artifacts/history/remed-017/qa/2026-04-17T18-27-54-665Z-qa.md (qa) - QA verification PASS — smoke_test now correctly FAILS with syntax_error classification instead of false PASS. EXEC-GODOT-006 fixed by regex correction in isGodotFatalDiagnosticOutput().
- smoke-test: .opencode/state/artifacts/history/remed-017/smoke-test/2026-04-17T18-28-53-144Z-smoke-test.md (smoke-test) - Deterministic smoke test failed.

## Notes


