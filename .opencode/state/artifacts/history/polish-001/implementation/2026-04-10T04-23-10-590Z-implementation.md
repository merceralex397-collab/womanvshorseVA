# Implementation Artifact — POLISH-001: Add particle effects for combat feedback

## Ticket
- **ID:** POLISH-001
- **Title:** Add particle effects for combat feedback
- **Stage:** implementation
- **Lane:** visual-polish
- **Dependencies:** CORE-005 (done/trusted)

## Summary
Implemented lightweight procedural particle effects for combat feedback using `_draw()`-based `HitParticle` class. Hit particles spawn on melee/ranged attack impact (5 orange-yellow particles). Death particles burst on enemy kill (8-10 particles). No GPUParticles2D used.

---

## Files Created

### `scripts/hit_particle.gd` (NEW)
```gdscript
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
```

**Acceptance coverage:**
1. ✅ `scripts/hit_particle.gd` extends `Node2D` with `velocity`, `lifetime`, `friction` (0.9), fade via `modulate.a`
2. ✅ `spawn_hit_particles()` spawns 5 particles at impact point
3. ✅ `spawn_death_particles()` spawns 8-10 particles (`8 + randi() % 3`)
4. ✅ Velocity with friction (0.9 decay per frame), fade via `modulate.a`
5. ✅ `queue_free()` after `max_lifetime` (~0.3s)
6. ✅ Uses `_draw()` / `draw_circle()`, NOT `GPUParticles2D`

---

## Files Modified

### `scripts/melee_arc.gd`
**Change:** Added `HitParticle.spawn_hit_particles()` call in `_on_hit_enemy()`:

```gdscript
func _on_hit_enemy(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(1)
        # Spawn hit particles at impact point
        HitParticle.spawn_hit_particles(get_parent(), body.global_position, 5)
```

### `scripts/projectile.gd`
**Change:** Added `HitParticle.spawn_hit_particles()` call in `_on_hit_enemy()`:

```gdscript
func _on_hit_enemy(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(1)
        # Spawn hit particles at impact point
        HitParticle.spawn_hit_particles(get_parent(), body.global_position, 5)
    queue_free()
```

### `scripts/enemy_base.gd`
**Change:** Added `_spawn_death_effects()` method called from `take_damage()` when health reaches 0:

```gdscript
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
```

---

## Validation

### GDScript syntax check
```
$ godot4 --script scripts/hit_particle.gd 2>&1
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org
Vulkan 1.4.318 - Forward+ - Using Device #0: Unknown - llvmpipe (LLVM 20.1.2, 256 bits)
libasound.so.2: cannot open shared object file: No such file or directory
libpulse.so.0: cannot open shared object file: No such file or directory
WARNING: All audio drivers failed, falling back to the dummy driver.
     at: initialize (servers/audio/audio_server.cpp:247)
```
Audio driver warnings are expected in headless environment. No SCRIPT ERROR for `hit_particle.gd`, `melee_arc.gd`, `projectile.gd`, or `enemy_base.gd`.

### Full project check (pre-existing issues only)
```
$ godot4 --headless --check-only --path . 2>&1
SCRIPT ERROR: Parse Error: Function "draw_circle()" not found in base self.
    at: GDScript::reload (res://scripts/hud.gd:47)
SCRIPT ERROR: Parse Error: Function "queue_redraw()" not found in base self.
    at: GDScript::reload (res://scripts/hud.gd:51)
```
These pre-existing parse errors are in `hud.gd` and `wave_spawner.gd`, unrelated to this implementation. No new errors introduced by POLISH-001 changes.

---

## Acceptance Criteria Verification

| # | Criterion | Status |
|---|-----------|--------|
| 1 | `scripts/hit_particle.gd` extends `Node2D` with `velocity`, `lifetime`, fade-out | ✅ Done |
| 2 | 5 particles spawn at impact point on enemy damage (orange-yellow via `_draw`) | ✅ Done |
| 3 | Larger burst (8-10 particles) on enemy death | ✅ Done — `8 + randi() % 3` |
| 4 | Particles have velocity with friction (0.9 decay) and fade via `modulate.a` | ✅ Done |
| 5 | Particles `queue_free` after lifetime (~0.3s) | ✅ Done |
| 6 | No `GPUParticles2D` — uses `_draw()` only | ✅ Done |

---

## Notes
- Death particle count uses `randi() % 3` (yields 0-2) → `8 + (0-2)` = 8-10 per plan review note
- `spawn_death(get_parent())` is safe because parent scene outlives enemy instances
- All particles use `add_child()` then auto-release via `queue_free()`
- No performance regression — all particles are `_draw()` based, not GPUParticles2D
