# Plan: CORE-002 — Create enemy horse base class with charge behavior

## 1. Scope

Create `scripts/enemy_base.gd` as the base enemy class with charge behavior, procedural visual, and damage system.

## 2. Files / Systems Affected

| File | Action |
|------|--------|
| `scripts/enemy_base.gd` | Create — new file |
| `scenes/main.tscn` | Modify — add EnemyBase scene instance for testing |
| `scripts/main.gd` | Modify — add enemy spawn logic in PLAYING state |

## 3. Implementation Steps

### Step 1: Create `scripts/enemy_base.gd`
- Extend `CharacterBody2D` with `class_name EnemyBase`
- Define `@export` vars: `max_health: int`, `speed: float`, `body_color: Color`, `body_size: Vector2`
- Add `signal enemy_died(enemy: EnemyBase)`
- `health` member variable initialized to `max_health` in `_ready()`
- Set `collision_layer = 2` (Enemies), `collision_mask = 3` (Player + PlayerAttack)
- Call `_create_visual()` from `_ready()`

### Step 2: Implement `_physics_process(delta)`
- Get player node via `get_tree().get_first_node_in_group("player")`
- Calculate direction to player, normalize, set `velocity = direction * speed`
- Call `move_and_slide()`
- Update `rotation` to face player when direction != ZERO
- Handle flash timer countdown and reset modulate

### Step 3: Implement `_create_visual()`
- Create `Polygon2D` named "Body" with rectangle polygon using `body_size`, color `body_color`
- Create `Polygon2D` named "Head" with triangle polygon (front of horse), lighter shade
- Add both as children

### Step 4: Implement `take_damage(amount: int)`
- Decrement `health` by `amount`
- Set `_is_flashing = true`, `_flash_timer = 0.15`, `modulate = Color(1.5, 1.5, 1.5)`
- If `health <= 0`: emit `enemy_died.emit(self)`, call `queue_free()`

### Step 5: Add enemy spawn in main.gd
- In PLAYING state, spawn one `EnemyBase` for validation
- Add spawned enemy to "enemies" group

## 4. Validation Plan

### Static Verification
- [ ] `scripts/enemy_base.gd` exists and contains `class_name EnemyBase extends CharacterBody2D`
- [ ] `@export var max_health: int`, `@export var speed: float`, `@export var body_color: Color`, `@export var body_size: Vector2` all present
- [ ] `signal enemy_died(enemy: EnemyBase)` declared
- [ ] `collision_layer = 2`, `collision_mask = 3` set in `_ready()`
- [ ] `take_damage(amount: int)` method implemented
- [ ] `_physics_process` contains charge logic with `get_tree().get_first_node_in_group("player")`
- [ ] `_create_visual()` creates Body and Head Polygon2D nodes
- [ ] `queue_free()` called on death after signal emission

### Smoke Test
- Run `godot4 --headless --quit` to verify no GDScript syntax errors

## 5. Risks / Assumptions

| Risk | Mitigation |
|------|------------|
| Player node not in "player" group | Spawner must add player to group; confirmed in SETUP-002 |
| `get_first_node_in_group` returns null | Check null before using direction; handled with `if player:` guard |
| Collision mask values wrong | Layer 1=Player, 3=PlayerAttack per SETUP-002 and CORE-001 |

## 6. Acceptance Mapping

| Criterion | Implementation |
|-----------|----------------|
| 1. `class_name EnemyBase extends CharacterBody2D` | Line 2-3 of enemy_base.gd |
| 2. `@export` vars | Lines 7-10 |
| 3. Charge behavior | `_physics_process` with player-facing direction |
| 4. Procedural visual | `_create_visual()` with Polygon2D body + head |
| 5. Collision layer 2, mask 3 | `collision_layer = 2; collision_mask = 3` in `_ready` |
| 6. `enemy_died` signal + `queue_free()` | `enemy_died.emit(self)` then `queue_free()` |
| 7. `take_damage(amount)` method | Full implementation with health decrement + flash |