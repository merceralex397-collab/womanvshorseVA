extends CharacterBody2D

signal health_changed(new_health: int)
signal player_died()

@export var speed: float = 200.0

var hp: int = 3
var _facing_direction: Vector2 = Vector2.RIGHT
var _attack_controller: Node2D = null
var _is_invincible: bool = false
var _invincibility_duration: float = 0.5  # 0.5 seconds invincibility
var _invincibility_timer: float = 0.0
var _contact_sensor: Area2D = null

func _ready() -> void:
    collision_layer = 1  # Player layer
    collision_mask = 0  # Player doesn't collide with anything directly
    _setup_contact_sensor()
    _setup_attacks()
    
    # Player body visual - green rectangle 30x40
    var body_polygon := Polygon2D.new()
    body_polygon.name = "PlayerBody"
    body_polygon.polygon = PackedVector2Array([Vector2(-15, -20), Vector2(15, -20), Vector2(15, 20), Vector2(-15, 20)])
    body_polygon.color = Color(0.2, 0.8, 0.2)  # Green
    add_child(body_polygon)
    
    # Sword indicator - white triangle pointing in facing direction
    var sword := Polygon2D.new()
    sword.name = "SwordIndicator"
    # Triangle pointing right: tip at (10, 0), base at x=0
    sword.polygon = PackedVector2Array([Vector2(10, 0), Vector2(0, -8), Vector2(0, 8)])
    sword.color = Color(1, 1, 1)  # White
    add_child(sword)

func _setup_contact_sensor() -> void:
    # Area2D contact sensor for enemy contact detection (radius 25-30 as recommended)
    _contact_sensor = Area2D.new()
    _contact_sensor.name = "ContactSensor"
    _contact_sensor.collision_layer = 0
    _contact_sensor.collision_mask = 2  # Enemies layer
    
    var shape := CircleShape2D.new()
    shape.radius = 27.0  # Recommended 25-30 for better contact detection
    var collision := CollisionShape2D.new()
    collision.shape = shape
    _contact_sensor.add_child(collision)
    
    add_child(_contact_sensor)
    # Use Callable(self, "_on_hit_enemy") style as recommended
    _contact_sensor.body_entered.connect(Callable(self, "_on_contact_enemy"))

func _physics_process(delta: float) -> void:
    # Handle invincibility timer
    if _is_invincible:
        _invincibility_timer -= delta
        if _invincibility_timer <= 0:
            _is_invincible = false
    
    var direction := Vector2.ZERO
    
    # Get input direction from VirtualJoystick singleton
    if has_node("/root/VirtualJoystick"):
        direction = $"/root/VirtualJoystick".direction
    else:
        # Alternative: use direct input state
        direction = Vector2(
            Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
            Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
        )
    
    if direction != Vector2.ZERO:
        _facing_direction = direction.normalized()
        velocity = _facing_direction * speed
    else:
        velocity = Vector2.ZERO
    
    move_and_slide()
    _constrain_to_arena()
    
    # Rotate sword indicator based on facing direction
    if has_node("SwordIndicator"):
        $SwordIndicator.rotation = _facing_direction.angle()

func _constrain_to_arena() -> void:
    var viewport_size = get_viewport_rect().size
    var inset = 45.0  # Match ARENA_INSET from main.gd
    var player_half_width = 15.0
    var player_half_height = 20.0
    
    position.x = clamp(position.x, inset + player_half_width, viewport_size.x - inset - player_half_width)
    position.y = clamp(position.y, inset + player_half_height, viewport_size.y - inset - player_half_height)

func _setup_attacks() -> void:
    _attack_controller = Node2D.new()
    _attack_controller.set_script(load("res://scripts/attack_controller.gd"))
    _attack_controller.name = "AttackController"
    add_child(_attack_controller)
    _attack_controller.connect("melee_attack", _on_melee_attack)
    _attack_controller.connect("ranged_attack", _on_ranged_attack)

func _on_melee_attack(facing: Vector2) -> void:
    var arc = load("res://scripts/melee_arc.gd").new()
    add_child(arc)
    arc.rotation = facing.angle()

func _on_ranged_attack(facing: Vector2) -> void:
    var proj = load("res://scripts/projectile.gd").new()
    proj.velocity = facing * proj.speed
    proj.position = position + facing * 30
    get_parent().add_child(proj)  # Add to parent so it moves independently

func _on_contact_enemy(body: Node2D) -> void:
    # Enemy touched player - deal 1 damage if not invincible
    if not _is_invincible:
        take_damage(1)

func _flash_damage() -> void:
    # Kill existing tweens before starting new one (plan review recommendation)
    if has_node("Tween"):
        $Tween.kill()
    
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.075)
    tween.tween_property(self, "modulate", Color.WHITE, 0.075).set_delay(0.075)
    # After flash, restore to normal color
    tween.tween_callback(func(): modulate = Color.WHITE)

func take_damage(amount: int) -> void:
    if _is_invincible:
        return
    
    hp -= amount
    _is_invincible = true
    _invincibility_timer = _invincibility_duration
    health_changed.emit(hp)
    _flash_damage()
    
    if hp <= 0:
        player_died.emit()
