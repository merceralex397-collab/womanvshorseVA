# Plan Review: CORE-005 — Implement collision and damage system

## Verdict: APPROVED with Notes

The plan correctly identifies all 6 acceptance criteria and provides a sound implementation approach using existing Godot 4 infrastructure. Three non-blocking observations are documented below for the implementer.

---

## Findings by Acceptance Criterion

### AC-1: Player melee arc and projectiles damage enemies on Area2D body_entered (layer 3 vs layer 2)
**Status: COVERED**

- `melee_arc.gd` has `collision_layer = 3` and `collision_mask = 2` already set in `_ready()` (lines 9-10), but `body_entered` signal is NOT connected — plan correctly identifies this gap
- `projectile.gd` is an Area2D with no signal wiring at all — plan correctly identifies this gap
- Both `_on_hit_enemy(body: Node2D)` handlers use `has_method("take_damage")` guard before calling damage, which is defensive and correct
- `queue_free()` on projectile after hit prevents repeated damage — correct

### AC-2: Enemy contact with player deals 1 damage (layer 2 vs layer 1)
**Status: COVERED**

- Plan correctly identifies the need for an Area2D child node on player since CharacterBody2D has no built-in overlap detection
- Contact sensor uses `collision_layer = 1` (Player) and `collision_mask = 2` (Enemies) — correct per spec
- Shape radius of 20.0 is small relative to player body (30×40) — recommend increasing to ~25-30 for better feel, but not a blocker
- `_on_enemy_contact()` checks `_is_invincible` before dealing damage — correct

### AC-3: Player has ~0.5s invincibility after taking damage with visual flash
**Status: COVERED**

- `INVINCIBILITY_DURATION = 0.5` matches "~0.5s" requirement
- `_is_invincible` flag checked in `_on_enemy_contact()` prevents repeated damage during window
- Timer decremented in `_physics_process()` — appropriate for CharacterBody2D
- Visual flash via modulate tween (see AC-6)

### AC-4: Score increments by enemy point value on kill (brown=10, black=20, war=50, boss=100)
**Status: COVERED (delegated to existing infrastructure)**

- `wave_spawner.gd` already implements `_point_values` dictionary with correct values (lines 14-19): brown=10, black=20, war=50, boss=100
- `_on_enemy_died()` increments score and emits `score_changed` signal (lines 102-107)
- HUD is already connected to `score_changed` in `main.gd:_setup_hud()` (lines 74-75)
- **Observation:** Current wave spawner only creates brown, black, and boss enemy types — no "war" type is spawned. CORE-006 (enemy variants) is meant to add the war horse. Score will correctly use default 10 for any unknown type.

### AC-5: Game state transitions to GAME_OVER when player HP reaches 0
**Status: COVERED**

- `take_damage()` in plan replaces current `get_tree().quit()` with proper state transition
- `_trigger_game_over()` uses `/root/Main` path to call `main._change_state(GameState.GAME_OVER)`
- `main.gd` has `GameState.GAME_OVER` case (line 29) which currently does nothing — plan's suggestion to stop wave spawner is appropriate
- **Note:** `main.gd` GAME_OVER case (line 29-30) is empty — implementer should add wave spawner stop and player freeze there

### AC-6: Damage flash uses modulate tween (white flash → normal in 0.15s)
**Status: COVERED with implementation note**

- `DAMAGE_FLASH_DURATION = 0.15` matches the 0.15s requirement
- `_flash_damage()` sequence: sets `modulate = Color(2.0, 2.0, 2.0)` (overbright) then tweens to `Color.WHITE` (1.0, 1.0, 1.0)
- **Implementation note:** The flash goes from overbright → normal white (2.0 → 1.0), which produces a visible "bright flash fading to normal" effect. This is functionally correct even though the starting point is brighter than the tween target.
- **Minor issue:** `_physics_process()` also sets `modulate = Color.WHITE` at end of invincibility (line 139). If the flash tween is still running when invincibility ends, this could cause a visual jump. Recommend canceling any existing tween before starting a new one using `tween.kill()` or using a single tween for the entire sequence.

---

## Gaps

1. **GODOT-4 CONNECT STYLE (low):** Plan uses Godot 3 `connect("signal", method)` shorthand. Godot 4 prefers explicit `Callable`: `connect("body_entered", Callable(self, "_on_hit_enemy"))`. Both work in Godot 4.6, but explicit Callable is more idiomatic and self-documenting.

2. **GAME_OVER case is empty in main.gd (medium-low):** The plan references stopping wave spawner in GAME_OVER but `main.gd` lines 29-30 show the case is `pass`. This needs actual implementation.

3. **Contact sensor shape radius (low):** Radius of 20.0 may miss enemy contact at edges. Consider 25-30 for better hit detection reliability.

4. **Tween cancellation (low):** If `_flash_damage()` is called while a previous tween is still running, the new tween will override but start from current value (2.0) rather than normal white. Recommend `tween.kill()` before creating new one, or track and reset modulate before each flash.

---

## Recommendations (Non-Blocking)

1. **Before creating tween in `_flash_damage()`:** Kill any existing tween to ensure clean state
   ```gdscript
   func _flash_damage() -> void:
       modulate = Color(2.0, 2.0, 2.0)
       var tween := create_tween()
       tween.kill()  # Cancel any running tween first
       tween = create_tween()
       tween.tween_property(self, "modulate", Color.WHITE, DAMAGE_FLASH_DURATION)
   ```

2. **Implement GAME_OVER case in `main.gd`:**
   ```gdscript
   GameState.GAME_OVER:
       if has_node("WaveSpawner"):
           $WaveSpawner.set_physics_process(false)
       if has_node("Player"):
           $Player.set_physics_process(false)
   ```

3. **Increase contact sensor radius to 25-30** for more reliable enemy contact detection.

---

## Risk Assessment

| Risk | Likelihood | Impact | Assessment |
|------|------------|--------|------------|
| Area2D conflicts with CharacterBody2D movement | Low | Medium | Area2D is sensor-only (no physics body) — safe |
| Double damage on single attack | Low | Low | `queue_free()` on projectile; invincibility on player |
| Enemy `take_damage()` idempotency | Low | Low | Already handles death/queue_free internally |
| GAME_OVER path access via `/root/Main` | Low | Low | Works for current scene structure |

---

## Summary

**Plan is APPROVED.** All 6 acceptance criteria have clear implementation paths. The approach leverages existing infrastructure correctly (wave_spawner score system, HUD signals, enemy take_damage). The three observations above are guidance for the implementer, not blockers.

---

*Review generated: 2026-04-10*
*Reviewer: wvhva-team-leader*
