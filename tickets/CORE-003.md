# CORE-003: Implement wave spawner with escalating difficulty

## Summary

Create a WaveSpawner node that manages wave progression. Spawns enemies from random arena edges. Wave 1: 3 brown. Wave 2: 5 brown. Wave 3: 3 brown + 2 black. Wave 5+: boss every 5 waves with escorts. Tracks enemies_alive count and starts next wave when all defeated.

## Wave

1

## Lane

wave-system

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

CORE-002

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] scripts/wave_spawner.gd extends Node with wave_number, enemies_alive tracking
- [ ] Enemies spawn from random positions on arena edges (outside play area)
- [ ] Wave composition follows the canonical spec: brown from wave 1, black from wave 3, war horse from wave 6, boss every 5 waves
- [ ] Next wave starts automatically when enemies_alive reaches 0
- [ ] Emits wave_started(wave_number) signal for HUD updates
- [ ] Difficulty scales: enemy count increases ~2 per wave

## Artifacts

- plan: .opencode/state/artifacts/history/core-003/planning/2026-04-09T23-14-09-347Z-plan.md (planning) - Planning artifact for CORE-003: Implement wave spawner with escalating difficulty. Covers wave composition per canonical spec, arena-edge spawning, automatic wave progression, signals for HUD, and static verification against all 6 acceptance criteria.
- implementation: .opencode/state/artifacts/history/core-003/implementation/2026-04-09T23-23-03-076Z-implementation.md (implementation) - Implementation for CORE-003: Created wave_spawner.gd with correct wave composition, signal wiring, arena-edge spawning, and escalating difficulty.
- qa: .opencode/state/artifacts/history/core-003/qa/2026-04-09T23-23-49-058Z-qa.md (qa) - QA verification for CORE-003: Static verification confirms all 6 acceptance criteria pass.
- smoke-test: .opencode/state/artifacts/history/core-003/smoke-test/2026-04-09T23-24-00-147Z-smoke-test.md (smoke-test) - Deterministic smoke test passed.
- backlog-verification: .opencode/state/artifacts/history/core-003/review/2026-04-10T11-19-16-579Z-backlog-verification.md (review) - Backlog verification PASS — all 6 acceptance criteria verified against current source, smoke test exit code 0, factory pattern correctly wired to verified enemy variant classes. Trust restored. Documentation gap (no review artifact) noted but non-blocking.
- reverification: .opencode/state/artifacts/history/core-003/review/2026-04-10T11-19-57-626Z-reverification.md (review) - Trust restored using CORE-003.

## Notes


