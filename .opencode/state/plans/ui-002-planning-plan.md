# Planning Artifact — UI-002: Game Over Screen with Score and Restart

## 1. Overview and Goal

Create the game over screen as a CanvasLayer within the main scene. The screen displays "GAME OVER" text, the final score, and a RESTART button. It is visible only when the game state is `GAME_OVER`. Pressing RESTART resets all game state (HP, score, wave) and transitions back to `TITLE`.

**Pattern**: Follow the same structure as `title_screen.gd` (CanvasLayer with dark background, centered Label, Button).

---

## 2. Files to Create / Modify

| File | Action | Purpose |
|------|--------|---------|
| `scripts/game_over_screen.gd` | **CREATE** | Game over screen CanvasLayer script |
| `scenes/main.tscn` | **MODIFY** | Add GameOverScreen as a child CanvasLayer node |
| `scripts/main.gd` | **MODIFY** | Add `_show_game_over_screen()` / `_hide_game_over_screen()` helper methods; add `_reset_game()` method; wire RESTART button to reset + TITLE transition |

---

## 3. Step-by-Step Implementation Plan

### Step 1 — Create `scripts/game_over_screen.gd`
- Extend `CanvasLayer`
- Create a dark `ColorRect` background (same `BG_COLOR = Color(0.0, 0.0, 0.0, 0.85)` as title screen)
- Create "GAME OVER" Label centered on screen with large font (72pt, white)
- Create score display Label below "GAME OVER" showing "Score: X"
- Create RESTART Button below score
- RESTART button calls `main._reset_game()` which resets state and calls `_change_state(TITLE)`
- Implement `show_game_over()` and `hide_game_over()` methods to control visibility
- Game over screen starts hidden (`visible = false`)

### Step 2 — Modify `scenes/main.tscn`
- Add new node: `[node name="GameOverScreen" type="CanvasLayer" parent="."]`
- Reference the new `game_over_screen.gd` script

### Step 3 — Modify `scripts/main.gd`

#### 3a. Add helper methods for game over screen visibility:
```gdscript
func _show_game_over_screen() -> void:
    var game_over_screen = get_node_or_null("GameOverScreen")
    if game_over_screen and game_over_screen.has_method("show_game_over"):
        game_over_screen.show_game_over()

func _hide_game_over_screen() -> void:
    var game_over_screen = get_node_or_null("GameOverScreen")
    if game_over_screen and game_over_screen.has_method("hide_game_over"):
        game_over_screen.hide_game_over()
```

#### 3b. Update `_change_state()` match arm for `GAME_OVER`:
```gdscript
GameState.GAME_OVER:
    _trigger_game_over()
    _show_game_over_screen()
```

#### 3c. Add `_reset_game()` method:
```gdscript
func _reset_game() -> void:
    # Reset player HP to 3
    var player = get_node_or_null("Player")
    if player and player.has_method("reset_health"):
        player.reset_health()
    
    # Reset wave spawner state
    var wave_spawner = get_node_or_null("WaveSpawner")
    if wave_spawner:
        wave_spawner.score = 0
        wave_spawner.wave_number = 0
        wave_spawner.enemies_alive = 0
        # Clear existing enemies from scene
        _clear_enemies()
        # Reset wave spawner
        wave_spawner.start_next_wave()
    
    # Clear any existing player and joystick
    if has_node("Player"):
        $Player.queue_free()
    if has_node("VirtualJoystick"):
        $VirtualJoystick.queue_free()
    
    # Clear HUD
    if has_node("HUD"):
        $HUD.queue_free()
```

#### 3d. Add `_clear_enemies()` helper:
```gdscript
func _clear_enemies() -> void:
    # Remove all enemies from scene by type name
    var children = get_children()
    for child in children:
        if child is EnemyBase:
            child.queue_free()
```

#### 3e. Add `restart_game()` method called by RESTART button:
```gdscript
func restart_game() -> void:
    _reset_game()
    _hide_game_over_screen()
    _change_state(GameState.TITLE)
```

### Step 4 — Verify Player Has `reset_health()` Method
- Check `scripts/player.gd` for existing reset mechanism
- If not present, add:
```gdscript
func reset_health() -> void:
    current_hp = max_health
    health_changed.emit(current_hp)
```

### Step 5 — Verify Wave Spawner Restart
- Ensure `wave_spawner.gd` can restart cleanly: `start_next_wave()` resets wave_number and spawns
- May need to call `wave_spawner.start_next_wave()` after resetting

---

## 4. Validation Plan

### Static Verification
1. `scripts/game_over_screen.gd` exists and has:
   - `extends CanvasLayer`
   - Dark background `ColorRect`
   - "GAME OVER" Label with large font (72pt)
   - Score Label
   - RESTART Button
   - `show_game_over()` / `hide_game_over()` methods
   - Button connects to `main.restart_game()`
2. `scenes/main.tscn` has `GameOverScreen` CanvasLayer child with script reference
3. `scripts/main.gd` has:
   - `_show_game_over_screen()` / `_hide_game_over_screen()` helpers
   - `_reset_game()` method
   - `restart_game()` method
   - Updated `_change_state()` with GAME_OVER → `_show_game_over_screen()`
   - `restart_game()` called from GAME_OVER state

### Smoke Test
- `godot4 --headless --path . --quit` exits cleanly (0)
- If godot4 unavailable, `find . -name "*.gd" | xargs grep -l "game_over_screen\|GameOverScreen\|restart_game"` confirms files exist

---

## 5. Acceptance Criteria Mapping

| # | Criterion | Implementation | Verification |
|---|----------|----------------|--------------|
| 1 | Game over screen is a CanvasLayer child of the main scene, visible in GAME_OVER state | `scenes/main.tscn` adds GameOverScreen CanvasLayer; `main.gd` `_change_state(GAME_OVER)` calls `_show_game_over_screen()` | File check + smoke test |
| 2 | "GAME OVER" Label centered with large font | `game_over_screen.gd` creates Label with `HORIZONTAL_ALIGNMENT_CENTER`, `VERTICAL_ALIGNMENT_CENTER`, font_size 72 | Static file check |
| 3 | Final score displayed below game over text | `game_over_screen.gd` creates score Label below title; score comes from `wave_spawner.score` | File check |
| 4 | RESTART button below score, responds to touch/press | `game_over_screen.gd` Button with `offset_top` below score Label; `connect("pressed", ...)` | File check |
| 5 | Pressing RESTART resets all game state and transitions to TITLE | `main.gd` `restart_game()` resets HP, score, wave, clears enemies, calls `_change_state(TITLE)` | Static check of reset logic |
| 6 | No imported assets — default font and procedural styling only | All UI uses Godot default font; `add_theme_font_size_override`, `add_theme_color_override`; no `load()` of external files | File grep check |

---

## 6. Risks and Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Player `reset_health()` method does not exist | Low | Medium | Check player.gd; add method if missing |
| Wave spawner restart leaves orphaned enemies | Medium | Medium | `_clear_enemies()` loops all children, queues free EnemyBase instances |
| Score Label shows stale value (not live update) | Low | Low | Game over screen reads score at show time; score is final |
| Restart transitions too quickly before cleanup | Low | Low | `queue_free()` is deferred; `_change_state(TITLE)` called after `_reset_game()` completes |

---

## 7. Dependencies

- **SETUP-001** (done): Main scene with `GameState` enum and `_change_state()` exists
- **UI-001** (done): Title screen pattern provides reference implementation for CanvasLayer UI
- **CORE-003** (done): Wave spawner tracks `score` and `wave_number`
- **CORE-005** (done): Player `health_changed` signal and `current_hp` exist

---

## 8. Non-Blocking Notes

- Score display reads from `wave_spawner.score` at the time game over screen is shown — this is the final score, not a live-updating value, which is correct behavior for a game over screen
- The "Score X" label format matches the HUD "Score X" format for consistency
- Wave spawner auto-starts on `start_next_wave()` call, which is correct for fresh game start
