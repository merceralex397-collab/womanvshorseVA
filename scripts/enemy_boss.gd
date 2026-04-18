class_name EnemyBoss
extends EnemyBase

func _ready() -> void:
	super()
	type = "boss"
	body_color = Color(1.0, 0.84, 0.0)
	body_size = Vector2(50, 65)
	speed = 100.0
	max_health = 10
	health = max_health

func _process(delta: float) -> void:
	var t: float = sin(Time.get_ticks_msec() / 300.0) * 0.5 + 0.5
	modulate = Color(1.0, 0.84 + t * 0.16, 0.0 + t * 1.0, 1.0)
	# Amplified pulse: scale oscillates slightly (1.0 to 1.15) in addition to color
	var scale_factor: float = 1.0 + t * 0.15
	scale = Vector2(scale_factor, scale_factor)
