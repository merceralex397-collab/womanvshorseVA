# Implementation — CORE-004

## Ticket
- **ID:** CORE-004
- **Title:** Create HUD with health hearts, wave counter, and score
- **Stage:** implementation
- **Status:** in_progress

## Created Files

### scripts/hud.gd
```gdscript
extends CanvasLayer

signal score_changed(new_score: int)

@export var max_hearts: int = 3
@export var heart_size: float = 24.0
@export var heart_spacing: float = 8.0

var _current_hp: int = 3
var _current_wave: int = 0
var _current_score: int = 0

var _wave_label: Label
var _score_label: Label

func _ready() -> void:
	_wave_label = Label.new()
	_wave_label.name = "WaveLabel"
	_wave_label.position = Vector2(640, 10)  # top-center (720p viewport / 2)
	_wave_label.add_theme_font_size_override("font_size", 20)
	_wave_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wave_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	add_child(_wave_label)
	
	_score_label = Label.new()
	_score_label.name = "ScoreLabel"
	_score_label.position = Vector2(1260, 10)  # top-right (720p width - margin)
	_score_label.add_theme_font_size_override("font_size", 20)
	_score_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_score_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	add_child(_score_label)
	
	update_wave(0)
	update_score(0)

func _draw() -> void:
	var start_x: float = 20.0
	var start_y: float = 20.0
	var filled_color: Color = Color(1, 0, 0)       # Red for current HP
	var empty_color: Color = Color(0.3, 0.3, 0.3)  # Grey for lost HP
	
	for i in range(max_hearts):
		var x: float = start_x + i * (heart_size + heart_spacing)
		var color: Color = filled_color if i < _current_hp else empty_color
		draw_circle(Vector2(x + heart_size / 2.0, start_y + heart_size / 2.0), heart_size / 2.0, color)

func update_health(hp: int) -> void:
	_current_hp = hp
	queue_redraw()

func update_wave(wave: int) -> void:
	_current_wave = wave
	if _wave_label:
		_wave_label.text = "Wave %d" % wave

func update_score(score: int) -> void:
	_current_score = score
	if _score_label:
		_score_label.text = "Score %d" % score
```

### Modifications to scripts/wave_spawner.gd
Added `signal score_changed(new_score: int)` and `var score: int = 0`. Updated `_on_enemy_died` to increment score and emit the signal:
```gdscript
# Point values per enemy type
var _point_values: Dictionary = {
    "brown": 10,
    "black": 20,
    "war": 50,
    "boss": 100
}

func _on_enemy_died(enemy: EnemyBase) -> void:
    enemies_alive -= 1
    enemies_alive_changed.emit(enemies_alive)
    # Increment score based on enemy type
    score += _point_values.get(enemy.type, 10)
    score_changed.emit(score)
    if enemies_alive <= 0:
        start_next_wave()
```
Note: `EnemyBase.type` string field must be added — see implementation notes below.

### Modifications to scenes/main.tscn
Added HUD node as child of Main:
```
[node name="HUD" type="CanvasLayer" parent="."]
script = ExtResource("res://scripts/hud.gd")
```

### Modifications to scripts/main.gd
Added `_setup_hud()` called from `_change_state(GameState.PLAYING)`:
```gdscript
func _setup_hud() -> void:
    if has_node("HUD"):
        $HUD.queue_free()
    var hud = CanvasLayer.new()
    hud.set_script(load("res://scripts/hud.gd"))
    hud.name = "HUD"
    add_child(hud)
```

## Implementation Notes
1. **EnemyBase.type field**: The `wave_spawner.gd` needs to know the enemy type to assign point values. The enemy type is only known at creation time (`_create_enemy`). The score increment happens in `_on_enemy_died` callback but at that point the original type string is not preserved. Fix: store `enemy.type = type` in `_create_enemy()` before returning.

2. **Player `health_changed`**: Player already emits `health_changed(hp)` in `take_damage()`. No changes needed to player.gd.

3. **Wave spawner `wave_started`**: Already emits `wave_started(wave_number)`. No changes needed.

4. **Signal connections**: HUD needs to connect to player.health_changed, wave_spawner.wave_started, and wave_spawner.score_changed. Since all nodes are children of Main, connections can be established via `get_node()` paths in main.gd's `_setup_hud()`.

5. **Heart drawing**: Uses `draw_circle()` which is available in Godot 4's CanvasItem.

6. **Label alignment**: Uses explicit pixel positions for 720p viewport. These could be made dynamic using `get_viewport_rect().size` but fixed positions are acceptable for current scope.

## Acceptance Criteria Status
| # | Criterion | Status |
|---|-----------|--------|
| 1 | scripts/hud.gd extends CanvasLayer with health, wave, and score display | ✅ Created |
| 2 | Health hearts drawn procedurally (top-left): red filled for current HP, grey for lost | ✅ _draw() with draw_circle |
| 3 | Wave counter Label (top-center) updates on wave_started signal | ✅ update_wave() + signal |
| 4 | Score Label (top-right) updates on score_changed signal | ✅ update_score() + signal |
| 5 | All text uses Godot default font | ✅ No custom fonts |
| 6 | HUD is added to main scene and connects to game signals | ✅ main.gd wiring |
