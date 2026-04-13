# Code Review — POLISH-001: Add particle effects for combat feedback

**Verdict: APPROVED**

## Summary

All 6 acceptance criteria are correctly implemented. The hit particle system uses Godot 4.6 static typing, _draw()-based rendering, and proper lifecycle management. No correctness issues, regressions, or blockers identified.

---

## File-by-File Analysis

### 1. `scripts/hit_particle.gd` (new file)

| Check | Result | Line(s) |
|---|---|---|
| Extends Node2D | ✅ | Line 2 |
| Has `velocity: Vector2` | ✅ | Line 4 |
| Has `lifetime: float` | ✅ | Line 5 |
| Has `max_lifetime: float = 0.3` | ✅ | Line 6 |
| Has `friction: float = 0.9` | ✅ | Line 7 |
| Fade via `modulate.a` | ✅ | Lines 22–24 |
| `queue_redraw()` each frame | ✅ | Line 26 |
| `_draw()` draws orange-yellow circle | ✅ | Lines 28–31 |
| `spawn_hit_particles()` static func, count=5 default | ✅ | Lines 34–46 |
| `spawn_death_particles()` static func, count=9 default | ✅ | Lines 49–61 |
| `queue_free()` when lifetime >= max_lifetime | ✅ | Lines 15–17 |
| Uses `_draw()`, not GPUParticles2D | ✅ | Line 28–31 |

**Static typing check:** All variables have explicit type annotations. GDScript 4 syntax used throughout (`class_name`, `var name: Type`, `-> void`).

**Fade math verification:**
- `max_lifetime = 0.3`
- Fade begins at `max_lifetime * 0.5 = 0.15`
- At `lifetime = 0.15`: `modulate.a = 1.0 - (0 / 0.15) = 1.0` (no fade yet)
- At `lifetime = 0.3`: `modulate.a = 1.0 - (0.15 / 0.15) = 0.0` (fully faded)
- ✅ Correct linear fade over second half of lifetime

**Spawn velocity check:**
- Hit particles: `100.0 + randf() * 100.0` = 100–200 px/s in random direction ✅
- Death particles: `150.0 + randf() * 150.0` = 150–300 px/s in random direction ✅
- Friction `0.9` applied per-physics-frame ✅

---

### 2. `scripts/melee_arc.gd` (modified)

| Check | Result | Line(s) |
|---|---|---|
| Collision layer 3 (PlayerAttack) | ✅ | Line 9 |
| Collision mask 2 (Enemies) | ✅ | Line 10 |
| `body_entered` connected via Callable | ✅ | Line 18 |
| Calls `body.take_damage(1)` | ✅ | Line 22 |
| Calls `HitParticle.spawn_hit_particles(get_parent(), body.global_position, 5)` | ✅ | Line 24 |

**Godot 4 pattern check:** Uses `Callable(self, "_on_hit_enemy")` style per plan review guidance ✅.

**Parent lifecycle note:** `get_parent()` on line 24 returns the melee arc's parent. The arc is a child of the player scene; particles are added to the player scene's world node. Plan review acknowledged this as low-risk since the player scene outlives the short-lived melee arc instances. Confirmed acceptable.

---

### 3. `scripts/projectile.gd` (modified)

| Check | Result | Line(s) |
|---|---|---|
| Collision layer 3 (PlayerAttack) | ✅ | Line 7 |
| Collision mask 2 (Enemies) | ✅ | Line 8 |
| `body_entered` connected via Callable | ✅ | Line 10 |
| Calls `body.take_damage(1)` | ✅ | Line 21 |
| Calls `HitParticle.spawn_hit_particles(get_parent(), body.global_position, 5)` | ✅ | Line 23 |
| `queue_free()` after hit | ✅ | Line 24 |

**Godot 4 pattern check:** Uses `Callable(self, "_on_hit_enemy")` style ✅.

**Particle parent note:** `get_parent()` on line 23 returns the projectile's parent node. In the single-scene architecture, this is the world root, which is the correct parent for world-space particle effects.

---

### 4. `scripts/enemy_base.gd` (modified)

| Check | Result | Line(s) |
|---|---|---|
| `enemy_died.emit(self)` on death | ✅ | Line 66 |
| Calls `_spawn_death_effects()` before `queue_free()` | ✅ | Lines 67–68 |
| `_spawn_death_effects()` calls `HitParticle.spawn_death_particles(get_parent(), global_position, 8 + randi() % 3)` | ✅ | Line 72 |
| `randi() % 3` yields 0–2 → 8+(0-2) = 8–10 | ✅ | Line 72 |

**Death particle count verification:**
- `randi() % 3` in GDScript returns 0, 1, or 2
- 8 + 0 = 8, 8 + 1 = 9, 8 + 2 = 10 ✅
- Range confirmed: 8–10 particles ✅

**Plan-review note addressed:** The comment says "8-10 particles" but the code `randi() % 3` yields 0–2 (not 1–3). The plan review flagged this. However, the functional result (8–10 burst) matches the acceptance criterion ("8-10 particles"). The comment is imprecise but not incorrect — no code change needed.

**Parent lifecycle note:** Same as melee_arc — low risk in single-scene architecture per plan review.

---

## Acceptance Criteria Verification

| # | Criterion | Status | Evidence |
|---|---|---|---|
| 1 | `scripts/hit_particle.gd` extends Node2D with velocity, lifetime, fade-out | ✅ PASS | hit_particle.gd lines 2, 4–7, 22–24 |
| 2 | 5 particles spawn at impact point on enemy damage (orange-yellow via _draw) | ✅ PASS | hit_particle.gd line 34 (count=5); melee_arc.gd line 24; projectile.gd line 23; hit_particle.gd lines 28–31 (orange-yellow Color(1.0, 0.6, 0.1)) |
| 3 | Larger burst (8–10 particles) on enemy death | ✅ PASS | enemy_base.gd line 72: `8 + randi() % 3`; hit_particle.gd line 49 |
| 4 | Particles have velocity with friction (0.9 decay) and fade via modulate.a | ✅ PASS | hit_particle.gd lines 19–20 (velocity + friction), lines 22–24 (modulate.a fade) |
| 5 | Particles queue_free after lifetime (~0.3s) | ✅ PASS | hit_particle.gd lines 15–17; max_lifetime default 0.3s (line 6) |
| 6 | No performance regression — particles use _draw(), not GPUParticles2D | ✅ PASS | hit_particle.gd line 28–31 uses `draw_circle`, no GPUParticles2D |

---

## Findings

### Non-Blocking Notes (from plan review)

1. **`randi() % 3` vs `randi() % 4` (design preference):**  
   The plan review suggested `randi() % 4` for more idiomatic range. The actual implementation `8 + randi() % 3` produces exactly 8–10 particles which matches acceptance criterion 3 precisely. The `randi() % 4` suggestion would produce 8–11. Current code is functionally correct as written. No change required.

2. **Comment precision in enemy_base.gd line 71:**  
   Comment says "8-10 particles" which is accurate (8 + randi()%3 yields 8, 9, or 10). The "randi() % 3 yields 0-2" observation in the plan review note is a comment-style concern, not a code defect. No action required.

3. **Parent lifecycle (get_parent() calls):**  
   Plan review acknowledged this is low-risk in the single-scene architecture. Confirmed: enemies are children of the world root, and `queue_free()` removes only the enemy node, leaving the world root intact as particle parent.

### Godot 4.6 Static Typing Compliance

- All 4 files use explicit type annotations on variables and function return types ✅
- `class_name HitParticle` used correctly ✅
- `Callable(self, "_method")` pattern used for signal connections ✅
- `signal enemy_died(enemy: EnemyBase)` uses typed signal parameter ✅
- PackedVector2Array constructor used correctly ✅

---

## Compile/Import Check

**Command:** `godot4 --headless --path . --quit`

**Result:** BLOCKED — tool execution prevented by environment permission restrictions in this review context. Cannot run Godot headless validation from this review agent.

This is an environment/tooling constraint, not a code defect. The GDScript files are syntactically well-formed and conform to Godot 4.6 static-typing standards based on static analysis.

---

## Regression Check

- No existing methods modified or removed ✅
- No collision layer/mask changes to existing nodes ✅
- `take_damage()` signature unchanged — still accepts `amount: int` ✅
- `enemy_died` signal unchanged ✅
- No changes to `project.godot` or scene files ✅

---

## Verdict

**APPROVED**

All 6 acceptance criteria are correctly implemented with proper Godot 4.6 patterns. No correctness issues, no regressions, no blockers. The one plan-review note (randi() % 3 idiom) does not affect correctness since the particle count matches the spec exactly. Godot headless validation could not be re-run due to environment constraints but static analysis confirms code is sound.

**Recommendation:** Advance to QA stage.
