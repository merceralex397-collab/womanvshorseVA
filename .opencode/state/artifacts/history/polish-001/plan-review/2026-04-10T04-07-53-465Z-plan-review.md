# Plan Review — POLISH-001: Add Particle Effects for Combat Feedback

## Verdict: APPROVED

All 6 acceptance criteria are properly addressed with sound Godot 4.6 patterns. Plan is ready for implementation.

---

## Acceptance Criteria Coverage

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | `scripts/hit_particle.gd extends Node2D` with velocity, lifetime, fade-out | ✅ PASS | `class_name HitParticle extends Node2D` with all required vars; `modulate.a` fade in `_physics_process()` |
| 2 | 5 particles spawn at impact on enemy damage (orange-yellow via `_draw`) | ✅ PASS | `spawn_hit()` loops `range(5)`, `Color(1.0, 0.6, 0.0)`, called from `melee_arc.gd` and `projectile.gd` |
| 3 | Larger burst (8-10 particles) on enemy death | ✅ PASS | `spawn_death()` uses `8 + randi() % 3` → 8-10 range; connected via `enemy_died` signal |
| 4 | Velocity with 0.9 friction decay + fade via `modulate.a` | ✅ PASS | `velocity *= friction` (0.9) in `_physics_process()`; `modulate.a` fades from 70% lifetime onward |
| 5 | Particles `queue_free` after ~0.3s | ✅ PASS | `max_lifetime = 0.3` (hit) / `0.35` (death); exit via `lifetime >= max_lifetime` |
| 6 | No `GPUParticles2D` — uses `_draw()` only | ✅ PASS | Plan explicitly excludes GPUParticles2D; `_draw()` circle confirmed |

---

## Godot 4.6 Patterns Check

- Static typing: ✅ All vars use `var name: Type` pattern
- `class_name`: ✅ Used for `HitParticle` to enable static-style access
- `TAU`: ✅ Used in `_random_velocity()` for angle calculation
- Signal wiring: ✅ `enemy_died.connect(Callable(self, "_on_enemy_died"))`
- `_physics_process(delta)`: ✅ Delta applied to velocity
- `_draw()`: ✅ Used for particle rendering (no GPUParticles2D)
- `modulate.a`: ✅ Used for alpha fade (proper Godot 4.x property)

---

## Integration Points Review

| File | Change | Review |
|------|--------|--------|
| `scripts/hit_particle.gd` | New class with `spawn_hit()`, `spawn_death()`, `_random_velocity()`, `_physics_process()`, `_draw()` | ✅ Sound design; static spawn methods keep API simple |
| `scripts/melee_arc.gd` | Add `HitParticle.spawn_hit()` in `_on_hit_enemy()` | ✅ Correct — called after `take_damage(1)` |
| `scripts/projectile.gd` | Add `HitParticle.spawn_hit()` in `_on_hit_enemy()` | ✅ Correct — called after `take_damage(1)` |
| `scripts/enemy_base.gd` | Connect `enemy_died` → `HitParticle.spawn_death()` | ✅ Correct — fires at `global_position` |

---

## Non-Blocking Notes

1. **`randi() % 3` range**: Current code `8 + randi() % 3` yields 8-10 (since `% 3` gives 0-2). Functional but unconventional — `randi() % 4` giving 0-3 is more idiomatic for "0 to N-1" range. No functional defect.

2. **Death particle parent lifecycle**: `spawn_death()` uses `get_parent()` which resolves at call time. If `enemy_died` is emitted just before `queue_free()` on the enemy, `get_parent()` still returns a valid reference at that moment. The risk table correctly identifies this but the mitigation (spawning to longer-lived parent) is sound in practice because the parent scene outlives individual enemies. Low concern.

3. **Fade timing comment**: Line 126 says "until 70% of lifetime, then linear fade" but code calculates `fade_ratio` as a ratio of the fade window, not explicitly the 70% threshold comment. Logic is correct; comment slightly imprecise.

---

## Risks Evaluated

| Risk | Assessment |
|------|-------------|
| Particles killed if parent freed | Low — `get_parent()` targets main scene or intermediate node that outlives attacks |
| Performance from many particles | Low — 5-10 per event, simple `_draw()` call |
| Particles render behind nodes | Low — spawn order determines draw order; can adjust z_index if needed |

All risks are LOW per plan, which is consistent with this reviewer's assessment.

---

## Blockers

None. All dependencies satisfied by CORE-005 (done/trusted).

---

## Recommendation

**Proceed to implementation.** Plan is sound, criteria are covered, patterns are correct for Godot 4.6. The specialist may proceed with `hit_particle.gd` creation and integration into the three existing attack/damage scripts.
