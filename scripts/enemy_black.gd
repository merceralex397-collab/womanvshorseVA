class_name EnemyBlack
extends EnemyBase

var _last_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	super()
	type = "black"
	body_color = Color(0.2, 0.2, 0.2)
	body_size = Vector2(25, 35)
	speed = 150.0
	max_health = 1
	health = max_health

func _physics_process(delta: float) -> void:
	_last_position = global_position
	super._physics_process(delta)
	queue_redraw()

func _draw() -> void:
	if velocity.length() > 50:
		var behind_offset: Vector2 = -Vector2.from_angle(rotation) * body_size.x * 0.6
		for i in range(3):
			var line_start := _last_position + behind_offset + Vector2.from_angle(rotation + PI/2) * (i - 1) * 8
			var line_end := line_start + (-velocity.normalized() * body_size.x * 0.4)
			draw_line(line_start - global_position, line_end - global_position, Color(0.4, 0.4, 0.4), 2.0)
