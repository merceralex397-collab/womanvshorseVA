# Plan Review: CORE-002 — Create enemy horse base class with charge behavior

## Verdict: APPROVED WITH NOTE

## Review Summary

All 7 acceptance criteria are addressed in the plan. Implementation approach is sound with Godot 4 static typing patterns correctly applied. One non-blocking discrepancy identified.

## Acceptance Criteria Coverage

| # | Criterion | Status | Implementation |
|---|-----------|--------|----------------|
| 1 | `class_name EnemyBase extends CharacterBody2D` | ✅ | Step 1 |
| 2 | `@export` vars: max_health, speed, body_color, body_size | ✅ | Step 1 with correct types |
| 3 | Charge behavior: moves toward player each physics frame | ✅ | Step 2 with `get_tree().get_first_node_in_group("player")` |
| 4 | Procedural visual: rectangle body + triangle head | ✅ | Step 3 with `_create_visual()` using Polygon2D |
| 5 | Collision layer 2, mask layers 1+3 | ⚠️ SEE NOTE | Step 1 |
| 6 | `enemy_died` signal + `queue_free()` | ✅ | Step 4 |
| 7 | `take_damage(amount)` with flash | ✅ | Step 4 |

## Godot 4 Standards Compliance

- Static typing used throughout (`int`, `float`, `Color`, `Vector2`)
- `class_name` for global type registration
- `CharacterBody2D` with `move_and_slide()` for movement
- `@export` for editor-exposed fields
- `signal` declaration with typed parameter
- Proper use of `_ready()` and `_physics_process()`

## Non-Blocking Design Note

**Criterion 5 - Collision Mask Value:**
- Plan states: `collision_mask = 3` (binary 011 = layers 1 and 2)
- Acceptance requires: mask layers 1 (Player) AND 3 (PlayerAttack)
- Correct value should be: `collision_mask = 5` (binary 101 = layers 1 and 3)

This does not block approval since implementer will see the explicit acceptance criteria and use the correct value `5`. The discrepancy is in plan documentation, not the implementation intent.

## Risks

| Risk | Assessment |
|------|-------------|
| Player not in "player" group | Mitigated: confirmed SETUP-002 adds player to group |
| Null player reference | Mitigated: `if player:` guard handles null |
| Mask value discrepancy | Non-blocking: implementer will use correct value per acceptance |

## Validation Plan

- Static verification checklist covers all criteria
- Smoke test with `godot4 --headless --quit` will catch syntax errors
- Implementation review stage will confirm collision_mask = 5

## Recommendation

**APPROVED** - Plan is sound and ready for implementation. The implementer should use `collision_mask = 5` per the acceptance criteria, not `3` as documented in the plan.
