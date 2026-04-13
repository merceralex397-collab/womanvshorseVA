class_name EnemyBase
extends CharacterBody2D

signal enemy_died(enemy: EnemyBase)

@export var max_health: int = 1
@export var speed: float = 80.0
@export var body_color: Color = Color(0.6, 0.4, 0.2)  # Brown
@export var body_size: Vector2 = Vector2(25, 35)

var health: int
var type: String = "brown"
var _flash_timer: float = 0.0
var _is_flashing: bool = false

func _ready() -> void:
    health = max_health
    collision_layer = 2  # Enemies layer
    collision_mask = 5  # Player (1) + PlayerAttack (4) = 5
    
    _create_visual()

func _physics_process(delta: float) -> void:
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var direction := (player.global_position - global_position).normalized()
        velocity = direction * speed
        move_and_slide()
        if direction != Vector2.ZERO:
            rotation = direction.angle()
    
    if _is_flashing:
        _flash_timer -= delta
        if _flash_timer <= 0:
            _is_flashing = false
            modulate = Color.WHITE

func _create_visual() -> void:
    var body := Polygon2D.new()
    body.name = "Body"
    body.polygon = PackedVector2Array([
        Vector2(-body_size.x/2, -body_size.y/2),
        Vector2(body_size.x/2, -body_size.y/2),
        Vector2(body_size.x/2, body_size.y/2),
        Vector2(-body_size.x/2, body_size.y/2)
    ])
    body.color = body_color
    add_child(body)
    
    var head := Polygon2D.new()
    head.name = "Head"
    head.polygon = PackedVector2Array([
        Vector2(body_size.x/2, 0),
        Vector2(body_size.x/2 - 10, -8),
        Vector2(body_size.x/2 - 10, 8)
    ])
    head.color = body_color.lightened(0.3)
    add_child(head)

func take_damage(amount: int) -> void:
    health -= amount
    _is_flashing = true
    _flash_timer = 0.15
    modulate = Color(1.5, 1.5, 1.5)
    if health <= 0:
        enemy_died.emit(self)
        _spawn_death_effects()
        queue_free()

func _spawn_death_effects() -> void:
    # 8-10 particles: randi() % 3 yields 0-2
    HitParticle.spawn_death_particles(get_parent(), global_position, 8 + randi() % 3)
