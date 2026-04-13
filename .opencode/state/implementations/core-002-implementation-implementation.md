# Implementation for CORE-002: Create enemy horse base class with charge behavior

## Summary
Created `scripts/enemy_base.gd` as the base enemy class with charge behavior, health system, procedural visual, and damage handling.

## Files Created

### scripts/enemy_base.gd
- `class_name EnemyBase` extends `CharacterBody2D`
- `@export` vars: `max_health` (int, default 1), `speed` (float, default 80.0), `body_color` (Color, brown default), `body_size` (Vector2, 25x35 default)
- `enemy_died` signal emitted on death
- `take_damage(amount: int)` method with flash effect
- Procedural visual: Polygon2D body rectangle + lighter head triangle
- Charge behavior: moves toward player each physics frame, rotates to face player
- Collision layer 2 (Enemies), collision mask 5 (Player + PlayerAttack)

## Acceptance Criteria Coverage

| # | Criterion | Status |
|---|-----------|--------|
| 1 | scripts/enemy_base.gd extends CharacterBody2D with class_name EnemyBase | ✅ |
| 2 | Has @export vars: max_health, speed, body_color, body_size | ✅ |
| 3 | Charge behavior: moves toward player position each physics frame | ✅ |
| 4 | Procedural visual: colored rectangle body + lighter triangle head indicator | ✅ |
| 5 | Collision layer 2 (Enemies), mask 5 (Player + PlayerAttack) | ✅ |
| 6 | Emits enemy_died signal on death, calls queue_free() | ✅ |
| 7 | take_damage(amount) method decrements health and triggers flash | ✅ |

## Plan Review Correction
- collision_mask = 5 (Player layer 1 + PlayerAttack layer 4) as noted in plan review, not 3
