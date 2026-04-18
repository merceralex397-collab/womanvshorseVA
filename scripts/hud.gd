extends Control

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
		_draw_heart(Vector2(x + heart_size / 2.0, start_y + heart_size / 2.0), heart_size / 2.0, color)

func _draw_heart(center: Vector2, radius: float, color: Color) -> void:
	# Heart silhouette: two overlapping circles at top + triangle bottom
	var top_radius: float = radius * 0.6
	var circle1_center: Vector2 = center + Vector2(-radius * 0.4, -radius * 0.2)
	var circle2_center: Vector2 = center + Vector2(radius * 0.4, -radius * 0.2)
	# Draw two top circles
	draw_circle(circle1_center, top_radius, color)
	draw_circle(circle2_center, top_radius, color)
	# Draw bottom triangle
	var tip_y: float = center.y + radius * 0.7
	var tip_x: float = center.x
	var triangle_pts: PackedVector2Array = PackedVector2Array([
		Vector2(center.x - radius * 0.6, center.y - radius * 0.1),
		Vector2(center.x + radius * 0.6, center.y - radius * 0.1),
		Vector2(tip_x, tip_y)
	])
	draw_colored_polygon(triangle_pts, color)

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
