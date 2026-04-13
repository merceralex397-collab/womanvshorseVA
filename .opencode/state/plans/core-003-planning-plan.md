# Plan: CORE-003 — Implement Wave Spawner with Escalating Difficulty

## 1. Scope

Create a `WaveSpawner` node (scripts/wave_spawner.gd) that manages wave progression, spawning enemies from random arena edges with escalating difficulty per the canonical spec.

**Wave composition (canonical spec):**
- Wave 1: 3 brown
- Wave 2: 5 brown
- Wave 3: 3 brown + 2 black
- Wave 6+: war horse appears
- Every 5 waves: boss + 2 escorts
- Difficulty scales: enemy count increases ~2 per wave

## 2. Files / Systems Affected

| File | Change |
|------|--------|
| `scripts/wave_spawner.gd` | New — wave spawner implementation |
| `scripts/main.gd` | Add WaveSpawner child on PLAYING state |
| `scenes/main.tscn` | Add WaveSpawner node child |

**Signal dependencies:**
- `wave_spawner.wave_started(wave_number: int)` → HUD listens
- `wave_spawner.enemies_alive_changed(count: int)` → HUD listens
- `enemy_base.enemy_died` → WaveSpawner listens

## 3. Implementation Steps

### Step 1: Create `scripts/wave_spawner.gd`

```gdscript
extends Node

signal wave_started(wave_number: int)
signal enemies_alive_changed(count: int)

@export var base_enemy_count: int = 3
@export var enemies_per_wave_increase: int = 2

var wave_number: int = 0
var enemies_alive: int = 0

# Arena bounds — set from main after spawn
var arena_min: Vector2
var arena_max: Vector2

func _ready() -> void:
    # Wave spawner starts when main calls start_next_wave()
    # Do not auto-start here — main controls game state
    pass

func initialize(arena_bounds: Rect2) -> void:
    arena_min = arena_bounds.position + Vector2(10, 10)
    arena_max = arena_bounds.end - Vector2(10, 10)
    start_next_wave()

func start_next_wave() -> void:
    wave_number += 1
    wave_started.emit(wave_number)
    _spawn_wave_enemies()

func _spawn_wave_enemies() -> void:
    var composition = _get_wave_composition(wave_number)
    for enemy_type in composition:
        var enemy = _create_enemy(enemy_type)
        enemy.connect("tree_exiting", _on_enemy_died)
        get_parent().add_child(enemy)
        enemies_alive += 1
    enemies_alive_changed.emit(enemies_alive)

func _get_wave_composition(wave: int) -> Array:
    var result: Array = []
    
    # Base count scales with wave
    var count: int = base_enemy_count + (wave - 1) * enemies_per_wave_increase
    
    # Brown enemies fill the base count
    for i in range(count):
        if wave >= 3 and i < 2:
            result.append("black")   # First 2 are black from wave 3+
        else:
            result.append("brown")
    
    # Boss wave: every 5 waves
    if wave % 5 == 0:
        result.append("boss")
        result.append("brown")   # escort 1
        result.append("brown")   # escort 2
    
    # War horse: wave 6+
    if wave >= 6:
        result.append("war_horse")
    
    return result

func _create_enemy(type: String) -> Node2D:
    var enemy := EnemyBase.new()
    match type:
        "brown":
            enemy.body_color = Color(0.6, 0.4, 0.2)
            enemy.speed = 80.0
            enemy.body_size = Vector2(25, 35)
            enemy.max_health = 1
        "black":
            enemy.body_color = Color(0.2, 0.2, 0.2)
            enemy.speed = 150.0
            enemy.body_size = Vector2(25, 35)
            enemy.max_health = 1
        "war_horse":
            enemy.body_color = Color(0.8, 0.2, 0.2)
            enemy.speed = 60.0
            enemy.body_size = Vector2(35, 50)
            enemy.max_health = 3
        "boss":
            enemy.body_color = Color(1.0, 0.84, 0.0)
            enemy.speed = 100.0
            enemy.body_size = Vector2(50, 65)
            enemy.max_health = 10
    
    # Spawn at random arena edge
    enemy.global_position = _get_spawn_position()
    return enemy

func _get_spawn_position() -> Vector2:
    # Spawn just outside the arena on a random edge
    var viewport_size = get_viewport_rect().size
    var edge = randi() % 4  # 0=top, 1=right, 2=bottom, 3=left
    
    match edge:
        0:  # Top — spawn above arena
            return Vector2(randf_range(arena_min.x, arena_max.x), arena_min.y - 40)
        1:  # Right
            return Vector2(arena_max.x + 40, randf_range(arena_min.y, arena_max.y))
        2:  # Bottom
            return Vector2(randf_range(arena_min.x, arena_max.x), arena_max.y + 40)
        3:  # Left
            return Vector2(arena_min.x - 40, randf_range(arena_min.y, arena_max.y))
    return Vector2.ZERO

func _on_enemy_died() -> void:
    enemies_alive -= 1
    enemies_alive_changed.emit(enemies_alive)
    if enemies_alive <= 0:
        start_next_wave()
```

### Step 2: Wire WaveSpawner into main.gd

In `main.gd`, add WaveSpawner child when entering PLAYING state:

```gdscript
func _spawn_player_and_joystick() -> void:
    # ... existing player/joystick code ...
    
    # Create and add WaveSpawner
    var spawner = Node.new()
    spawner.set_script(load("res://scripts/wave_spawner.gd"))
    spawner.name = "WaveSpawner"
    add_child(spawner)
    
    # Initialize spawner with arena bounds
    var viewport_size = get_viewport_rect().size
    var arena_bounds = Rect2(
        Vector2(ARENA_INSET, ARENA_INSET),
        Vector2(viewport_size.x - (ARENA_INSET * 2), viewport_size.y - (ARENA_INSET * 2))
    )
    spawner.initialize(arena_bounds)
```

### Step 3: Update main.tscn

Add WaveSpawner as a child node of Main:

```
[node name="WaveSpawner" type="Node" parent="."]
```

## 4. Validation Plan

### Static Verification
- [ ] `scripts/wave_spawner.gd` exists and extends `Node`
- [ ] Signal declarations: `wave_started(wave_number: int)`, `enemies_alive_changed(count: int)`
- [ ] `@export var` fields for `base_enemy_count` and `enemies_per_wave_increase`
- [ ] `wave_number` and `enemies_alive` tracking variables
- [ ] `_get_wave_composition()` returns correct enemy types per wave number
- [ ] `_create_enemy()` sets correct color, speed, size, health per type
- [ ] `_get_spawn_position()` returns Vector2 along arena perimeter
- [ ] `_on_enemy_died()` decrements `enemies_alive`, emits signal, triggers next wave
- [ ] `main.gd` creates WaveSpawner on PLAYING state entry
- [ ] `main.gd` calls `initialize(arena_bounds)` with correct Rect2

### Smoke Test
- [ ] `godot4 --headless --quit` exits cleanly

## 5. Risks & Assumptions

| Risk | Mitigation |
|------|------------|
| Enemy variants (black, war_horse, boss) don't exist yet | Fallback to `EnemyBase` with appropriate overrides; variants are separate tickets |
| Arena bounds not yet exposed from main | `initialize(arena_bounds)` receives bounds as Rect2 parameter |
| WaveSpawner spawned before arena bounds known | `initialize()` is a separate call after construction |

**Assumptions:**
- EnemyBase exists and is properly configured with collision layers
- Main scene has ARENA_INSET constant for bounds calculation
- Signals from WaveSpawner will be consumed by HUD (CORE-004)

## 6. Acceptance Criteria Mapping

| # | Criterion | Verification |
|---|-----------|--------------|
| 1 | scripts/wave_spawner.gd extends Node with wave_number, enemies_alive tracking | Static: line count, variable declarations |
| 2 | Enemies spawn from random positions on arena edges | Static: `_get_spawn_position()` with 4-edge random selection |
| 3 | Wave composition follows canonical spec | Static: `_get_wave_composition()` branch logic |
| 4 | Next wave starts automatically when enemies_alive reaches 0 | Static: `_on_enemy_died()` checks `enemies_alive <= 0` |
| 5 | Emits wave_started(wave_number) signal for HUD updates | Static: signal declaration + emit call in `start_next_wave()` |
| 6 | Difficulty scales: enemy count increases ~2 per wave | Static: `base_enemy_count + (wave - 1) * enemies_per_wave_increase` |
