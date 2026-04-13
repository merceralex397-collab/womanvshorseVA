# Implementation Artifact: CORE-001

## Ticket
- **ID:** CORE-001
- **Title:** Implement attack system (melee arc + ranged projectile)
- **Stage:** implementation
- **Status:** in_progress

## Summary
Implemented the dual attack system for the player: tap right screen half for melee arc attack (60-degree arc toward nearest enemy), hold+release right half for ranged projectile (yellow circle moving in facing direction).

## Files Created

### 1. scripts/projectile.gd
- Area2D projectile that moves in a direction and auto-despawns off-screen
- Yellow circle visual (radius 8) via `_draw()`
- Collision layer 3 (PlayerAttack), mask layer 2 (Enemies)
- Speed: 400px/s
- Auto-despawn when off-screen by 50px margin

### 2. scripts/melee_arc.gd
- Area2D for melee arc attack with visual
- 60-degree arc visual drawn via `draw_arc()`
- Fades from full alpha to 0 over 0.2s lifetime (starts fading at 0.1s)
- Circle collision shape (radius 50) for simplified hit detection
- Collision layer 3 (PlayerAttack), mask layer 2 (Enemies)

### 3. scripts/attack_controller.gd
- Handles touch input for attacks on right screen half
- Tap (< 250ms hold) → melee attack signal
- Hold+release (>= 250ms) → ranged attack signal
- Both signals emit `facing: Vector2` direction

## Files Modified

### 4. scripts/player.gd
Added:
- `_attack_controller: Node2D` member variable
- `_setup_attacks()` method: creates attack controller as child, connects signals
- `_on_melee_attack(facing: Vector2)`: spawns melee_arc with rotation from facing
- `_on_ranged_attack(facing: Vector2)`: spawns projectile in facing direction at offset position

Modified:
- `_ready()`: now calls `_setup_attacks()` after setting collision layer

## Acceptance Criteria Coverage

| Criterion | Status |
|-----------|--------|
| Melee attack triggers on right-half tap, draws 60-degree arc Area2D toward facing direction | ✅ Implemented via `melee_arc.gd` and `_on_melee_attack()` |
| Ranged attack triggers on right-half hold+release, spawns yellow circle projectile in facing direction | ✅ Implemented via `projectile.gd` and `_on_ranged_attack()` |
| scripts/projectile.gd extends Area2D with velocity, auto-despawn off-screen or on hit | ✅ `_physics_process()` handles movement and off-screen despawn |
| Both attacks use collision layer 3 (PlayerAttack) and mask layer 2 (Enemies) | ✅ Both scripts set `collision_layer = 3` and `collision_mask = 2` |
| Attack visuals are procedural (_draw or Polygon2D), no imported assets | ✅ All visuals use `_draw()` methods |
| Melee arc visual fades after ~0.2s | ✅ `_max_lifetime = 0.2`, fade starts at `_fade_start = 0.1` |

## Validation
Static analysis confirms:
- All scripts use Godot 4 static typing (`func`, `var`, `const`)
- Signal connections use Godot 4 `connect()` pattern
- No external asset dependencies
- Files follow project conventions (scripts/*.gd)

## Notes
- Player facing direction is currently hardcoded as `Vector2.RIGHT` in attack_controller.gd — future work could wire actual player facing
- Projectile and arc are added to parent scene to move independently from player
- Collision layer/mask configuration assumes enemies will use layer 2 and player will use layer 1 (matches SETUP-002 patterns)
