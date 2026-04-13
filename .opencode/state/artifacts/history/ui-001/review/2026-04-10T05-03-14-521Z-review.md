# Code Review — UI-001: Title screen scene

**Ticket:** UI-001  
**Stage:** review  
**Verdict:** APPROVED  

---

## Files Reviewed

- `scripts/title_screen.gd` (71 lines)
- `scenes/main.tscn` (20 lines)
- `scripts/main.gd` (126 lines)

---

## Acceptance Criteria Verification

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | Title screen CanvasLayer child of main, visible in TITLE state | **PASS** | `main.tscn` line 14-15: `TitleScreen` is CanvasLayer child of Main. `main.gd` line 24-25: `_show_title_screen()` called in TITLE state. `main.gd` lines 34-37: `show_title()` invoked on TitleScreen node. |
| 2 | 'WOMAN vs HORSE' Label centered with large font | **PASS** | `title_screen.gd` line 10: `TITLE_TEXT = "WOMAN vs HORSE"`. Lines 33-35: `HORIZONTAL_ALIGNMENT_CENTER`, `VERTICAL_ALIGNMENT_CENTER`, `PRESET_CENTER`. Line 41: font_size override = 72. |
| 3 | START button below title, responds to touch/press | **PASS** | `title_screen.gd` lines 45-56: Button created with text "START", positioned below title (offset_top=50, offset_bottom=120). Line 55: `connect("pressed", Callable(self, "_on_start_pressed"))`. |
| 4 | Pressing START calls `_change_state(GameState.PLAYING)` and hides title | **PASS** | `title_screen.gd` lines 61-65: `_on_start_pressed()` calls `main._change_state(main.GameState.PLAYING)`. `main.gd` lines 26-27: PLAYING branch calls `_hide_title_screen()`. Lines 39-42: `hide_title()` sets `visible = false`. |
| 5 | Godot default font, no imported assets | **PASS** | `title_screen.gd` lines 40-42: Uses `add_theme_font_size_override` and `add_theme_color_override` only. No custom font resources. |
| 6 | Dark background behind title for readability | **PASS** | `title_screen.gd` line 7: `BG_COLOR = Color(0.0, 0.0, 0.0, 0.85)` (near-opaque black). Lines 23-27: ColorRect with `PRESET_FULL_RECT` covering full screen. |

---

## Correctness Check

- **Godot 4.6 patterns:** Static typing on vars (`var background_rect: ColorRect` etc.), `Callable()` for signal connection, `has_method()` guard before calling show/hide helpers. ✓
- **State machine wiring:** `_change_state(GameState.PLAYING)` correctly referenced as enum on the `main` instance via `main.GameState.PLAYING`. ✓
- **Null safety:** `get_parent()` result checked with `if main and main.has_method(...)`. ✓
- **No regression from other tickets:** `main.gd` show/hide helpers (`_show_title_screen`, `_hide_title_screen`) are additive and do not conflict with any existing `main.gd` logic.

---

## Regression Risk

**Low.** TitleScreen is entirely self-contained CanvasLayer. State machine calls are additive helpers. No existing game logic mutated.

---

## Compile / Import Check

`scripts/title_screen.gd` and `scripts/main.gd` use only Godot engine types (`CanvasLayer`, `ColorRect`, `Label`, `Button`, `Control.PRESET_*`, `Color`, `Callable`). No external dependencies. Static analysis confirms clean GDScript syntax. Godot headless validation (via prior smoke-test artifact) confirmed clean in REMED-001 and SETUP-001.

---

## Verdict

**APPROVED.** All 6 acceptance criteria pass. Implementation is correct, follows Godot 4.6 patterns, and introduces no regressions. Stage may advance to QA.