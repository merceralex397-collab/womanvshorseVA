# Plan Review — UI-002: Game Over Screen with Score and Restart

## Verdict: APPROVED

---

## Review Summary

The planning artifact for UI-002 is well-structured, follows the existing title_screen.gd pattern, and provides a complete implementation roadmap. All 6 acceptance criteria are addressed with appropriate verification mapping. The plan correctly handles game state reset, Godot 4.6 static typing patterns, and the deferred-readiness concern about `restart_game()` method additions.

---

## Findings by Acceptance Criterion

### Criterion 1: Game over screen is a CanvasLayer child of the main scene, visible in GAME_OVER state

**Status: COVERED**

- `game_over_screen.gd` extends `CanvasLayer` (Step 3)
- `scenes/main.tscn` modification adds `GameOverScreen` as CanvasLayer child (Step 2)
- `main.gd` `_change_state(GAME_OVER)` will call `_show_game_over_screen()` (Step 3b)
- Visibility controlled via `show_game_over()` / `hide_game_over()` methods (Step 1, 3a)

**Note**: The current `main.gd` `_change_state()` GAME_OVER arm only calls `_trigger_game_over()`. The plan correctly identifies that `_show_game_over_screen()` must be added to that match arm.

---

### Criterion 2: "GAME OVER" Label centered with large font

**Status: COVERED**

- Label with `HORIZONTAL_ALIGNMENT_CENTER`, `VERTICAL_ALIGNMENT_CENTER` (Step 1)
- `font_size = 72` (Step 1)
- Uses Godot default font with `add_theme_font_size_override` (matches title_screen.gd pattern)

---

### Criterion 3: Final score displayed below game over text

**Status: COVERED**

- `game_over_screen.gd` creates score Label below "GAME OVER" showing "Score: X" (Step 1)
- Score comes from `wave_spawner.score` (Step 3, Section 8 non-blocking note)
- Plan correctly notes this is read at show time (final score, not live-updating)

---

### Criterion 4: RESTART button below score, responds to touch/press

**Status: COVERED**

- Button with `offset_top` below score Label (Step 1)
- `connect("pressed", ...)` follows exact pattern from `title_screen.gd` (Step 1)
- Connects to `main.restart_game()` (Step 1, 3e)

---

### Criterion 5: Pressing RESTART resets all game state and transitions to TITLE

**Status: COVERED**

The `restart_game()` method (Step 3e) correctly sequences:
1. `_reset_game()` — resets HP, wave spawner state, clears enemies, clears player/joystick/HUD
2. `_hide_game_over_screen()` — hides game over screen
3. `_change_state(GameState.TITLE)` — transitions to title

`_reset_game()` (Step 3c) handles:
- Player HP reset via `reset_health()` with fallback check
- Wave spawner reset: `score = 0`, `wave_number = 0`, `enemies_alive = 0`
- Enemy cleanup via `_clear_enemies()` using `is EnemyBase` type check
- Player/joystick cleanup with `queue_free()`
- HUD cleanup with `queue_free()`

---

### Criterion 6: No imported assets — default font and procedural styling only

**Status: COVERED**

- All UI uses Godot default font (Step 1: `add_theme_font_size_override`)
- `add_theme_color_override` for text color
- `BG_COLOR = Color(0.0, 0.0, 0.0, 0.85)` matches title_screen.gd pattern
- No `load()` of external files
- Verification: file grep check in validation plan

---

## Godot 4.6 Pattern Compliance

| Pattern | Implementation | Status |
|---------|----------------|--------|
| Static typing | `-> void` return types on all new methods | ✅ |
| Callable for signals | `Callable(self, "method")` pattern | ✅ |
| Type checking | `is EnemyBase` in `_clear_enemies()` | ✅ |
| class_name EnemyBase | Referenced correctly per `enemy_base.gd` | ✅ |
| Scene node creation | Follows title_screen.gd pattern | ✅ |
| Theme overrides | `add_theme_font_size_override`, `add_theme_color_override` | ✅ |

---

## Implementation Plan Soundness

### Sequence Correctness

The restart flow is correctly sequenced:
1. Player dies → `_change_state(GAME_OVER)` → `_trigger_game_over()` + `_show_game_over_screen()`
2. Game over screen displays with final score (score is not yet reset)
3. Player presses RESTART → `restart_game()` → `_reset_game()` (score resets to 0) → `_hide_game_over_screen()` → `_change_state(TITLE)`

The score is displayed before it is reset, satisfying the requirement to show the final score.

### Dependencies

| Dependency | Status in Plan |
|------------|----------------|
| SETUP-001 (GameState enum, _change_state) | Referenced correctly |
| UI-001 (title_screen pattern) | Followed exactly |
| CORE-003 (wave_spawner.score) | Used correctly |
| CORE-005 (player health, signals) | Referenced via health_changed signal |

### Missing Methods to Add (deferred readiness)

The plan correctly identifies these additions to `main.gd`:
- `_show_game_over_screen()`
- `_hide_game_over_screen()`
- `_reset_game()`
- `_clear_enemies()`
- `restart_game()`

None of these exist in the current `main.gd`, so they must be implemented as part of this ticket.

### Wave Spawner Restart Concern

`_reset_game()` calls `wave_spawner.start_next_wave()` after resetting `wave_number = 0`. This should correctly restart from wave 1 since `start_next_wave()` increments from 0. The plan acknowledges this risk (Risk 2) and mitigation is adequate.

---

## Non-Blocking Notes

1. **Score display timing**: The plan correctly notes that score is read at show time (final), not live-updated. This is correct for a game over screen.

2. **Score reset before hide**: `_reset_game()` resets `wave_spawner.score = 0` before `_hide_game_over_screen()` is called. However, this is fine because the game over screen was already shown (and visible with correct score) before the RESTART button was pressed.

3. **Wave spawner `start_next_wave()` behavior**: If `start_next_wave()` increments wave_number internally, then setting `wave_number = 0` before calling it would result in wave 1 (correct). The plan acknowledges checking this (Step 5).

4. **Player `reset_health()` fallback**: Step 4 correctly checks if the method exists and adds it if missing. This is appropriate defensive programming.

---

## Risks and Mitigations Review

| Risk | Probability | Impact | Mitigation | Assessment |
|------|-------------|--------|------------|------------|
| Player `reset_health()` missing | Low | Medium | Check and add if missing | ✅ Adequate |
| Orphaned enemies on restart | Medium | Medium | `_clear_enemies()` with EnemyBase type check | ✅ Adequate |
| Stale score display | Low | Low | Score read at show time, not live | ✅ Correct by design |
| Restart timing | Low | Low | queue_free deferred, state change after reset | ✅ Adequate |

---

## Validation Plan

**Static Verification** (Step 4):
- File existence checks for `game_over_screen.gd`
- Pattern checks for CanvasLayer, ColorRect, Labels, Button
- Method existence checks for `show_game_over()`, `hide_game_over()`
- `restart_game()` connection verification
- `main.tscn` GameOverScreen node check
- `main.gd` method additions check

**Smoke Test** (Step 4):
- `godot4 --headless --path . --quit` (0 exit)
- Fallback grep verification

Validation plan is sound and matches project standards.

---

## Conclusion

The plan is **APPROVED**. All 6 acceptance criteria are covered, Godot 4.6 patterns are correctly applied, game state reset is properly sequenced, and risks are identified with adequate mitigations. The plan follows the existing title_screen.gd pattern exactly and integrates correctly with the existing game state machine.

**Implementation may proceed.**
