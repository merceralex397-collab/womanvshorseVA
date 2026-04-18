# CORE-004: Create HUD with health hearts, wave counter, and score

## Summary

Create a CanvasLayer-based HUD showing: health hearts (top-left, procedural red shapes), wave counter (top-center, Label), and score (top-right, Label). Hearts drawn via _draw() — filled red for current HP, grey for lost HP. Updates via signals from player and wave spawner.

## Wave

1

## Lane

ui-hud

## Parallel Safety

- parallel_safe: true
- overlap_risk: low

## Stage

closeout

## Status

done

## Trust

- resolution_state: done
- verification_state: reverified
- finding_source: None
- source_ticket_id: None
- source_mode: None

## Depends On

SETUP-001

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] scripts/hud.gd extends CanvasLayer with health, wave, and score display
- [ ] Health hearts drawn procedurally (top-left): red filled for current HP, grey for lost
- [ ] Wave counter Label (top-center) updates on wave_started signal
- [ ] Score Label (top-right) updates on score_changed signal
- [ ] All text uses Godot default font with theme overrides for size and color
- [ ] HUD is added to main scene and connects to game signals

## Artifacts

- plan: .opencode/state/artifacts/history/core-004/planning/2026-04-09T23-37-37-998Z-plan.md (planning) - Planning artifact for CORE-004: Create HUD with health hearts, wave counter, and score. Covers hud.gd implementation, main.tscn wiring, signal connections, and static verification against all 6 acceptance criteria.
- implementation: .opencode/state/artifacts/history/core-004/implementation/2026-04-09T23-39-29-322Z-implementation.md (implementation) - Implementation for CORE-004: Created hud.gd with CanvasLayer, _draw() hearts, wave/score Labels. Modified wave_spawner.gd to add score tracking. Modified main.gd to spawn HUD. All 6 acceptance criteria covered.
- review: .opencode/state/artifacts/history/core-004/review/2026-04-09T23-46-04-276Z-review.md (review) [superseded] - Code review REJECTED for CORE-004 - Signal connection logic in main.gd _setup_hud() is broken. String-membership check "health_changed" in player does not validate signal existence. Must use has_signal() and proper Error handling.
- review: .opencode/state/artifacts/history/core-004/review/2026-04-09T23-48-47-588Z-review.md (review) - Code review APPROVED for CORE-004. Signal connection logic fixed. All 6 acceptance criteria pass.
- qa: .opencode/state/artifacts/history/core-004/qa/2026-04-09T23-49-19-755Z-qa.md (qa) - QA verification for CORE-004: Static verification confirms all 6 acceptance criteria pass.
- smoke-test: .opencode/state/artifacts/history/core-004/smoke-test/2026-04-09T23-49-27-165Z-smoke-test.md (smoke-test) - Deterministic smoke test passed.
- backlog-verification: .opencode/state/artifacts/history/core-004/review/2026-04-10T11-22-35-716Z-backlog-verification.md (review) - Backlog verification PASS — all 6 acceptance criteria verified against current source, smoke-test exit code 0, signal wiring fix confirmed, enemy.type field exists. TRUST recommended. No reopening or rollback needed.
- reverification: .opencode/state/artifacts/history/core-004/review/2026-04-10T11-25-21-434Z-reverification.md (review) - Trust restored using CORE-004.

## Notes


