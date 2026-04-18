extends Area2D

var _lifetime: float = 0.0
var _max_lifetime: float = 0.2  # 0.2 seconds
var _fade_start: float = 0.1  # Start fading at 0.1s
var _current_alpha: float = 1.0

func _ready() -> void:
    collision_layer = 3  # PlayerAttack layer
    collision_mask = 2  # Enemies layer
    # Add circle shape for collision (simplified from arc)
    var shape := CircleShape2D.new()
    shape.radius = 50.0
    var collision := CollisionShape2D.new()
    collision.shape = shape
    add_child(collision)
    # Use Callable(self, "_on_hit_enemy") style as recommended
    body_entered.connect(Callable(self, "_on_hit_enemy"))

func _on_hit_enemy(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
		AudioManager.play_hit_sfx()
		# Spawn hit particles at impact point
		HitParticle.spawn_hit_particles(get_parent(), body.global_position, 5)

func _physics_process(delta: float) -> void:
    _lifetime += delta
    if _lifetime >= _max_lifetime:
        queue_free()
        return
    
    # Fade calculation
    if _lifetime > _fade_start:
        _current_alpha = 1.0 - ((_lifetime - _fade_start) / (_max_lifetime - _fade_start))
    
    queue_redraw()

func _draw() -> void:
    # Draw filled 60-degree arc sector
    var arc_color := Color(1.0, 1.0, 1.0, _current_alpha * 0.4)
    var center_angle: float = -PI / 6  # -30 degrees from up
    var arc_angle: float = PI / 3  # 60 degrees total
    var radius: float = 50.0
    var start_angle: float = center_angle - arc_angle / 2.0
    var end_angle: float = center_angle + arc_angle / 2.0
    var pts: PackedVector2Array = PackedVector2Array([Vector2.ZERO])
    var segments: int = 12
    for i in range(segments + 1):
        var a: float = start_angle + float(i) / float(segments) * arc_angle
        pts.append(Vector2(cos(a), sin(a)) * radius)
    draw_colored_polygon(pts, arc_color)
