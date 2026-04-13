# Plan: SETUP-002 — Create Player Character with Movement and Virtual Joystick

## 1. Scope

**Objective:** Create the player `CharacterBody2D` with procedural green rectangle body, white triangle sword indicator, collision shape, and 8-directional movement driven by a virtual joystick on the left screen half. Player is constrained within arena bounds.

**Deliverables:**
- `scripts/player.gd` — Player CharacterBody2D script
- `scripts/virtual_joystick.gd` — Virtual joystick input handler
- Updated `scenes/main.tscn` — Player node added as child of root

---

## 2. Files and Systems Affected

| File | Change |
|------|--------|
| `scripts/player.gd` | **CREATE** — Player CharacterBody2D with movement, visuals, HP, arena constraint |
| `scripts/virtual_joystick.gd` | **CREATE** — Touch input handler for left-screen-half joystick |
| `scenes/main.tscn` | **MODIFY** — Add Player node as child of root Node2D |
| `scripts/main.gd` | **MODIFY** — Add Player to scene tree and wire joystick |

---

## 3. Implementation Steps

### Step 1 — Create `scripts/player.gd`

```
extends CharacterBody2D

## Export variables
@export var speed: float = 200.0

## Internal state
var hp: int = 3
var facing_direction: Vector2 = Vector2.RIGHT

## Arena bounds (set from main.gd or hardcoded constants)
const ARENA_INSET: float = 45.0

## References
@onready var player_body: Polygon2D = $PlayerBody
@onready var sword_indicator: Polygon2D = $SwordIndicator

func _ready() -> void:
    # Set collision layer 1 (Player)
    collision_layer = 1
    collision_mask = 0  # Player doesn't collide with static geometry here

func _physics_process(delta: float) -> void:
    # Get input direction from virtual joystick
    var input_dir: Vector2 = _get_joystick_input()
    
    if input_dir.length() > 0.1:
        facing_direction = input_dir.normalized()
        velocity = facing_direction * speed
    else:
        velocity = Vector2.ZERO
    
    move_and_slide()
    _constrain_to_arena()

func _get_joystick_input() -> Vector2:
    # Read from virtual joystick singleton or signal
    return Vector2.ZERO  # Placeholder — replaced by joystick connection

func _constrain_to_arena() -> void:
    var screen_size: Vector2 = get_viewport_rect().size
    var pos: Vector2 = global_position
    var half_w: float = 15.0  # Approximate half of player width
    var half_h: float = 20.0  # Approximate half of player height
    
    pos.x = clamp(pos.x, ARENA_INSET + half_w, screen_size.x - ARENA_INSET - half_w)
    pos.y = clamp(pos.y, ARENA_INSET + half_h, screen_size.y - ARENA_INSET - half_h)
    global_position = pos

func take_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        hp = 0
        # Emit death signal — handled by main.gd
```

### Step 2 — Create Player Visual Nodes (attached to Player scene)

Create a child scene `scenes/player.tscn` or add directly as children in main.tscn:

```
Player (CharacterBody2D)
├── CollisionShape2D (RectangleShape2D, 30x40)
├── PlayerBody (Polygon2D) — green rectangle 30x40
│   └── Points: [(-15,-20), (15,-20), (15,20), (-15,20)]
└── SwordIndicator (Polygon2D) — white triangle
    └── Points relative to body: tip forward in facing direction
```

For procedural triangle: offset toward facing direction, base perpendicular.

### Step 3 — Create `scripts/virtual_joystick.gd`

```
extends Node2D

## Emitted when joystick produces a direction
signal joystick_direction(dir: Vector2)

## Touch tracking
var touch_index: int = -1
var joystick_center: Vector2 = Vector2.ZERO
var is_active: bool = false

## Joystick parameters
const DEADZONE: float = 0.15
const MAX_RADIUS: float = 50.0

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch(event)
    elif event is InputEventScreenDrag:
        _handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
    var screen_half: float = get_viewport_rect().size.x / 2.0
    
    if event.pressed:
        # Start touch on left half
        if event.position.x < screen_half and touch_index == -1:
            touch_index = event.index
            joystick_center = event.position
            is_active = true
    else:
        # End touch
        if event.index == touch_index:
            touch_index = -1
            is_active = false
            emit_signal("joystick_direction", Vector2.ZERO)

func _handle_drag(event: InputEventScreenDrag) -> void:
    if event.index != touch_index or not is_active:
        return
    
    var delta: Vector2 = event.position - joystick_center
    var dist: float = delta.length()
    
    if dist > DEADZONE * MAX_RADIUS:
        var dir: Vector2 = delta.normalized()
        var magnitude: float = min(dist / MAX_RADIUS, 1.0)
        emit_signal("joystick_direction", dir * magnitude)
    else:
        emit_signal("joystick_direction", Vector2.ZERO)
```

### Step 4 — Wire Virtual Joystick to Player in `scripts/main.gd`

In `_ready()` or when state transitions to PLAYING:
```gdscript
func _ready() -> void:
    # Assuming joystick is a child or singleton
    joystick.joystick_direction.connect(_on_joystick_direction)

func _on_joystick_direction(dir: Vector2) -> void:
    if player:
        player.facing_direction = dir if dir.length() > 0 else player.facing_direction
```

Add Player node instantiation in main.gd when entering PLAYING state:
```gdscript
func _change_state(new_state: GameState) -> void:
    match new_state:
        GameState.PLAYING:
            if player == null:
                player = preload("res://scenes/player.tscn").instantiate()
                add_child(player)
            # Connect joystick signal
```

---

## 4. Validation Plan

| Step | Command | Expected |
|------|---------|----------|
| Static check | `godot4 --headless --path . --quit` | Exit code 0, no errors |
| File existence | `ls scripts/player.gd scripts/virtual_joystick.gd` | Both files exist |
| Scene parse | Godot headless loads `scenes/main.tscn` without errors | Clean parse |

---

## 5. Risks and Assumptions

| Risk | Mitigation |
|------|------------|
| Virtual joystick signal wiring depends on main.gd structure | Signal connection deferred until player is added to scene |
| Arena bounds hardcoded vs. dynamic | ARENA_INSET constant used; can be replaced by signal from Arena node |
| Multi-touch edge case (right-half attack touch conflicts) | Touch index tracking ensures only left-half touches control joystick |
| Player added before arena is ready | Player is added in PLAYING state after arena is initialized |

---

## 6. Blockers or Required User Decisions

- **None** — All dependencies resolved. SETUP-001 (main scene with arena) is done and in closeout.

---

## 7. Acceptance Mapping

| Criterion | Implementation |
|-----------|----------------|
| `scripts/player.gd` extends CharacterBody2D with @export speed, 3 HP, static typing | Lines 1–7 in player.gd |
| Player visual is green rectangle (30x40) with white triangle sword, via Polygon2D | PlayerBody and SwordIndicator Polygon2D nodes |
| `scripts/virtual_joystick.gd` handles InputEventScreenTouch/Drag on left half with touch index | `_handle_touch` and `_handle_drag` in virtual_joystick.gd |
| Player movement 8-directional, ~200px/s, constrained to arena | `_physics_process` and `_constrain_to_arena` |
| Player added to main scene as child of root | Updated main.gd `_change_state` to instantiate and add_child |
| Collision layer 1 (Player) set | `collision_layer = 1` in player.gd `_ready()` |
