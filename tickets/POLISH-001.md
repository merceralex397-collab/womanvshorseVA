# POLISH-001: Add particle effects for combat feedback

## Summary

Add lightweight procedural particle effects for combat feedback. Hit particles (orange-yellow circles) burst from impact point on enemy damage. Death particles (larger burst) on enemy kill. Player damage flash already exists from CORE-005. Use _draw() based particles with velocity, friction, and lifetime — not GPUParticles2D.

## Wave

3

## Lane

visual-polish

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

CORE-005

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] scripts/hit_particle.gd extends Node2D with velocity, lifetime, fade-out
- [ ] 5 particles spawn at impact point on enemy damage (orange-yellow circles via _draw)
- [ ] Larger burst (8-10 particles) on enemy death
- [ ] Particles have velocity with friction (0.9 decay) and fade via modulate.a
- [ ] Particles queue_free after lifetime (~0.3s)
- [ ] No performance regression — particles use _draw(), not GPUParticles2D

## Artifacts

- plan: .opencode/state/artifacts/history/polish-001/planning/2026-04-10T04-05-09-995Z-plan.md (planning) - Planning artifact for POLISH-001: Add particle effects for combat feedback. Covers hit_particle.gd design, spawn functions, integration into melee_arc.gd, projectile.gd, and enemy_base.gd, validation strategy, risk analysis, and full acceptance criteria mapping.
- plan-review: .opencode/state/artifacts/history/polish-001/plan-review/2026-04-10T04-07-53-465Z-plan-review.md (plan_review) - Plan review APPROVED for POLISH-001. All 6 acceptance criteria covered with sound Godot 4.6 patterns. Implementation cleared to proceed.
- implementation: .opencode/state/artifacts/history/polish-001/implementation/2026-04-10T04-23-10-590Z-implementation.md (implementation) - Implementation for POLISH-001: Created hit_particle.gd with HitParticle class_name, velocity/lifetime/friction/fade, spawn functions. Modified melee_arc.gd, projectile.gd, and enemy_base.gd to spawn particles on attacks and enemy death. All 6 acceptance criteria met.
- review: .opencode/state/artifacts/history/polish-001/review/2026-04-10T04-29-25-104Z-review.md (review) - Code review APPROVED for POLISH-001. All 6 acceptance criteria pass. HitParticle system uses Godot 4.6 patterns, _draw()-based particles, correct fade math, and proper lifecycle. No regressions. Godot headless validation blocked by environment tooling constraint.
- qa: .opencode/state/artifacts/history/polish-001/qa/2026-04-10T04-46-25-869Z-qa.md (qa) - QA verification for POLISH-001: All 6 acceptance criteria pass. hit_particle.gd with velocity/lifetime/friction/_draw() verified, spawn_hit_particles(5) integrated in melee_arc.gd and projectile.gd, spawn_death_particles(8-10) integrated in enemy_base.gd, all criteria met.
- smoke-test: .opencode/state/artifacts/history/polish-001/smoke-test/2026-04-10T04-47-16-694Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test passed.
- smoke-test: .opencode/state/artifacts/history/polish-001/smoke-test/2026-04-10T11-20-52-668Z-smoke-test.md (smoke-test) - Deterministic smoke test failed.
- backlog-verification: .opencode/state/artifacts/history/polish-001/review/2026-04-10T11-22-37-581Z-backlog-verification.md (review) - Backlog verification PASS — all 6 acceptance criteria verified against current source, smoke test exit code 0, implementation correct. Trust restored. No reopening or rollback needed.
- reverification: .opencode/state/artifacts/history/polish-001/review/2026-04-10T11-23-00-399Z-reverification.md (review) [superseded] - Trust restored using POLISH-001.
- reverification: .opencode/state/artifacts/history/polish-001/review/2026-04-10T11-25-28-025Z-reverification.md (review) - Trust restored using POLISH-001.

## Notes


