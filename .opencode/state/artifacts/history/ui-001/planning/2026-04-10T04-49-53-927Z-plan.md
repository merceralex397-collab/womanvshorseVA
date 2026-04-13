# Planning Artifact: UI-001 Title Screen Scene

## 1. Scope

Create a title screen for the Woman vs Horse VA Godot 4.6 Android game. The title screen is a CanvasLayer within the main scene that displays:
- "WOMAN vs HORSE" title text (large, centered)
- START button (touch-responsive)
- Dark background for readability

The title screen is visible when the game is in `GameState.TITLE` and transitions to `GameState.PLAYING` when the player taps START.

---

## 2. Files to Modify

| File | Change Type | Purpose |
|------|-------------|---------|
| `scripts/title_screen.gd` | **New** | Title screen logic: visibility control, START button signal, state transition |
| `scenes/main.tscn` | **Modify** | Add TitleScreen CanvasLayer as child of root Node2D |

---

## 3. Implementation Approach

### Architecture

- Create `scripts/title_screen.gd` as a CanvasLayer-based script
- Add a `TitleScreen` CanvasLayer child to the main scene in `main.tscn`
- Visibility controlled by `current_state == GameState.TITLE` in main.gd's `_change_state()`
- Title screen script handles its own button press and calls main.gd's `_change_state(GameState.PLAYING)`

### Script Design: `title_screen.gd`

```
class_name TitleScreen
extends CanvasLayer

# UI References
var title_label: Label
var start_button: Button

# Colors
const BACKGROUND_COLOR := Color(0.02, 0.02, 0.05, 0.95)  # Near-black, slight blue tint
const TITLE_COLOR := Color(1.0, 1.0, 1.0, 1.0)             # White
const BUTTON_NORMAL := Color(0.2, 0.4, 0.2, 1.0)          # Dark green
const BUTTON_HOVER := Color(0.3, 0.6, 0.3, 1.0)           # Brighter green

func _ready() -> void:
    _create_background()
    _create_title_label()
    _create_start_button()
    # Visible by default in TITLE state

func _create_background() -> void:
    # Use a ColorRect for the dark background layer
    var bg = ColorRect.new()
    bg.color = BACKGROUND_COLOR
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

func _create_title_label() -> void:
    title_label = Label.new()
    title_label.text = "WOMAN vs HORSE"
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    # Use default Godot font, size scaled for readability
    title_label.add_theme_font_size_override("font_size", 72)
    title_label.add_theme_color_override("font_color", TITLE_COLOR)
    title_label.set_anchors_preset(Control.PRESET_CENTER)
    add_child(title_label)

func _create_start_button() -> void:
    start_button = Button.new()
    start_button.text = "START"
    start_button.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    start_button.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    # Use default Godot font
    start_button.add_theme_font_size_override("font_size", 48)
    start_button.add_theme_color_override("font_color", TITLE_COLOR)
    # Style the button background
    start_button.flat = false
    # Position below title
    start_button.set_anchors_preset(Control.PRESET_CENTER)
    start_button.offset_top = 120  # Below centered title
    start_button.custom_minimum_size = Vector2(200, 80)
    add_child(start_button)
    # Connect pressed signal
    start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
    # Hide title screen
    visible = false
    # Transition to PLAYING state via main.gd's _change_state
    var main = get_tree().root.get_node("main") as Node
    if main and main.has_method("_change_state"):
        main._change_state(main.GameState.PLAYING)

func show_title() -> void:
    visible = true

func hide_title() -> void:
    visible = false
```

### Visibility Control in `main.gd`

Modify `_change_state()` to control title screen visibility:

```
# Add to _change_state():
GameState.TITLE:
    _show_title_screen()
GameState.PLAYING:
    _hide_title_screen()
    _spawn_player_and_joystick()
    _setup_hud()

# Add helper functions:
func _show_title_screen() -> void:
    var title_screen = get_node_or_null("TitleScreen")
    if title_screen:
        title_screen.show_title()

func _hide_title_screen() -> void:
    var title_screen = get_node_or_null("TitleScreen")
    if title_screen:
        title_screen.hide_title()
```

### Scene Modification: `main.tscn`

Add TitleScreen node to the scene tree:
```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/main.gd" id="1_main"]

[node name="main" type="Node2D"]
script = ExtResource("1_main")

[node name="TitleScreen" type="CanvasLayer" parent="."]
script = ExtResource("res://scripts/title_screen.gd")
```

---

## 4. Step-by-Step Implementation Plan

| Step | Action | Output |
|------|--------|--------|
| 1 | Create `scripts/title_screen.gd` with TitleScreen class | New GDScript file |
| 2 | Modify `scenes/main.tscn` to add TitleScreen CanvasLayer child | Updated scene file |
| 3 | Modify `scripts/main.gd` to add `_show_title_screen()` and `_hide_title_screen()` helpers | Updated main.gd |
| 4 | Update `_change_state()` in main.gd to call title screen show/hide | Updated main.gd |
| 5 | Validate syntax and structure via static analysis | Verification |

---

## 5. Validation Plan

### Static Verification Checklist

- [ ] `scripts/title_screen.gd` exists and extends CanvasLayer with `class_name TitleScreen`
- [ ] Title Label created with text "WOMAN vs HORSE", centered, large font size (72pt)
- [ ] START Button created with touch/press response, positioned below title
- [ ] Button `pressed` signal connects to `_on_start_pressed()`
- [ ] `_on_start_pressed()` calls `main._change_state(GameState.PLAYING)` and hides title screen
- [ ] Dark background ColorRect covers full screen behind UI
- [ ] All UI uses Godot default font (`add_theme_font_size_override`), no imported assets
- [ ] `main.tscn` has TitleScreen CanvasLayer as child of root Node2D
- [ ] `main.gd` has `_show_title_screen()` and `_hide_title_screen()` methods
- [ ] `_change_state(GameState.TITLE)` calls `_show_title_screen()`
- [ ] `_change_state(GameState.PLAYING)` calls `_hide_title_screen()`

### Smoke Test Commands

```bash
# Godot headless validation (if godot4 available)
godot4 --headless --path . --quit

# Alternative: syntax check via grep for common GDScript errors
rg -n "func _" scripts/title_screen.gd
rg -n "_change_state|_show_title_screen|_hide_title_screen" scripts/main.gd
```

---

## 6. Acceptance Criteria Mapping

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| 1. Title screen is CanvasLayer child of main scene, visible in TITLE state | TitleScreen CanvasLayer in main.tscn; `_change_state(TITLE)` calls `show_title()` | Static check: main.tscn has TitleScreen node; main.gd has show/hide logic |
| 2. 'WOMAN vs HORSE' Label centered with large font | Label.new() with HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, font_size=72 | Static check: title_label creation and alignment in title_screen.gd |
| 3. START button below title, responds to touch/press | Button with offset_top=120, `pressed.connect(_on_start_pressed)` | Static check: button creation and signal connection in title_screen.gd |
| 4. Pressing START calls _change_state(GameState.PLAYING) and hides | `_on_start_pressed()` calls `main._change_state(GameState.PLAYING)` and `visible=false` | Static check: method body in title_screen.gd |
| 5. Title screen uses Godot default font, no imported assets | `add_theme_font_size_override` used throughout, no `load()` of external fonts | Static check: no `load()` or `preload()` for fonts in title_screen.gd |
| 6. Dark background behind title for readability | ColorRect with `BACKGROUND_COLOR = Color(0.02, 0.02, 0.05, 0.95)` as first child | Static check: bg ColorRect creation in title_screen.gd |

---

## 7. Risks and Assumptions

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Touch input not responsive on device | Low | Medium | Use Button node which handles touch natively in Godot 4 |
| Title text too large/small on different screen sizes | Low | Low | Use `set_anchors_preset(Control.PRESET_CENTER)` for centering; font size chosen for typical 1920x1080 scaled down |
| State transition race condition | Low | High | Title screen `visible=false` is set synchronously before `_change_state` completes |
| main.tscn modification conflicts with other UI work | Low | Medium | UI-001 and UI-002 are parallel-safe; UI-002 (game over screen) uses similar pattern |

**Assumptions:**
- Godot 4.6 CanvasLayer and Button nodes work the same on Android as in editor
- Default font renders acceptably on Android at 72pt/48pt sizes
- `get_tree().root.get_node("main")` is a reliable way to access main from a child CanvasLayer

---

## 8. Dependency Status

- **SETUP-001** (done/trusted): Provides `GameState` enum, `_change_state()` method, and main scene structure
- **No blockers**: All dependencies satisfied

---

## 9. Technical Notes

### Godot 4.6 Specific Patterns Used

- `class_name TitleScreen` for type-safe node access
- `extends CanvasLayer` for UI overlay
- `add_theme_font_size_override("font_size", size)` for default font sizing
- `add_theme_color_override("font_color", color)` for text color
- `set_anchors_preset(Control.PRESET_CENTER)` for centering
- `set_anchors_preset(Control.PRESET_FULL_RECT)` for background coverage
- `Control.offset_top` for relative positioning below centered element
- `Button.pressed` signal for touch/click handling

### No External Assets

All UI elements use Godot's built-in default font via theme overrides. No custom fonts, textures, or other imported assets are required or used.
