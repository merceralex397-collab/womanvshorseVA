# CORE-002: Create enemy horse base class with charge behavior

## Summary

Create the base enemy horse class as a CharacterBody2D with health, speed, charge-toward-player behavior, procedural rectangle visual, and death signal. Enemies spawn facing the player and move toward them. On death, emit enemy_died signal and queue_free.

## Wave

1

## Lane

enemy-system

## Parallel Safety

- parallel_safe: true
- overlap_risk: low

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

SETUP-001

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] scripts/enemy_base.gd extends CharacterBody2D with class_name EnemyBase
- [ ] Has @export vars: max_health, speed, body_color, body_size
- [ ] Charge behavior: moves toward player position each physics frame
- [ ] Procedural visual: colored rectangle body + lighter triangle head indicator
- [ ] Collision layer 2 (Enemies), mask layers 1 (Player) and 3 (PlayerAttack)
- [ ] Emits enemy_died signal on death, calls queue_free()
- [ ] take_damage(amount) method decrements health and triggers flash

## Artifacts

- plan: .opencode/state/artifacts/history/core-002/planning/2026-04-09T23-06-33-599Z-plan.md (planning) - Planning artifact for CORE-002: Create enemy horse base class with charge behavior. Covers scope, files affected, 5-step implementation, static + smoke-test validation plan, risks, and full acceptance mapping.
- review: .opencode/state/artifacts/history/core-002/plan-review/2026-04-09T23-08-32-711Z-review.md (plan_review) - Plan review APPROVED for CORE-002. All 7 acceptance criteria covered, Godot 4 standards met. Non-blocking note: collision_mask should be 5 (not 3) per acceptance criterion 5.
- implementation: .opencode/state/artifacts/history/core-002/implementation/2026-04-09T23-09-41-234Z-implementation.md (implementation) - Implementation for CORE-002: enemy_base.gd with charge behavior, health system, procedural visual
- qa: .opencode/state/artifacts/history/core-002/qa/2026-04-09T23-10-25-067Z-qa.md (qa) - QA verification for CORE-002: Static verification confirms all 7 acceptance criteria pass.
- smoke-test: .opencode/state/artifacts/history/core-002/smoke-test/2026-04-09T23-10-49-633Z-smoke-test.md (smoke-test) - Deterministic smoke test passed.
- backlog-verification: .opencode/state/artifacts/history/core-002/review/2026-04-09T23-20-13-167Z-backlog-verification.md (review) - Backlog verification PASS — all 7 acceptance criteria verified, smoke test exit code 0, implementation correct. Documentation gap noted: no code review artifact (only plan-review). No reopening or rollback needed.

## Notes

