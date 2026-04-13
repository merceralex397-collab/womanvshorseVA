# Planning Artifact: CORE-005

## Ticket
- **ID:** CORE-005
- **Title:** Implement collision and damage system
- **Wave:** 2
- **Lane:** combat-system
- **Stage:** planning
- **Status:** todo
- **Depends on:** CORE-001 (done/trusted), CORE-002 (done/trusted)

## Summary
Wire up collision detection between player attacks and enemies, and between enemies and player. Player attacks (layer 3) damage enemies on contact. Enemy bodies (layer 2) damage player on overlap with player (layer 1). Implement damage flash, invincibility frames for player (~0.5s), score increment on enemy kill, and game over at 0 HP.

---

## Scope

### Goals
1. Player attacks (melee arc + projectile) damage enemies on Area2D contact
2. Enemy bodies damage player on CharacterBody2D overlap
3. Player receives ~0.5s invincibility after taking damage with white flash
4. Score increments via existing wave_spawner signal on enemy kill
5. Game state transitions to GAME_OVER when player HP reaches 0
6. Damage flash uses modulate tween (white → normal in 0.15s)

### Files to Modify
| File | Changes |
|------|---------|
| `scripts/player.gd` | Add invincibility frames, damage flash via modulate tween, Area2D for enemy contact detection, connect to game over |
| `scripts/projectile.gd` | Connect `body_entered` signal to enemy `take_damage()` |
| `scripts/melee_arc.gd` | Connect `body_entered` signal to enemy `take_damage()` |
| `scripts/main.gd` | Handle GAME_OVER state transition, stop wave spawner |

### Files to Create
None required — existing attack and enemy infrastructure is sufficient.

---

## Implementation Steps

### Step 1: Add player invincibility infrastructure to `player.gd`
**Rationale:** Player needs to track invincibility state and prevent repeated damage during the ~0.5s window.

Add to `player.gd`:
```gdscript
var _is_invincible: bool = false
var _invincibility_timer: float = 0.0
const INVINCIBILITY_DURATION: float = 0.5
const DAMAGE_FLASH_DURATION: float = 0.15
```

### Step 2: Add Area2D contact sensor to `player.gd`
**Rationale:** CharacterBody2D doesn't have built-in overlap detection. An Area2D child on layer 1 (Player) with mask layer 2 (Enemies) will detect enemy contact.

In `_ready()` or after body setup, add:
```gdscript
var contact_sensor := Area2D.new()
contact_sensor.name = "ContactSensor"
contact_sensor.collision_layer = 1  # Player layer
contact_sensor.collision_mask = 2   # Enemies layer
var shape := CircleShape2D.new()
shape.radius = 20.0
var collision := CollisionShape2D.new()
collision.shape = shape
contact_sensor.add_child(collision)
add_child(contact_sensor)
contact_sensor.connect("body_entered", _on_enemy_contact)
```

### Step 3: Wire projectile damage in `projectile.gd`
**Rationale:** Projectile is an Area2D that already has the correct collision layer/mask, but needs signal connection to deal damage.

Modify `projectile.gd` `_ready()`:
```gdscript
func _ready() -> void:
    collision_layer = 3  # PlayerAttack layer
    collision_mask = 2  # Enemies layer
    connect("body_entered", _on_hit_enemy)
    var collision := CollisionShape2D.new()
    collision.shape = shape
    add_child(collision)

func _on_hit_enemy(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(1)
    queue_free()
```

### Step 4: Wire melee arc damage in `melee_arc.gd`
**Rationale:** Same as projectile — Area2D already configured, needs signal connection.

Modify `melee_arc.gd`:
```gdscript
func _ready() -> void:
    collision_layer = 3
    collision_mask = 2
    connect("body_entered", _on_hit_enemy)
    var collision := CollisionShape2D.new()
    collision.shape = shape
    add_child(collision)

func _on_hit_enemy(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(1)
```

### Step 5: Implement player damage handler in `player.gd`
**Rationale:** Handle enemy contact, apply invincibility, trigger damage flash, check for game over.

Add `_on_enemy_contact(body: Node2D)`:
```gdscript
func _on_enemy_contact(body: Node2D) -> void:
    if _is_invincible:
        return
    take_damage(1)
    _start_invincibility()
    _flash_damage()
```

Add helper methods:
```gdscript
func _start_invincibility() -> void:
    _is_invincible = true
    _invincibility_timer = INVINCIBILITY_DURATION

func _flash_damage() -> void:
    modulate = Color(2.0, 2.0, 2.0)  # White flash (brighter than enemy's 1.5)
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, DAMAGE_FLASH_DURATION)
```

Add to `_physics_process()`:
```gdscript
if _is_invincible:
    _invincibility_timer -= delta
    if _invincibility_timer <= 0:
        _is_invincible = false
        modulate = Color.WHITE
```

### Step 6: Modify `take_damage()` in `player.gd`
**Rationale:** Current implementation just quits. Need to emit signal and check for game over.

Replace `take_damage()`:
```gdscript
func take_damage(amount: int) -> void:
    hp -= amount
    health_changed.emit(hp)
    if hp <= 0:
        _trigger_game_over()

func _trigger_game_over() -> void:
    if has_node("/root/Main"):
        var main = $"/root/Main"
        main.call("_change_state", main.GameState.GAME_OVER)
```

### Step 7: Handle GAME_OVER state in `main.gd`
**Rationale:** When game over triggers, stop spawning enemies and player movement.

Modify `_change_state()` case GAME_OVER:
```gdscript
GameState.GAME_OVER:
    # Stop wave spawner if exists
    if has_node("WaveSpawner"):
        $WaveSpawner.set_physics_process(false)
    # Optionally freeze player
```

---

## Validation Plan

### Static Verification
1. Confirm all modified scripts use Godot 4 static typing
2. Verify collision layers are correct:
   - Player: layer 1, mask 0 (contact via Area2D child)
   - Player attacks: layer 3, mask 2
   - Enemies: layer 2, mask 5
3. Confirm signal connections use Godot 4 `connect()` pattern with Callable
4. Verify no external asset dependencies

### Smoke Test
```bash
godot4 --headless --path . --quit
```
Expected: Exit code 0 (clean scene load)

---

## Acceptance Criteria Mapping

| # | Criterion | Implementation Location | Verification |
|---|-----------|------------------------|--------------|
| 1 | Player melee arc and projectiles damage enemies on Area2D body_entered (layer 3 vs layer 2) | `melee_arc.gd:_on_hit_enemy()`, `projectile.gd:_on_hit_enemy()` | Static: `connect("body_entered"` present, `take_damage(1)` called |
| 2 | Enemy contact with player deals 1 damage (layer 2 vs layer 1) | `player.gd` Area2D child with mask 2, `_on_enemy_contact()` | Static: Area2D child with `collision_mask = 2`, calls `take_damage(1)` |
| 3 | Player has ~0.5s invincibility after taking damage with visual flash | `_is_invincible`, `_invincibility_timer`, `INVINCIBILITY_DURATION = 0.5` | Static: timer logic in `_physics_process()`, invincibility checked in `_on_enemy_contact()` |
| 4 | Score increments by enemy point value on kill (brown=10, black=20, war=50, boss=100) | Already implemented in `wave_spawner.gd:_on_enemy_died()` via `score_changed` signal | Static: `wave_spawner.gd` score logic unchanged; HUD already connects to `score_changed` |
| 5 | Game state transitions to GAME_OVER when player HP reaches 0 | `_trigger_game_over()` calls `main._change_state(GameState.GAME_OVER)` | Static: `_change_state` call present in `take_damage()` |
| 6 | Damage flash uses modulate tween (white flash → normal in 0.15s) | `_flash_damage()` with `DAMAGE_FLASH_DURATION = 0.15`, modulate → Color.WHITE | Static: `create_tween()`, `tween_property(self, "modulate", Color.WHITE, 0.15)` |

---

## Risks and Assumptions

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Area2D child on player may conflict with CharacterBody2D movement | Low | Medium | Area2D is sensor-only (no physics body), player movement is separate CharacterBody2D |
| Enemy `take_damage()` already handles death and queue_free — no double-emit issue | Low | Low | `take_damage()` is idempotent; score increment happens on `enemy_died` signal |
| Invincibility timer during game over transition | Low | Low | Game over freezes gameplay; invincibility irrelevant once GAME_OVER active |
| `body_entered` may fire multiple times per attack | Low | Low | Attacks `queue_free()` on hit; invincibility also prevents repeat damage |

### Assumptions
1. Player and enemies are in the same scene tree (true per `wave_spawner.gd` adding enemies as children of parent)
2. `main.gd` is accessible via `/root/Main` from player context
3. Enemy variants (CORE-006) will extend `EnemyBase` and inherit `take_damage()`
4. Score display is already wired via HUD → `score_changed` signal (no new work needed)

---

## Blockers / Required User Decisions

**None.** All acceptance criteria have clear implementation paths using existing infrastructure.
