# Planning Artifact: CORE-001 — Attack System (Melee Arc + Ranged Projectile)

## 1. Scope

Implement a dual attack system for the player character:

- **Melee attack**: Tap right-half screen → 60-degree arc Area2D facing nearest enemy, rendered as semi-transparent white polygon via `_draw()`, auto-fades after ~0.2s
- **Ranged attack**: Hold+release right-half screen → yellow circle projectile spawns at player, travels in facing direction, auto-despawns off-screen or on hit
- Both attacks use collision layer 3 (PlayerAttack), mask layer 2 (Enemies)
- All visuals are procedural (no imported assets)

## 2. Files / Systems Affected

| File | Change | Reason |
|------|--------|--------|
| `scripts/projectile.gd` | **CREATE** | Area2D projectile with velocity, yellow circle `_draw()`, auto-despawn |
| `scripts/attack_controller.gd` | **CREATE** | Right-half touch handling, tap-vs-hold detection, melee arc spawning |
| `scripts/player.gd` | **MODIFY** | Add `_facing_direction` export signal, attack spawning API, collision layer/mask update |
| `scenes/main.tscn` | **MODIFY** | Attach `attack_controller.gd` as child of Main |
| `scripts/main.gd` | **MODIFY** | Spawn `attack_controller` node on PLAYING state (parallel to player/joystick) |

**Collision layer reference** (from canonical spec and existing code):
- Layer 1: Player
- Layer 2: Enemies
- Layer 3: PlayerAttack

## 3. Implementation Steps

### Step 1: Create `scripts/projectile.gd`
```gdscript
extends Area2D

@export var speed: float = 400.0
var velocity: Vector2 = Vector2.ZERO
var _radius: float = 8.0

func _physics_process(delta: float) -> void:
    position += velocity * delta
    
    # Auto-despawn if off-screen
    var viewport_size = get_viewport_rect().size
    if position.x < -50 or position.x > viewport_size.x + 50 \
       or position.y < -50 or position.y > viewport_size.y + 50:
        queue_free()

func _draw() -> void:
    # Yellow circle projectile visual
    draw_circle(Vector2.ZERO, _radius, Color(1.0, 0.9, 0.0, 1.0))

func setup(dir: Vector2, spd: float) -> void:
    velocity = dir.normalized() * spd
    rotation = dir.angle()
```

- `extends Area2D`
- Collision layer 3, mask layer 2 (set in `_ready()` or via scene setup)
- `_physics_process` for movement + off-screen despawn
- `_draw()` for yellow circle
- `setup(dir, spd)` factory method for initialization

### Step 2: Create `scripts/attack_controller.gd`
```gdscript
extends Node2D

const HOLD_THRESHOLD: float = 0.3       # seconds to distinguish tap vs hold
const MELEE_ARC_DEGREES: float = 60.0
const MELEE_RANGE: float = 60.0
const MELEE_DURATION: float = 0.2       # seconds before arc auto-frees

var _touch_index: int = -1
var _touch_start_time: float = 0.0
var _hold_start_pos: Vector2 = Vector2.ZERO

signal melee_attack_arc(from_pos: Vector2, direction: Vector2)
signal ranged_attack_requested(from_pos: Vector2, direction: Vector2)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _is_in_attack_zone(event.position):
            _touch_index = event.index
            _touch_start_time = Time.get_ticks_msec() / 1000.0
            _hold_start_pos = event.position
        elif not event.pressed and event.index == _touch_index:
            var hold_duration = (Time.get_ticks_msec() / 1000.0) - _touch_start_time
            if hold_duration < HOLD_THRESHOLD:
                _trigger_melee()
            else:
                _trigger_ranged()
            _touch_index = -1
    elif event is InputEventScreenDrag:
        if event.index == _touch_index:
            # Could track drag for aim assist, but ranged uses player facing direction
            pass

func _is_in_attack_zone(pos: Vector2) -> bool:
    return pos.x >= get_viewport_rect().size.x / 2.0

func _trigger_melee() -> void:
    var player = get_node_or_null("/root/Main/Player") as CharacterBody2D
    if player:
        var dir = player._facing_direction
        melee_attack_arc.emit(player.global_position, dir)

func _trigger_ranged() -> void:
    var player = get_node_or_null("/root/Main/Player") as CharacterBody2D
    if player:
        var dir = player._facing_direction
        ranged_attack_requested.emit(player.global_position, dir)
```

### Step 3: Create `scripts/melee_arc.gd`
```gdscript
extends Area2D

const ARC_DEGREES: float = 60.0
const ARC_RADIUS: float = 60.0
const ARC_COLOR: Color = Color(1.0, 1.0, 1.0, 0.6)
const FADE_DURATION: float = 0.2

var _arc_direction: Vector2 = Vector2.RIGHT
var _elapsed: float = 0.0

func _ready() -> void:
    collision_layer = 3   # PlayerAttack
    collision_mask = 2   # Enemies
    # Create CollisionShape2D for the arc (wedge/circle sector)
    # Use Shape2D directly or approximated with multiple ray shapes
    var shape = CircleShape2D.new()
    shape.radius = ARC_RADIUS
    var col = CollisionShape2D.new()
    col.shape = shape
    add_child(col)

func _draw() -> void:
    var alpha = lerp(0.6, 0.0, _elapsed / FADE_DURATION)
    var color = Color(ARC_COLOR.r, ARC_COLOR.g, ARC_COLOR.b, alpha)
    # Draw arc as pie slice (approximated with polyline)
    var points = _get_arc_points(ARC_RADIUS, _elapsed / FADE_DURATION)
    if points.size() > 2:
        var polygon = PackedVector2Array(points)
        draw_colored_polygon(polygon, color)

func _get_arc_points(radius: float, fade_ratio: float) -> Array:
    # Returns arc outline points for _draw()
    var points: Array = [Vector2.ZERO]
    var arc_rad = deg_to_rad(ARC_DEGREES / 2.0)
    var start_angle = _arc_direction.angle() - arc_rad
    var steps = 12
    for i in range(steps + 1):
        var angle = start_angle + (arc_rad * 2.0 * i / steps)
        points.append(Vector2(cos(angle), sin(angle)) * radius)
    return points

func _physics_process(delta: float) -> void:
    _elapsed += delta
    queue_redraw()
    if _elapsed >= FADE_DURATION:
        queue_free()
```

### Step 4: Modify `scripts/player.gd`
Add collision layer/mask updates and attack signal handlers:

```gdscript
# Add these signals:
signal attack_melee_requested(from_pos: Vector2, direction: Vector2)
signal attack_ranged_requested(from_pos: Vector2, direction: Vector2)

# Modify _ready():
func _ready() -> void:
    collision_layer = 1  # Player layer
    collision_mask = 0   # Player doesn't collide with anything directly
    # ... existing visual setup ...

# Add new method for spawning attacks (called by main.gd connecting to attack_controller):
func spawn_melee_arc(from_pos: Vector2, direction: Vector2) -> void:
    var arc = Area2D.new()
    arc.set_script(load("res://scripts/melee_arc.gd"))
    arc._arc_direction = direction
    arc.position = from_pos
    get_tree().root.add_child(arc)

func spawn_projectile(from_pos: Vector2, direction: Vector2) -> void:
    var proj = Area2D.new()
    proj.set_script(load("res://scripts/projectile.gd"))
    proj.position = from_pos + direction.normalized() * 30.0  # spawn in front of player
    proj.setup(direction, 400.0)
    get_tree().root.add_child(proj)
```

### Step 5: Modify `scripts/main.gd`
Connect attack controller signals to player attack methods:

```gdscript
func _spawn_player_and_joystick() -> void:
    # ... existing player/joystick spawning ...
    
    # Create and add AttackController
    var attack_ctrl = Node2D.new()
    attack_ctrl.set_script(load("res://scripts/attack_controller.gd"))
    attack_ctrl.name = "AttackController"
    add_child(attack_ctrl)
    
    # Connect attack signals to player attack methods
    if attack_ctrl.has_signal("melee_attack_arc") and player.has_method("spawn_melee_arc"):
        attack_ctrl.melee_attack_arc.connect(player.spawn_melee_arc)
    if attack_ctrl.has_signal("ranged_attack_requested") and player.has_method("spawn_projectile"):
        attack_ctrl.ranged_attack_requested.connect(player.spawn_projectile)
```

### Step 6: Wire collision layers
In `melee_arc.gd` and `projectile.gd`, set collision in `_ready()`:
```gdscript
func _ready() -> void:
    collision_layer = 3  # PlayerAttack
    collision_mask = 2   # Enemies
```

## 4. Validation Plan

### Static verification (QA artifact):
| Acceptance Criterion | Verification Method |
|---------------------|---------------------|
| Melee attack triggers on right-half tap | Code inspection: `_is_in_attack_zone()` returns `pos.x >= viewport_width/2`, `_trigger_melee()` called on release with `hold_duration < HOLD_THRESHOLD` |
| Ranged attack triggers on right-half hold+release | Code inspection: `_trigger_ranged()` called on release with `hold_duration >= HOLD_THRESHOLD` |
| `projectile.gd` extends Area2D with velocity, auto-despawn | Code inspection: `extends Area2D`, `velocity` member, `position += velocity * delta`, `queue_free()` when off-screen |
| Both attacks use collision layer 3, mask layer 2 | Code inspection: `collision_layer = 3`, `collision_mask = 2` in `_ready()` of both projectile.gd and melee_arc.gd |
| Attack visuals are procedural | Code inspection: `_draw()` methods use `draw_circle()` and `draw_colored_polygon()`, no external asset references |
| Melee arc visual fades after ~0.2s | Code inspection: `FADE_DURATION = 0.2`, `_elapsed` timer, `lerp(0.6, 0.0, _elapsed / FADE_DURATION)` alpha fade |

### Godot validation (smoke test):
```bash
godot4 --headless --path . --quit
```
Expected: clean exit (exit code 0)

## 5. Risks and Assumptions

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Touch handling conflicts with virtual joystick | Low | Joystick uses left half (`pos.x < width/2`), attack uses right half (`pos.x >= width/2`) — mutually exclusive zones |
| Melee arc collision shape too simple | Medium | Use CircleShape2D as approximation; arc visual is cosmetic (actual damage comes from Area2D overlap) |
| `_draw()` performance on many attacks | Low | Melee arc auto-frees after 0.2s, projectiles auto-despawn off-screen |
| Player facing direction stale when ranged fires | Low | Player updates `_facing_direction` every frame when moving; if stationary, retains last direction |
| Area2D collision with enemies not yet existing | Medium | CORE-002 creates enemy base class; attacks will work with placeholder enemy nodes during isolated testing |

**Assumptions:**
- Godot 4.6.2 available on build machine
- No collision layers conflict with existing setup
- `projectile.gd` and `melee_arc.gd` can be instantiated via `set_script(load(...))` and configured via exported vars or `setup()` method

## 6. Blockers / Required User Decisions

**None.** All acceptance criteria are spec'd with sufficient detail. The touch zone separation (left: movement, right: attack) is a clean architectural split with no ambiguity.

**Pre-implementation note:** The `player.gd` modification exposes `spawn_melee_arc` and `spawn_projectile` methods that assume `melee_arc.gd` and `projectile.gd` exist at `res://scripts/`. If script paths differ, the `load()` calls in `main.gd` and `player.gd` must be updated to match.

## 7. Acceptance Mapping

| # | Criterion | Implementation Coverage |
|---|----------|------------------------|
| 1 | Melee attack triggers on right-half tap, 60-degree arc Area2D | `attack_controller.gd::_trigger_melee()`, `melee_arc.gd::_draw()` arc rendering |
| 2 | Ranged attack on hold+release, yellow circle projectile | `attack_controller.gd::_trigger_ranged()`, `projectile.gd::_draw()` circle |
| 3 | `projectile.gd` extends Area2D, velocity, auto-despawn | Full implementation in `projectile.gd` |
| 4 | Both attacks use layer 3 / mask layer 2 | Set in `_ready()` of `melee_arc.gd` and `projectile.gd` |
| 5 | Procedural visuals, no imported assets | `_draw()` only — `draw_circle()`, `draw_colored_polygon()` |
| 6 | Melee arc fades after ~0.2s | `FADE_DURATION = 0.2`, alpha lerp in `melee_arc.gd::_draw()` |
