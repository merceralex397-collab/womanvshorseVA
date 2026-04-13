class_name HitParticle
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0
var max_lifetime: float = 0.3
var friction: float = 0.9
var size: float = 4.0

func _ready() -> void:
    modulate.a = 1.0

func _physics_process(delta: float) -> void:
    lifetime += delta
    if lifetime >= max_lifetime:
        queue_free()
        return
    
    position += velocity * delta
    velocity *= friction
    
    # Fade via modulate.a
    if lifetime > max_lifetime * 0.5:
        modulate.a = 1.0 - ((lifetime - max_lifetime * 0.5) / (max_lifetime * 0.5))
    
    queue_redraw()

func _draw() -> void:
    # Orange-yellow circle particle
    var color := Color(1.0, 0.6, 0.1, modulate.a)
    draw_circle(Vector2.ZERO, size, color)

# Static spawn for hit particles (5 at impact point)
static func spawn_hit_particles(parent_node: Node2D, world_position: Vector2, count: int = 5) -> void:
    for i in range(count):
        var particle := HitParticle.new()
        particle.position = world_position
        # Random velocity in all directions
        var angle := randf() * TAU
        var speed := 100.0 + randf() * 100.0
        particle.velocity = Vector2(cos(angle), sin(angle)) * speed
        particle.max_lifetime = 0.25 + randf() * 0.1
        particle.lifetime = 0.0
        particle.friction = 0.9
        particle.size = 3.0 + randf() * 2.0
        parent_node.add_child(particle)

# Static spawn for death particles (8-10 burst)
static func spawn_death_particles(parent_node: Node2D, world_position: Vector2, count: int = 9) -> void:
    for i in range(count):
        var particle := HitParticle.new()
        particle.position = world_position
        # Wider burst for death
        var angle := randf() * TAU
        var speed := 150.0 + randf() * 150.0
        particle.velocity = Vector2(cos(angle), sin(angle)) * speed
        particle.max_lifetime = 0.3 + randf() * 0.1
        particle.lifetime = 0.0
        particle.friction = 0.9
        particle.size = 4.0 + randf() * 3.0
        parent_node.add_child(particle)
