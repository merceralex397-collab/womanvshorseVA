# CORE-001: Implement attack system (melee arc + ranged projectile)

## Summary

Implement the dual attack system: tap right screen half for melee arc attack (60-degree arc toward nearest enemy, rendered as semi-transparent white polygon), hold+release right half for ranged projectile (yellow circle moving in facing direction). Both use Area2D on collision layer 3 (PlayerAttack).

## Wave

1

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
- verification_state: trusted
- finding_source: None
- source_ticket_id: None
- source_mode: None

## Depends On

SETUP-002

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] Melee attack triggers on right-half tap, draws a 60-degree arc Area2D toward facing direction
- [ ] Ranged attack triggers on right-half hold+release, spawns a yellow circle projectile in facing direction
- [ ] scripts/projectile.gd extends Area2D with velocity, auto-despawn off-screen or on hit
- [ ] Both attacks use collision layer 3 (PlayerAttack) and mask layer 2 (Enemies)
- [ ] Attack visuals are procedural (_draw or Polygon2D), no imported assets
- [ ] Melee arc visual fades after ~0.2s

## Artifacts

- plan: .opencode/state/artifacts/history/core-001/planning/2026-04-09T22-56-40-114Z-plan.md (planning) - Planning artifact for CORE-001: Implements dual attack system (melee arc + ranged projectile). Covers scope, files affected, 6-step implementation, static + smoke-test validation plan, risks, and full acceptance mapping.
- review: .opencode/state/artifacts/history/core-001/plan-review/2026-04-09T22-59-00-597Z-review.md (plan_review) - Plan review APPROVED for CORE-001. All 6 acceptance criteria covered with sound Godot 4 patterns. Two non-blocking design notes: (1) melee arc collision shape is circular approximation vs visual 60-degree sector, acknowledged in risk table; (2) unused fade_ratio parameter in _get_arc_points(), no functional impact.
- implementation: .opencode/state/artifacts/history/core-001/implementation/2026-04-09T23-03-16-694Z-implementation.md (implementation) - Implementation for CORE-001: Created projectile.gd, melee_arc.gd, attack_controller.gd and modified player.gd to add attack handling.
- qa: .opencode/state/artifacts/history/core-001/qa/2026-04-09T23-04-15-086Z-qa.md (qa) - QA verification for CORE-001: Static verification confirms all 6 acceptance criteria pass.
- smoke-test: .opencode/state/artifacts/history/core-001/smoke-test/2026-04-09T23-04-25-248Z-smoke-test.md (smoke-test) - Deterministic smoke test passed.
- backlog-verification: .opencode/state/artifacts/history/core-001/review/2026-04-09T23-20-12-073Z-backlog-verification.md (review) - Backlog verification PASS — all 6 acceptance criteria verified, smoke test exit code 0, implementation correct. Documentation gap noted: no code review artifact (only plan-review). No reopening or rollback needed.

## Notes


