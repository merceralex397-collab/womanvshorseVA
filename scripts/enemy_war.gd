class_name EnemyWar
extends EnemyBase

func _ready() -> void:
	super()
	type = "war"
	body_color = Color(0.8, 0.2, 0.2)
	body_size = Vector2(35, 50)
	speed = 60.0
	max_health = 3
	health = max_health
