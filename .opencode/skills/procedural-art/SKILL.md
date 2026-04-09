---
name: procedural-art
description: GDScript procedural sprite generation patterns for Route A (colored shapes, no external assets). Use when implementing any visual element — player, enemies, UI, particles, or arena.
---

# Procedural Art — GDScript Sprite Generation

Before applying these patterns, call `skill_ping` with `skill_id: "procedural-art"` and `scope: "project"`.

## Core Principle

All visual content is generated programmatically via GDScript. No image files, no imported assets. Every sprite is built from colored polygons, `_draw()` calls, or Polygon2D nodes.

## Two Rendering Approaches

### 1. Polygon2D Nodes (Preferred for Static Shapes)
```gdscript
# Create in _ready() or scene tree
var body := Polygon2D.new()
body.polygon = PackedVector2Array([
    Vector2(-15, -20), Vector2(15, -20),
    Vector2(15, 20), Vector2(-15, 20)
])
body.color = Color.GREEN
add_child(body)
```

### 2. Custom _draw() (Preferred for Dynamic Shapes)
```gdscript
extends Node2D

func _draw() -> void:
    # Rectangle body
    draw_rect(Rect2(-15, -20, 30, 40), Color.GREEN)
    # Sword indicator (triangle)
    draw_colored_polygon(
        PackedVector2Array([
            Vector2(0, -25), Vector2(-5, -20), Vector2(5, -20)
        ]),
        Color.WHITE
    )

# Call queue_redraw() when visual state changes
func update_facing(angle: float) -> void:
    rotation = angle
    queue_redraw()
```

**When to use which:**
- Polygon2D: character bodies, arena borders, static UI elements
- `_draw()`: health bars, dynamic indicators, attack arcs, particles

## Character Recipes

### Player Character
- Green rectangle body (30×40px)
- White triangle sword indicator on facing side
- Flashes white on damage (modulate tween)

```gdscript
func _create_player_visual() -> void:
    # Body
    var body := Polygon2D.new()
    body.polygon = PackedVector2Array([
        Vector2(-15, -20), Vector2(15, -20),
        Vector2(15, 20), Vector2(-15, 20)
    ])
    body.color = Color.GREEN
    body.name = "Body"
    add_child(body)

    # Sword indicator
    var sword := Polygon2D.new()
    sword.polygon = PackedVector2Array([
        Vector2(0, -30), Vector2(-6, -20), Vector2(6, -20)
    ])
    sword.color = Color.WHITE
    sword.name = "SwordIndicator"
    add_child(sword)
```

### Enemy Recipes

| Type | Color | Size | Extra |
|------|-------|------|-------|
| Brown Horse | `Color(0.6, 0.4, 0.2)` | 25×35 | — |
| Black Horse | `Color(0.2, 0.2, 0.2)` | 25×35 | Speed lines (two thin rects behind) |
| War Horse | `Color(0.8, 0.2, 0.2)` | 35×50 | Larger, thicker outline |
| Boss | `Color(1.0, 0.84, 0.0)` | 50×65 | Gold with pulsing modulate |

```gdscript
func _create_horse_visual(color: Color, size: Vector2) -> void:
    # Rectangular horse body
    var body := Polygon2D.new()
    var hw := size.x / 2.0
    var hh := size.y / 2.0
    body.polygon = PackedVector2Array([
        Vector2(-hw, -hh), Vector2(hw, -hh),
        Vector2(hw, hh), Vector2(-hw, hh)
    ])
    body.color = color
    add_child(body)

    # Head indicator (small triangle in movement direction)
    var head := Polygon2D.new()
    head.polygon = PackedVector2Array([
        Vector2(0, -hh - 8), Vector2(-5, -hh), Vector2(5, -hh)
    ])
    head.color = color.lightened(0.2)
    add_child(head)
```

## Arena

```gdscript
func _draw_arena_border() -> void:
    var rect := Rect2(50, 50, 1180, 620)  # inset from viewport
    draw_rect(rect, Color.WHITE, false, 3.0)  # outline only
```

Use the viewport-relative approach:
```gdscript
var vp_size := get_viewport_rect().size
var margin := 50.0
var arena_rect := Rect2(margin, margin, vp_size.x - margin * 2, vp_size.y - margin * 2)
```

## HUD Elements

### Health Hearts
```gdscript
func _draw_heart(center: Vector2, filled: bool) -> void:
    var color := Color.RED if filled else Color(0.3, 0.3, 0.3)
    # Simple heart as two overlapping circles + triangle
    draw_circle(center + Vector2(-5, -3), 6, color)
    draw_circle(center + Vector2(5, -3), 6, color)
    draw_colored_polygon(PackedVector2Array([
        center + Vector2(-10, 0),
        center + Vector2(10, 0),
        center + Vector2(0, 12)
    ]), color)
```

### Score and Wave Labels
Use `Label` nodes with dynamic font size. No custom font files needed — Godot default font works.

```gdscript
var label := Label.new()
label.text = "WAVE 1"
label.add_theme_font_size_override("font_size", 24)
label.add_theme_color_override("font_color", Color.WHITE)
```

## Attack Visuals

### Melee Arc
```gdscript
func _draw_melee_arc(center: Vector2, direction: float, radius: float) -> void:
    var arc_points: PackedVector2Array = [center]
    var arc_angle := PI / 3.0  # 60-degree arc
    var steps := 8
    for i in range(steps + 1):
        var angle := direction - arc_angle / 2.0 + arc_angle * (float(i) / steps)
        arc_points.append(center + Vector2.from_angle(angle) * radius)
    draw_colored_polygon(arc_points, Color(1, 1, 1, 0.5))
```

### Projectile
```gdscript
# Small bright circle that moves in a direction
func _draw() -> void:
    draw_circle(Vector2.ZERO, 4, Color.YELLOW)
```

## Particle Effects (Combat Feedback)

Use lightweight `_draw()` particles, not Godot's GPUParticles2D (overkill for shapes):

```gdscript
class_name HitParticle
extends Node2D

var velocity: Vector2
var lifetime: float = 0.3
var _age: float = 0.0
var _color: Color

func _ready() -> void:
    _color = Color(1, 0.8, 0.2)  # orange-yellow

func _process(delta: float) -> void:
    _age += delta
    position += velocity * delta
    velocity *= 0.9  # friction
    if _age >= lifetime:
        queue_free()
    else:
        modulate.a = 1.0 - (_age / lifetime)
        queue_redraw()

func _draw() -> void:
    draw_circle(Vector2.ZERO, 3, _color)
```

### Spawn Hit Particles
```gdscript
func _spawn_hit_particles(pos: Vector2, count: int = 5) -> void:
    for i in range(count):
        var p := HitParticle.new()
        p.position = pos
        p.velocity = Vector2.from_angle(randf() * TAU) * randf_range(50, 150)
        get_parent().add_child(p)
```

## Damage Flash Pattern

```gdscript
func _flash_damage() -> void:
    modulate = Color.WHITE * 3.0  # bright flash
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 0.15)
```

## Mobile Performance Rules

- Keep total node count under 200 for smooth 60fps on mid-range Android
- Prefer `_draw()` batch calls over many Polygon2D children for particles
- Use `queue_redraw()` only when visual state actually changes
- Avoid per-frame `String` allocations in score/wave labels — update only on change
- Use object pooling for projectiles and particles if count exceeds ~30 simultaneous
- `set_process(false)` on nodes that don't need per-frame updates (static arena, inactive UI)
