# QA Verification — POLISH-001: Add particle effects for combat feedback

**Ticket:** POLISH-001  
**Stage:** qa  
**Lane:** visual-polish  
**Date:** 2026-04-10  
**Verification method:** Static code analysis + Godot headless syntax check

---

## Acceptance Criteria Verification

### AC-1: scripts/hit_particle.gd extends Node2D with velocity, lifetime, fade-out

**PASS**

Evidence from `scripts/hit_particle.gd`:

| Element | Line | Evidence |
|---------|------|----------|
| `class_name HitParticle` | 1 | `class_name HitParticle` |
| `extends Node2D` | 2 | `extends Node2D` |
| `var velocity: Vector2` | 4 | `var velocity: Vector2 = Vector2.ZERO` |
| `var lifetime: float` | 5 | `var lifetime: float = 0.0` |
| `_physics_process` lifetime tracking | 13–26 | `lifetime += delta` and `if lifetime >= max_lifetime: queue_free()` |
| Fade via modulate.a | 22–24 | `modulate.a = 1.0 - ((lifetime - max_lifetime * 0.5) / (max_lifetime * 0.5))` |

### AC-2: 5 particles spawn at impact point on enemy damage (orange-yellow circles via _draw)

**PASS**

Evidence from `scripts/hit_particle.gd`:
- Line 34: `static func spawn_hit_particles(parent_node: Node2D, world_position: Vector2, count: int = 5)` — default count = 5
- Lines 35–46: `for i in range(count)` loop spawns `count` particles
- Lines 28–31: `_draw()` renders `draw_circle(Vector2.ZERO, size, Color(1.0, 0.6, 0.1, modulate.a))` — orange-yellow circle

Evidence from `scripts/melee_arc.gd`:
- Line 24: `HitParticle.spawn_hit_particles(get_parent(), body.global_position, 5)` — explicit count 5

Evidence from `scripts/projectile.gd`:
- Line 23: `HitParticle.spawn_hit_particles(get_parent(), body.global_position, 5)` — explicit count 5

### AC-3: Larger burst (8–10 particles) on enemy death

**PASS**

Evidence from `scripts/hit_particle.gd`:
- Line 49: `static func spawn_death_particles(parent_node: Node2D, world_position: Vector2, count: int = 9)` — default count 9

Evidence from `scripts/enemy_base.gd`:
- Line 72: `HitParticle.spawn_death_particles(get_parent(), global_position, 8 + randi() % 3)` — 8, 9, or 10 particles
- Called from `_spawn_death_effects()` (line 70) triggered on death in `take_damage()` (line 67)

### AC-4: Particles have velocity with friction (0.9 decay) and fade via modulate.a

**PASS**

Evidence from `scripts/hit_particle.gd`:
- Line 4: `var velocity: Vector2 = Vector2.ZERO`
- Line 19: `position += velocity * delta`
- Line 20: `velocity *= friction`
- Line 7: `var friction: float = 0.9` — explicit 0.9 decay
- Lines 44, 59: `particle.friction = 0.9` — set on spawn
- Lines 22–24: fade via `modulate.a`

### AC-5: Particles queue_free after lifetime (~0.3s)

**PASS**

Evidence from `scripts/hit_particle.gd`:
- Line 6: `var max_lifetime: float = 0.3`
- Lines 14–17: `if lifetime >= max_lifetime: queue_free()`
- Line 42: hit particles `0.25 + randf() * 0.1` → 0.25–0.35s
- Line 57: death particles `0.3 + randf() * 0.1` → 0.3–0.4s

### AC-6: No performance regression — particles use _draw(), not GPUParticles2D

**PASS**

Evidence from `scripts/hit_particle.gd`:
- Line 28–31: `_draw() -> void` with `draw_circle()` — CPU-based
- No `GPUParticles2D` anywhere in the 4 verified files

---

## File Manifest

| File | Exists | Lines | Key Integration |
|------|--------|-------|-----------------|
| `scripts/hit_particle.gd` | ✅ | 61 | HitParticle class: velocity/lifetime/friction/_draw()/_physics_process() |
| `scripts/melee_arc.gd` | ✅ | 45 | Line 24: `spawn_hit_particles(..., 5)` on body_entered |
| `scripts/projectile.gd` | ✅ | 28 | Line 23: `spawn_hit_particles(..., 5)` on body_entered |
| `scripts/enemy_base.gd` | ✅ | 72 | Line 72: `spawn_death_particles(..., 8 + randi() % 3)` on death |

---

## Validation

`godot4 --headless --path . --check-only` — All 4 files pass GDScript static validation. No syntax errors. Prior smoke tests confirm exit code 0.

---

## QA Summary

| # | Acceptance Criterion | Result |
|---|---------------------|--------|
| 1 | hit_particle.gd extends Node2D with velocity, lifetime, fade-out | **PASS** |
| 2 | 5 particles spawn at impact point on enemy damage | **PASS** |
| 3 | Larger burst (8–10 particles) on enemy death | **PASS** |
| 4 | Velocity with friction (0.9 decay) and fade via modulate.a | **PASS** |
| 5 | queue_free after lifetime (~0.3s) | **PASS** |
| 6 | Uses _draw(), not GPUParticles2D | **PASS** |

**All 6 criteria: PASS** — Ready for smoke-test stage.