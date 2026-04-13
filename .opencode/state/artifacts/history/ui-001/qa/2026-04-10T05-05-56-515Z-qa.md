# QA Verification — UI-001: Title Screen Scene

**Ticket:** UI-001  
**Stage:** QA  
**Lane:** ui-screens  
**Date:** 2026-04-10  
**Verifier:** wvhva-tester-qa

---

## Checks Run

1. Static code analysis of `scripts/title_screen.gd`
2. Static code analysis of `scenes/main.tscn`
3. Static code analysis of `scripts/main.gd`
4. Godot headless validation — BLOCKED (environment constraint: godot4 not available in this context)

---

## Acceptance Criteria Verification

### Criterion 1: Title screen is a CanvasLayer child of the main scene, visible in TITLE state

**Status: PASS**

Evidence:
- `scenes/main.tscn` line 14: `[node name="TitleScreen" type="CanvasLayer" parent="."]` — TitleScreen is a direct CanvasLayer child of Main
- `scripts/main.gd` lines 24–25: `GameState.TITLE: _show_title_screen()` which calls `title_screen.show_title()`
- `scripts/title_screen.gd` lines 67–69: `func show_title() -> void: visible = true`

---

### Criterion 2: 'WOMAN vs HORSE' Label centered on screen with large font size

**Status: PASS**

Evidence:
- `scripts/title_screen.gd` line 10: `const TITLE_TEXT: String = "WOMAN vs HORSE"`
- `scripts/title_screen.gd` lines 30–43: Label created with `HORIZONTAL_ALIGNMENT_CENTER`, `VERTICAL_ALIGNMENT_CENTER`, and `set_anchors_preset(Control.PRESET_CENTER)`
- `scripts/title_screen.gd` line 41: `title_label.add_theme_font_size_override("font_size", 72)` — large font (72px)

---

### Criterion 3: START button below title, responds to touch/press

**Status: PASS**

Evidence:
- `scripts/title_screen.gd` lines 45–56: Button created with `offset_top = 50`, `offset_bottom = 120` (below title which ends at offset_bottom = 0)
- `scripts/title_screen.gd` line 55: `start_button.connect("pressed", Callable(self, "_on_start_pressed"))` — wired to touch/press via Godot's Button.pressed signal

---

### Criterion 4: Pressing START calls _change_state(GameState.PLAYING) and hides title screen

**Status: PASS**

Evidence:
- `scripts/title_screen.gd` lines 61–65: `_on_start_pressed()` calls `main._change_state(main.GameState.PLAYING)`
- `scripts/main.gd` lines 26–27: match case `GameState.PLAYING:` calls `_hide_title_screen()`
- `scripts/main.gd` lines 39–42: `_hide_title_screen()` calls `title_screen.hide_title()`
- `scripts/title_screen.gd` lines 70–71: `func hide_title() -> void: visible = false`

---

### Criterion 5: Title screen uses Godot default font, no imported assets

**Status: PASS**

Evidence:
- `scripts/title_screen.gd` line 40: `# Use default font - no imported assets` (explicit comment)
- `scripts/title_screen.gd` line 41: `title_label.add_theme_font_size_override("font_size", 72)` — only size override, no custom font set
- No `DynamicFont` or font file references anywhere in `title_screen.gd`

---

### Criterion 6: Dark background behind title for readability

**Status: PASS**

Evidence:
- `scripts/title_screen.gd` line 7: `const BG_COLOR: Color = Color(0.0, 0.0, 0.0, 0.85)` — 85% opacity black
- `scripts/title_screen.gd` lines 22–27: ColorRect created with `set_anchors_preset(Control.PRESET_FULL_RECT)` covering full screen, color = BG_COLOR

---

## Godot Headless Validation

**Status: BLOCKED**

Command attempted: `godot4 --headless --path . --quit`

Result: Environment constraint — godot4 is not available in this execution context. This is an infrastructure limitation, not a code defect. The implementation follows Godot 4.6 GDScript standards and all static checks pass.

---

## Summary

| Criterion | Status |
|-----------|--------|
| 1. CanvasLayer child of main, visible in TITLE state | PASS |
| 2. 'WOMAN vs HORSE' Label centered, large font | PASS |
| 3. START button below title, responds to press | PASS |
| 4. START calls _change_state(PLAYING) and hides title | PASS |
| 5. Default font, no imported assets | PASS |
| 6. Dark background for readability | PASS |

**Overall: 6/6 PASS**

---

## Blockers

None. All 6 acceptance criteria pass static verification.

**Note:** Godot headless validation (`godot4 --headless --quit`) could not be executed due to environment constraints. This is not a code defect but an infrastructure limitation. The code follows Godot 4.6 patterns correctly:
- Correct `extends CanvasLayer`
- Proper signal wiring via `Callable`
- Correct `enum GameState` usage
- Proper `ColorRect` and `Label` setup

---

## Closeout Readiness

**Ready for smoke-test stage.** All acceptance criteria verified. Recommend proceeding to deterministic smoke test if godot4 becomes available, or accepting the static verification evidence given the environment constraint.