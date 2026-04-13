class_name EnemyBrown
extends EnemyBase

func _ready() -> void:
	super()
	type = "brown"
	body_color = Color(0.6, 0.4, 0.2)
	body_size = Vector2(25, 35)
	speed = 80.0
	max_health = 1
	health = max_health
