extends Area2D

@export var speed: float = 400.0
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
    collision_layer = 3  # PlayerAttack layer
    collision_mask = 2   # Enemies layer
    # Use Callable(self, "_on_hit_enemy") style as recommended
    body_entered.connect(Callable(self, "_on_hit_enemy"))

func _physics_process(delta: float) -> void:
    position += velocity * delta
    # Auto-despawn if off-screen
    var viewport_size = get_viewport_rect().size
    if position.x < -50 or position.x > viewport_size.x + 50 or position.y < -50 or position.y > viewport_size.y + 50:
        queue_free()

func _on_hit_enemy(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
		AudioManager.play_hit_sfx()
		# Spawn hit particles at impact point
		HitParticle.spawn_hit_particles(get_parent(), body.global_position, 5)
	queue_free()

func _draw() -> void:
    # Yellow circle visual (radius 8)
    draw_circle(Vector2.ZERO, 8.0, Color(1.0, 0.9, 0.0))
