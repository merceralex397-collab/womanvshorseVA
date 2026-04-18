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
	_add_war_outline()

func _add_war_outline() -> void:
	# Add a darker outline behind the body for visual distinction
	var outline_body := Polygon2D.new()
	outline_body.name = "BodyOutline"
	outline_body.polygon = PackedVector2Array([
		Vector2(-body_size.x/2.0 - 2.0, -body_size.y/2.0 - 2.0),
		Vector2(body_size.x/2.0 + 2.0, -body_size.y/2.0 - 2.0),
		Vector2(body_size.x/2.0 + 2.0, body_size.y/2.0 + 2.0),
		Vector2(-body_size.x/2.0 - 2.0, body_size.y/2.0 + 2.0)
	])
	outline_body.color = Color(0.3, 0.05, 0.05)  # Dark red outline
	# Move outline behind body
	var body_node = get_node_or_null("Body")
	if body_node:
		outline_body.z_index = body_node.z_index - 1
	add_child(outline_body)
