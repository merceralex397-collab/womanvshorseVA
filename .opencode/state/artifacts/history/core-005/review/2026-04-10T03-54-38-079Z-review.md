# Code Review: CORE-005 — Implement collision and damage system

**Ticket:** CORE-005  
**Stage:** review  
**Date:** 2026-04-10  
**Result:** APPROVED

---

## Verdict Summary

All 6 acceptance criteria verified and correctly implemented. No regressions detected. Implementation follows Godot 4 patterns and all plan-review recommendations were applied.

---

## Acceptance Criteria Verification

### Criterion 1: Player melee arc and projectiles damage enemies on Area2D body_entered (layer 3 vs layer 2)

**Status: PASS**

| File | Finding |
|------|---------|
| `melee_arc.gd` line 9 | collision_layer = 3 (PlayerAttack) |
| `melee_arc.gd` line 10 | collision_mask = 2 (Enemies) |
| `melee_arc.gd` line 18 | `body_entered.connect(Callable(self, "_on_hit_enemy"))` — uses Callable style |
| `melee_arc.gd` line 20-22 | `_on_hit_enemy` calls `body.take_damage(1)` if method exists |
| `projectile.gd` line 7-8 | collision_layer = 3, collision_mask = 2 |
| `projectile.gd` line 10, 19-22 | Same pattern, body.take_damage(1) on hit, then queue_free() |

### Criterion 2: Enemy contact with player deals 1 damage (layer 2 vs layer 1)

**Status: PASS**

| File | Finding |
|------|---------|
| `player.gd` line 41-42 | `_contact_sensor` with collision_mask = 2 (Enemies layer only) |
| `player.gd` line 45 | CircleShape2D radius = 27.0 (within recommended 25-30 range) |
| `player.gd` line 52 | `body_entered.connect(Callable(self, "_on_contact_enemy"))` — Callable style confirmed |
| `player.gd` line 114-117 | `_on_contact_enemy` guards with `not _is_invincible` before calling `take_damage(1)` |

### Criterion 3: Player has ~0.5s invincibility after taking damage with visual flash

**Status: PASS**

| File | Finding |
|------|---------|
| `player.gd` line 12 | `_invincibility_duration: float = 0.5` (exactly 0.5s as specified) |
| `player.gd` line 56-59 | `_physics_process` decrements `_invincibility_timer` and clears `_is_invincible` when timer reaches 0 |
| `player.gd` line 131-140 | `take_damage` sets `_is_invincible = true`, starts timer, emits `health_changed`, calls `_flash_damage()` |
| `player.gd` line 136-137 | Invincibility correctly resets on each hit |

### Criterion 4: Score increments by enemy point value on kill (brown=10, black=20, war=50, boss=100)

**Status: PASS**

| File | Finding |
|------|---------|
| `wave_spawner.gd` line 14-19 | `_point_values` dictionary: "brown":10, "black":20, "war":50, "boss":100 — matches spec exactly |
| `wave_spawner.gd` line 106 | `score += _point_values.get(enemy.type, 10)` — uses .get() with fallback 10 |
| `wave_spawner.gd` line 107 | `score_changed.emit(score)` — HUD updates via signal |

### Criterion 5: Game state transitions to GAME_OVER when player HP reaches 0

**Status: PASS**

| File | Finding |
|------|---------|
| `player.gd` line 141-142 | `if hp <= 0: player_died.emit()` — death signal emitted at 0 HP |
| `main.gd` line 68-69 | `player.connect("player_died", Callable(self, "_on_player_died"))` — uses Callable style |
| `main.gd` line 46-47 | `_on_player_died` calls `_change_state(GameState.GAME_OVER)` |
| `main.gd` line 29-30 | `_change_state` match case for GAME_OVER calls `_trigger_game_over()` |
| `main.gd` line 33-44 | `_trigger_game_over()` freezes wave_spawner (set_physics_process/set_process false) and player (same) |

### Criterion 6: Damage flash uses modulate tween (white flash → normal in 0.15s)

**Status: PASS**

| File | Finding |
|------|---------|
| `player.gd` line 119-129 | `_flash_damage()` creates two sequential tweens: 0.075s to bright + 0.075s back = 0.15s total |
| `player.gd` line 120-122 | Tween cancellation: `if has_node("Tween"): $Tween.kill()` — kills existing before creating new |
| `player.gd` line 126 | First tween: `modulate` → Color(1.5, 1.5, 1.5, 1.0) (bright white flash) |
| `player.gd` line 127 | Second tween: `modulate` → Color.WHITE with 0.075 delay |
| `player.gd` line 129 | Callback ensures `modulate = Color.WHITE` after sequence |

---

## Plan Review Notes Verification

| Note | Status | Implementation |
|------|--------|----------------|
| Tween cancellation in `_flash_damage()` | ✓ Implemented | `player.gd` lines 120-122 |
| GAME_OVER case in main.gd | ✓ Implemented | `main.gd` lines 33-44 with wave spawner freeze + player freeze |
| Contact sensor radius 25-30 | ✓ Implemented | `player.gd` line 45: radius = 27.0 |
| Callable(self, "_on_*") signal style | ✓ Implemented | All signal connections: player.gd:52, main.gd:69, projectile.gd:10, melee_arc.gd:18 |

---

## Godot 4 Pattern Compliance

- All signal connections use `Callable(self, "method")` style
- Static typing used throughout (`func _ready() -> void:`)
- `create_tween()` used with parallel set (correct Godot 4 pattern)
- `set_physics_process(false)` and `set_process(false)` used for freeze (correct)
- `modulate` property tweened correctly (property path passed as Node reference)
- `if has_node("Tween"): $Tween.kill()` pattern works because `create_tween()` auto-creates named Tween child

---

## Regression Risks

| Risk | Assessment |
|------|-----------|
| Enemy queue_free during signal handler | Low — wave_spawner._on_enemy_died decrements enemies_alive before wave check |
| Invincibility race conditions | None — _is_invincible checked in both _on_contact_enemy and take_damage |
| Tween overwriting | Low — existing tween killed before new one created |

---

## Files Reviewed

| File | Path |
|------|------|
| player.gd | `scripts/player.gd` |
| projectile.gd | `scripts/projectile.gd` |
| melee_arc.gd | `scripts/melee_arc.gd` |
| main.gd | `scripts/main.gd` |
| wave_spawner.gd | `scripts/wave_spawner.gd` (context) |
| enemy_base.gd | `scripts/enemy_base.gd` (context) |

---

## Conclusion

**APPROVED** — All 6 acceptance criteria correctly implemented. All 4 plan-review recommendations applied. No regressions detected. Implementation is ready to advance to QA stage.