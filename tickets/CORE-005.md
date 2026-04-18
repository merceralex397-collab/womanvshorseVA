# CORE-005: Implement collision and damage system

## Summary

Wire up collision detection between player attacks and enemies, and between enemies and player. Player attacks (layer 3) damage enemies on contact. Enemy bodies (layer 2) damage player on overlap with player (layer 1). Implement damage flash, invincibility frames for player (~0.5s), score increment on enemy kill, and game over at 0 HP.

## Wave

2

## Lane

combat-system

## Parallel Safety

- parallel_safe: false
- overlap_risk: medium

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

CORE-001, CORE-002

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] Player melee arc and projectiles damage enemies on Area2D body_entered (layer 3 vs layer 2)
- [ ] Enemy contact with player deals 1 damage (layer 2 vs layer 1)
- [ ] Player has ~0.5s invincibility after taking damage with visual flash
- [ ] Score increments by enemy point value on kill (brown=10, black=20, war=50, boss=100)
- [ ] Game state transitions to GAME_OVER when player HP reaches 0
- [ ] Damage flash uses modulate tween (white flash → normal in 0.15s)

## Artifacts

- plan: .opencode/state/artifacts/history/core-005/planning/2026-04-10T03-17-11-082Z-plan.md (planning) - Planning artifact for CORE-005: Covers collision/damage implementation approach, 7-step plan, files to modify, validation strategy, acceptance criteria mapping, and risk analysis.
- plan-review: .opencode/state/artifacts/history/core-005/plan-review/2026-04-10T03-26-13-050Z-plan-review.md (plan_review) - Plan review APPROVED for CORE-005. All 6 acceptance criteria covered with sound Godot 4 patterns. Non-blocking notes: (1) tween cancellation recommended in _flash_damage(), (2) GAME_OVER case in main.gd needs implementation, (3) contact sensor radius could be increased to 25-30.
- implementation: .opencode/state/artifacts/history/core-005/implementation/2026-04-10T03-36-33-549Z-implementation.md (implementation) - Implementation for CORE-005: Collision and damage system. Added player contact sensor, invincibility frames, damage flash with tween, enemy attack collision, and GAME_OVER state handling in main.gd.
- review: .opencode/state/artifacts/history/core-005/review/2026-04-10T03-54-38-079Z-review.md (review) - Code review APPROVED for CORE-005. All 6 acceptance criteria pass. All 4 plan-review recommendations implemented.
- qa: .opencode/state/artifacts/history/core-005/qa/2026-04-10T03-59-19-523Z-qa.md (qa) - QA verification for CORE-005: All 6 acceptance criteria pass static verification. Collision/damage system fully implemented per Godot 4 patterns.
- smoke-test: .opencode/state/artifacts/history/core-005/smoke-test/2026-04-10T03-59-45-062Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- smoke-test: .opencode/state/artifacts/history/core-005/smoke-test/2026-04-10T04-00-22-709Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test passed.
- smoke-test: .opencode/state/artifacts/history/core-005/smoke-test/2026-04-10T04-01-30-082Z-smoke-test.md (smoke-test) - Deterministic smoke test passed.
- backlog-verification: .opencode/state/artifacts/history/core-005/review/2026-04-10T11-21-45-272Z-backlog-verification.md (review) - Backlog verification PASS — all 6 acceptance criteria verified against current source, smoke test exit code 0, implementation correct. godot4 stderr parse warnings are tooling artifacts, not code defects. TRUST recommended. No reopening or rollback needed.
- reverification: .opencode/state/artifacts/history/core-005/review/2026-04-10T11-24-02-657Z-reverification.md (review) [superseded] - Trust restored using CORE-005.
- reverification: .opencode/state/artifacts/history/core-005/review/2026-04-10T11-25-24-346Z-reverification.md (review) - Trust restored using CORE-005.

## Notes


