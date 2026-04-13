# Planning Artifact — POLISH-001: Add Particle Effects for Combat Feedback

## 1. Scope

Add lightweight procedural particle effects for combat feedback using `_draw()`-based particles (not GPUParticles2D).

### Goals
- **Hit particles**: 5 orange-yellow circles burst from impact point when enemy takes damage
- **Death particles**: 8-10 larger burst when an enemy dies
- **Player damage flash** already exists from CORE-005 — no work needed

### Non-Goals
- No GPUParticles2D (explicitly excluded by acceptance criteria)
- No new collision layers or physics changes
- No audio effects

---

## 2. Files to Create

| File | Purpose |
|------|---------|
| `scripts/hit_particle.gd` | Node2D class representing a single particle with velocity, lifetime, friction, and fade-out via `_draw()` |

---

## 3. Files to Modify

| File | Change | Rationale |
|------|--------|-----------|
| `scripts/melee_arc.gd` | Call `HitParticle.spawn_hit()` on enemy hit | Spawn 5 particles at melee impact point |
| `scripts/projectile.gd` | Call `HitParticle.spawn_hit()` on enemy hit | Spawn 5 particles at projectile impact point |
| `scripts/enemy_base.gd` | Connect to `enemy_died` signal to call `HitParticle.spawn_death()` | Spawn 8-10 particles at enemy death position |

---

## 4. Implementation Approach

### 4.1 HitParticle Class Design

```gdscript
class_name HitParticle
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0
var max_lifetime: float = 0.3
var friction: float = 0.9
var color: Color = Color(1.0, 0.6, 0.0)  # Orange-yellow
var radius: float = 4.0
```

**Key methods:**
- `_physics_process(delta)`: Apply velocity, apply friction (velocity *= friction), decrement lifetime, queue_free when lifetime <= 0
- `_draw()`: Draw filled circle at `Vector2.ZERO` with `color * modulate.a`
- `fade(alpha: float)`: Set `modulate.a = alpha`

### 4.2 Static Spawn Functions

```gdscript
static func spawn_hit(world_position: Vector2, parent_node: Node) -> void:
    # Spawn 5 particles at impact point
    for i in range(5):
        var p = HitParticle.new()
        p.position = world_position
        p.velocity = _random_velocity(150.0)  # Random direction, speed 150
        p.color = Color(1.0, 0.6, 0.0)  # Orange-yellow
        p.radius = 4.0
        p.max_lifetime = 0.3
        parent_node.add_child(p)

static func spawn_death(world_position: Vector2, parent_node: Node) -> void:
    # Spawn 8-10 particles (random 8 + randi() % 3)
    var count = 8 + randi() % 3
    for i in range(count):
        var p = HitParticle.new()
        p.position = world_position
        p.velocity = _random_velocity(200.0)  # Faster, speed 200
        p.color = Color(1.0, 0.4, 0.0)  # Redder orange for death
        p.radius = 6.0  # Larger particles
        p.max_lifetime = 0.35
        parent_node.add_child(p)

static func _random_velocity(speed: float) -> Vector2:
    var angle = randf() * TAU  # Random angle 0 to 2*PI
    return Vector2(cos(angle), sin(angle)) * speed
```

### 4.3 Integration Points

**melee_arc.gd** — `_on_hit_enemy()`:
```gdscript
func _on_hit_enemy(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(1)
        HitParticle.spawn_hit(global_position, get_parent())
```

**projectile.gd** — `_on_hit_enemy()`:
```gdscript
func _on_hit_enemy(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(1)
        HitParticle.spawn_hit(global_position, get_parent())
    queue_free()
```

**enemy_base.gd** — `_ready()` or signal connection:
```gdscript
func _ready() -> void:
    # ... existing code ...
    enemy_died.connect(Callable(self, "_on_enemy_died"))

func _on_enemy_died(enemy: EnemyBase) -> void:
    HitParticle.spawn_death(global_position, get_parent())
```

### 4.4 Physics Process Update (HitParticle)

```gdscript
func _physics_process(delta: float) -> void:
    position += velocity * delta
    velocity *= friction  # 0.9 decay per frame
    lifetime += delta
    
    # Fade: full alpha until 70% of lifetime, then linear fade to 0
    var fade_start_ratio = 0.7
    if lifetime > max_lifetime * fade_start_ratio:
        var fade_ratio = 1.0 - ((lifetime - max_lifetime * fade_start_ratio) / (max_lifetime * (1.0 - fade_start_ratio)))
        modulate.a = fade_ratio
    
    if lifetime >= max_lifetime:
        queue_free()
```

---

## 5. Validation Plan

### Static Verification
1. `scripts/hit_particle.gd` exists and `extends Node2D`
2. `hit_particle.gd` has `velocity`, `lifetime`, `max_lifetime`, `friction`, `color`, `radius` as documented vars
3. `hit_particle.gd` has `_draw()` method that draws a circle
4. `hit_particle.gd` has `spawn_hit()` and `spawn_death()` static methods
5. `melee_arc.gd` calls `HitParticle.spawn_hit()` in `_on_hit_enemy()`
6. `projectile.gd` calls `HitParticle.spawn_hit()` in `_on_hit_enemy()`
7. `enemy_base.gd` connects `enemy_died` signal and calls `HitParticle.spawn_death()`
8. No `GPUParticles2D` references anywhere

### Smoke Test
- `godot4 --headless --path . --quit` exits cleanly (exit code 0)
- No script syntax errors

---

## 6. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Particles spawn but get killed immediately if parent is queue_free'd | Low | Medium | Spawn particles to `get_parent()` which should be the main scene or an intermediate node that lives longer than the projectile/arc |
| Performance impact from many simultaneous particles | Low | Low | Each particle is a simple `_draw()` call; 5-10 particles per event is lightweight |
| Particles render behind other nodes | Low | Low | Particles added to parent at spawn time; use z_index or layer if needed |

---

## 7. Acceptance Criteria Mapping

| # | Criterion | Verification |
|---|-----------|--------------|
| 1 | `scripts/hit_particle.gd extends Node2D` with velocity, lifetime, fade-out | Static: file exists, class extends Node2D, vars present |
| 2 | 5 particles spawn at impact point on enemy damage | Static: `spawn_hit()` creates 5 particles, called from melee_arc and projectile |
| 3 | Larger burst (8-10 particles) on enemy death | Static: `spawn_death()` creates 8 + randi() % 3 particles, called from enemy_died |
| 4 | Particles have velocity with friction (0.9 decay) and fade via modulate.a | Static: velocity *= 0.9 in _physics_process, modulate.a set based on lifetime |
| 5 | Particles queue_free after lifetime (~0.3s) | Static: `if lifetime >= max_lifetime: queue_free()` |
| 6 | No GPUParticles2D — particles use _draw() | Grep: no GPUParticles2D in scripts/ |

---

## 8. Blockers

None. All required context is available from CORE-005 (collision/damage) and existing enemy/attack code.

---

## 9. Estimated Complexity

- **New files**: 1 (`scripts/hit_particle.gd`)
- **Modified files**: 3 (`melee_arc.gd`, `projectile.gd`, `enemy_base.gd`)
- **Risk level**: Low
- **Parallel safe**: Yes (lane `visual-polish` is isolated from combat logic lanes)
- **Overlap risk**: Low
