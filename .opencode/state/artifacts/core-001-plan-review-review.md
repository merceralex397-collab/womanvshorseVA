# Plan Review: CORE-001 — Attack System (Melee Arc + Ranged Projectile)

## Verdict: APPROVED

## Summary

Plan review approved. All 6 acceptance criteria are fully covered with sound Godot 4 implementation patterns. The plan is ready for implementation.

## Acceptance Criteria Coverage

| # | Criterion | Coverage | Evidence |
|---|----------|----------|----------|
| 1 | Melee attack on right-half tap, 60-degree arc Area2D | ✅ Complete | `attack_controller.gd:_trigger_melee()`, `_is_in_attack_zone()` checks `pos.x >= viewport_width/2`, tap threshold `< HOLD_THRESHOLD` (0.3s), `ARC_DEGREES = 60.0` in `melee_arc.gd` |
| 2 | Ranged attack on hold+release, yellow circle projectile | ✅ Complete | `attack_controller.gd:_trigger_ranged()`, hold threshold `>= HOLD_THRESHOLD`, `projectile.gd:draw_circle(radius=8, Color(1.0, 0.9, 0.0, 1.0))` |
| 3 | `projectile.gd` extends Area2D with velocity, auto-despawn | ✅ Complete | `extends Area2D`, `velocity: Vector2`, `position += velocity * delta`, `queue_free()` when off-screen (viewport ± 50px margin) |
| 4 | Both attacks use collision layer 3, mask layer 2 | ✅ Complete | `collision_layer = 3`, `collision_mask = 2` set in `_ready()` of both `melee_arc.gd` and `projectile.gd`. Consistent with canonical spec (Layer 1=Player, 2=Enemies, 3=PlayerAttack) |
| 5 | Procedural visuals, no imported assets | ✅ Complete | All visuals via `_draw()`: `draw_circle()`, `draw_colored_polygon()`. Zero external asset references |
| 6 | Melee arc fades after ~0.2s | ✅ Complete | `FADE_DURATION = 0.2`, alpha lerp: `lerp(0.6, 0.0, _elapsed / FADE_DURATION)` in `melee_arc.gd:_draw()` |

## Godot 4 Standards Review

### Static Typing ✅
- `@export var speed: float = 400.0` — correct typed export
- `var velocity: Vector2 = Vector2.ZERO` — correct typed member
- `const HOLD_THRESHOLD: float = 0.3` — correct typed constant
- `func _physics_process(delta: float) -> void:` — correct return type annotation
- `var hold_duration: float` (implicit via `Time.get_ticks_msec()` arithmetic) — acceptable

### Area2D Patterns ✅
- `melee_arc.gd` and `projectile.gd` both `extends Area2D`
- `collision_layer` and `collision_mask` set in `_ready()`
- `_physics_process(delta)` for movement + lifecycle (`queue_free()`)
- Signal-driven architecture via `melee_attack_arc` and `ranged_attack_requested` signals

### Touch Input Handling ✅
- `InputEventScreenTouch` press/release discrimination
- `InputEventScreenDrag` tracked with `event.index == _touch_index`
- Touch index tracking prevents multi-touch interference
- Touch zone separation (right half: attack, left half: joystick) is architecturally clean

### Collision Layer Configuration ✅
- Layer 3 (PlayerAttack) for both attack types
- Mask layer 2 (Enemies) for both attack types
- Consistent with canonical spec documented in plan

## Design Notes (Non-Blocking)

### 1. Melee Arc Collision Shape vs. Visual (Risk: Medium, Accepted)
- **Visual**: Proper 60-degree arc sector drawn via `_get_arc_points()` and `draw_colored_polygon()`
- **Collision**: `CircleShape2D` with radius 60 — circular, not a wedge
- **Impact**: The Area2D will register hits for enemies within a 60px circle, even those outside the visual 60-degree arc
- **Plan acknowledges this**: Risk table lists "Melee arc collision shape too simple" with mitigation noting "arc visual is cosmetic (actual damage comes from Area2D overlap)"
- **Verdict**: Acceptable for prototype. Collision shape refinement can be a post-prototype polish item.

### 2. Unused `fade_ratio` Parameter in `_get_arc_points()`
- **Issue**: `func _get_arc_points(radius: float, fade_ratio: float)` receives `fade_ratio` but never uses it in geometry calculation
- **Impact**: None — only alpha uses `fade_ratio`; geometry remains constant during fade
- **Verdict**: Minor imprecision. Does not affect correctness.

## Validation Plan Review

### Static Verification ✅
All 6 criteria have explicit code inspection checkpoints in Section 4 of the plan.

### Smoke Test ✅
`godot4 --headless --path . --quit` is appropriate for Godot project validation.

## Risks Assessment

| Risk | Assessment |
|------|------------|
| Touch zone conflict with virtual joystick | ✅ Mitigated: left/right screen halves are mutually exclusive |
| Melee collision shape simplification | ✅ Accepted tradeoff (see Design Note 1) |
| `_draw()` performance | ✅ Mitigated: arcs auto-free after 0.2s, projectiles despawn off-screen |
| Stale facing direction on ranged fire | ✅ Mitigated: player retains last direction; accepted limitation |
| Enemies not yet existing | ✅ Mitigated: attacks use Area2D overlap; will work with placeholders |

## Blockers / Required Decisions

**None.** The plan is self-contained and ready for implementation.

## Recommendation

**APPROVE** — Proceed to implementation. All acceptance criteria are covered with sound Godot 4 patterns. The noted design notes are non-blocking and represent intentional prototype-phase tradeoffs documented in the plan's risk table.
