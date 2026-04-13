# Review Artifact — UI-002: Game Over Screen with Score and Restart

## Verdict: APPROVED

All 6 acceptance criteria pass. Implementation is correct, follows Godot 4.6 patterns, and introduces no regressions.

---

## Acceptance Criteria Findings

### AC-1: Game over screen is a CanvasLayer child of the main scene, visible in GAME_OVER state

**Status: PASS**

- `scenes/main.tscn` lines 18-19: `GameOverScreen` node defined as `type="CanvasLayer"` with `script = ExtResource("5_gameoverscreen")`
- `scripts/main.gd` lines 30-32: `_change_state(GameState.GAME_OVER)` calls `_trigger_game_over()` then `_show_game_over_screen()`
- `game_over_screen.gd` line 85: `visible = true` in `show_game_over()`

**Evidence:**
```gdscript
# main.gd:30-32
GameState.GAME_OVER:
    _trigger_game_over()
    _show_game_over_screen()
```
```gdscript
# game_over_screen.gd:83-85
func show_game_over(final_score: int) -> void:
    score_label.text = "Score: %d" % final_score
    visible = true
```

---

### AC-2: 'GAME OVER' Label centered with large font

**Status: PASS**

- `scripts/game_over_screen.gd` lines 36-49: `title_label` created with:
  - `horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER`
  - `vertical_alignment = VERTICAL_ALIGNMENT_CENTER`
  - `set_anchors_preset(Control.PRESET_CENTER)`
  - `add_theme_font_size_override("font_size", 72)` — large font
  - `add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))` — white

**Evidence:**
```gdscript
# game_over_screen.gd:36-49
title_label = Label.new()
title_label.name = "GameOverLabel"
title_label.text = GAME_OVER_TEXT
title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
title_label.set_anchors_preset(Control.PRESET_CENTER)
title_label.add_theme_font_size_override("font_size", 72)
```

---

### AC-3: Final score displayed below game over text

**Status: PASS**

- `scripts/game_over_screen.gd` lines 52-65: `score_label` created with `offset_top = -20` (below title's `offset_top = -150`)
- `show_game_over(final_score: int)` updates `score_label.text` with `"Score: %d" % final_score`
- Score label positioned below title via vertical offset

**Evidence:**
```gdscript
# game_over_screen.gd:52-65 (score_label) vs 36-45 (title_label)
# title_label: offset_top = -150, offset_bottom = -50
# score_label: offset_top = -20, offset_bottom = 30  ← below title

func show_game_over(final_score: int) -> void:
    score_label.text = "Score: %d" % final_score
    visible = true
```

---

### AC-4: RESTART button below score, responds to touch/press

**Status: PASS**

- `scripts/game_over_screen.gd` lines 68-78: `restart_button` created with `offset_top = 60` (below score's `offset_bottom = 30`)
- Signal connection: `restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))`
- `_on_restart_pressed()` emits `restart_pressed` signal

**Evidence:**
```gdscript
# game_over_screen.gd:68-81
restart_button.offset_top = 60
restart_button.offset_bottom = 130
restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))

func _on_restart_pressed() -> void:
    restart_pressed.emit()
```

---

### AC-5: Pressing RESTART resets all game state and transitions to TITLE

**Status: PASS**

- `main.gd` lines 52-53: `restart_pressed.is_connected()` duplicate guard before connecting to `restart_game`
- `restart_game()` (lines 103-106) calls: `_reset_game()` → `_hide_game_over_screen()` → `_change_state(GameState.TITLE)`
- `_reset_game()` (lines 73-94) resets:
  - Enemies via `_clear_enemies()`
  - Player and VirtualJoystick nodes
  - HUD
  - Wave spawner (score=0, wave_number=0, enemies_alive=0, physics_process re-enabled)

**Evidence:**
```gdscript
# main.gd:52-53 (signal connection with guard)
if not game_over_screen.restart_pressed.is_connected(Callable(self, "restart_game")):
    game_over_screen.restart_pressed.connect(Callable(self, "restart_game"))

# main.gd:103-106 (restart sequence)
func restart_game() -> void:
    _reset_game()
    _hide_game_over_screen()
    _change_state(GameState.TITLE)

# main.gd:73-94 (_reset_game implementation)
func _reset_game() -> void:
    _clear_enemies()
    if has_node("Player"): $Player.queue_free()
    if has_node("VirtualJoystick"): $VirtualJoystick.queue_free()
    if has_node("HUD"): $HUD.queue_free()
    var wave_spawner = get_node_or_null("WaveSpawner")
    if wave_spawner:
        wave_spawner.score = 0
        wave_spawner.wave_number = 0
        wave_spawner.enemies_alive = 0
        wave_spawner.set_physics_process(true)
        wave_spawner.set_process(true)
```

**Game State Reset Sequence (correct order):**
1. `_reset_game()` clears enemies, player, joystick, HUD, resets wave spawner
2. `_hide_game_over_screen()` hides the canvas layer
3. `_change_state(GameState.TITLE)` transitions to title

Note: Player HP is not explicitly reset in `_reset_game()`. Since the player node is `queue_free()`'d and recreated via `_spawn_player_and_joystick()` on state change to PLAYING, the new player will have default HP. This is acceptable because the player object is destroyed and recreated fresh, and the new player uses default exported values (HP=3).

---

### AC-6: No imported assets — default font and procedural styling only

**Status: PASS**

- All font sizes use `add_theme_font_size_override("font_size", ...)`
- All colors use `add_theme_color_override("font_color", ...)`
- `ColorRect` used for background
- No `load()` calls for external files
- No `preload()` calls

**Evidence:**
```gdscript
# game_over_screen.gd:47-48, 63-64, 76
title_label.add_theme_font_size_override("font_size", 72)
title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
score_label.add_theme_font_size_override("font_size", 32)
restart_button.add_theme_font_size_override("font_size", 48)
```

---

## Godot 4.6 Static Typing Verification

| Pattern | Location | Status |
|---------|----------|--------|
| `_ready() -> void` | game_over_screen.gd:21 | PASS |
| `Callable()` for signal | main.gd:52-53, game_over_screen.gd:77 | PASS |
| `Color(1.0, 1.0, 1.0, 1.0)` typed color | game_over_screen.gd:8, 48, 64 | PASS |
| `enum GameState` | main.gd:4 | PASS |

---

## Signal Connection Pattern

**Duplicate guard pattern used correctly:**
```gdscript
# main.gd:52-53
if not game_over_screen.restart_pressed.is_connected(Callable(self, "restart_game")):
    game_over_screen.restart_pressed.connect(Callable(self, "restart_game"))
```

This prevents double-connection if `_show_game_over_screen()` is called multiple times during the same GAME_OVER state (e.g., if state machine has a race condition or re-triggers).

---

## Non-Blocking Notes

1. **Player HP reset**: The player HP is not explicitly reset in `_reset_game()` because the player node is destroyed and recreated. New player instances use default `@export` HP value of 3. This is functionally correct but relies on the re-spawn mechanism.

2. **Smoke test warnings**: The implementation artifact notes pre-existing script warnings in `hud.gd` and `wave_spawner.gd` related to draw/viewport methods in headless mode. These are non-fatal and identical to those seen in UI-001 (which passed smoke test with exit code 0).

3. **Wave spawner reset completeness**: `wave_spawner.wave_number = 0` means the next wave will start from wave 1 (since wave 1 is started when `wave_number == 0` triggers initial wave). This matches the expected restart behavior.

---

## Summary

All 6 acceptance criteria pass. Implementation is clean, follows Godot 4.6 patterns, and introduces no regressions to existing code. The game over screen correctly displays, the restart flow properly resets all game state, and no imported assets are used.
