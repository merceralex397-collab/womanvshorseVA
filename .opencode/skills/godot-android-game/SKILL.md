---
name: godot-android-game
description: Godot 4.6 Android game development patterns, scene architecture, GDScript conventions, touch input, and export configuration. Use when planning or implementing any game scene, script, or Android build work.
---

# Godot 4.6 Android Game Development

Before applying these patterns, call `skill_ping` with `skill_id: "godot-android-game"` and `scope: "project"`.

## Project Architecture

This project uses a single-scene architecture with state management:

```
project.godot          # Godot project config (landscape, Android)
export_presets.cfg     # Android export preset
scenes/
  main.tscn            # Root scene (always loaded)
scripts/
  main.gd              # Root script: state machine (Title → Playing → GameOver)
  player.gd            # Player character controller
  enemy_base.gd        # Base enemy class
  enemy_*.gd           # Enemy variant scripts
  wave_spawner.gd      # Wave management
  hud.gd               # HUD overlay
  projectile.gd        # Ranged attack projectile
  virtual_joystick.gd  # Touch joystick input
```

## Scene Tree Pattern

```
Main (Node2D)
├── Arena (Node2D)
│   └── ArenaBorder (Polygon2D or draw-based)
├── Player (CharacterBody2D)
│   ├── CollisionShape2D
│   ├── PlayerSprite (Polygon2D or Node2D with _draw)
│   └── AttackArea (Area2D + CollisionShape2D)
├── Enemies (Node2D)  # container for spawned enemies
├── Projectiles (Node2D)  # container for projectiles
├── HUD (CanvasLayer)
│   ├── HealthDisplay
│   ├── WaveCounter (Label)
│   └── ScoreLabel (Label)
├── TitleScreen (CanvasLayer)
│   ├── TitleLabel
│   └── StartButton (TouchScreenButton or Button)
├── GameOverScreen (CanvasLayer)
│   ├── ScoreLabel
│   └── RestartButton
└── WaveSpawner (Node)
```

## GDScript Conventions (Godot 4.6)

### Script Structure
```gdscript
class_name ClassName
extends BaseNode

## Doc comment for exported vars
@export var speed: float = 200.0

var _private_var: int = 0

@onready var _sprite: Polygon2D = $Sprite

signal health_changed(new_health: int)

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    pass

# Public methods first, then private
func take_damage(amount: int) -> void:
    pass

func _update_visual() -> void:
    pass
```

### Naming Conventions
- Scripts: `snake_case.gd`
- Classes: `PascalCase`
- Functions/variables: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Signals: `past_tense_verb` (e.g., `health_changed`, `enemy_died`)
- Private members: `_prefixed`

### Type Hints
Always use static typing for function signatures and member variables:
```gdscript
func spawn_enemy(type: String, position: Vector2) -> Enemy:
    pass
```

## Touch Input Patterns

### Virtual Joystick
```gdscript
# Use InputEventScreenTouch and InputEventScreenDrag
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _is_in_joystick_zone(event.position):
            _touch_index = event.index
            _touch_origin = event.position
        elif not event.pressed and event.index == _touch_index:
            _touch_index = -1
            _direction = Vector2.ZERO
    elif event is InputEventScreenDrag:
        if event.index == _touch_index:
            _direction = (event.position - _touch_origin).normalized()
```

### Screen Zone Division
- Left half: movement joystick
- Right half tap: melee attack
- Right half hold+release: ranged attack

### Touch Zones
```gdscript
func _is_left_half(pos: Vector2) -> bool:
    return pos.x < get_viewport_rect().size.x / 2.0

func _is_right_half(pos: Vector2) -> bool:
    return pos.x >= get_viewport_rect().size.x / 2.0
```

## Android Export Configuration

### Required project.godot Settings
```
display/window/size/viewport_width=1280
display/window/size/viewport_height=720
display/window/handheld/orientation=landscape
display/window/stretch/mode=canvas_items
display/window/stretch/aspect=expand
```

### Export Commands
```bash
# Debug APK
godot4 --headless --export-debug "Android Debug" build/android/womanvshorseva-debug.apk

# Verify project loads
godot4 --headless --quit
```

### Android-Specific Pitfalls
- Always use `get_viewport_rect()` for screen dimensions, never hardcode
- Use `canvas_items` stretch mode for consistent scaling on varied screen sizes
- Test touch with multi-touch support (joystick + attack simultaneously)
- Avoid `_unhandled_input` for touch — use `_input` with explicit index tracking
- Keep draw calls minimal for mobile GPU performance
- Prefer Polygon2D or `_draw()` over Sprite2D with textures for procedural art

## Physics and Collision Layers

Recommended layer assignment:
| Layer | Name | Used By |
|-------|------|---------|
| 1 | Player | Player CharacterBody2D |
| 2 | Enemies | Enemy CharacterBody2D |
| 3 | PlayerAttack | Melee arc Area2D, projectiles |
| 4 | EnemyAttack | Enemy charge hitbox |
| 5 | Arena | Arena boundary walls |

## State Machine Pattern

```gdscript
enum GameState { TITLE, PLAYING, GAME_OVER }

var _state: GameState = GameState.TITLE

func _change_state(new_state: GameState) -> void:
    _state = new_state
    match _state:
        GameState.TITLE:
            _show_title()
        GameState.PLAYING:
            _start_game()
        GameState.GAME_OVER:
            _show_game_over()
```

## Wave Spawner Pattern

```gdscript
var _wave_number: int = 0
var _enemies_alive: int = 0

func _start_wave() -> void:
    _wave_number += 1
    var spawn_list := _get_wave_composition(_wave_number)
    for entry in spawn_list:
        _spawn_enemy(entry.type, _random_edge_position())
        _enemies_alive += 1

func _on_enemy_died() -> void:
    _enemies_alive -= 1
    if _enemies_alive <= 0:
        _start_wave()

func _random_edge_position() -> Vector2:
    # Spawn from arena edges, outside player view
    var edge := randi() % 4  # 0=top, 1=right, 2=bottom, 3=left
    # ... return position on selected edge
```
