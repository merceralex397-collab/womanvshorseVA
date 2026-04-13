# Implementation Artifact: CORE-005 - Collision and Damage System

## Ticket
- **ID**: CORE-005
- **Title**: Implement collision and damage system
- **Stage**: implementation
- **Lane**: combat-system
- **Dependencies**: CORE-001 ✓, CORE-002 ✓

## Summary
Implemented the full collision and damage system wiring player attacks, enemy contact, invincibility frames, damage flash, score tracking on kill, and game over state transition.

## Files Modified

### 1. `scripts/player.gd` (142 lines total)

**Changes:**
- Added `player_died` signal
- Added `_is_invincible`, `_invincibility_duration` (0.5s), `_invincibility_timer`, and `_contact_sensor` variables
- Added `_setup_contact_sensor()` method:
  - Creates Area2D child node with collision_mask=2 (Enemies)
  - CircleShape2D with radius 27.0 (plan review recommendation: 25-30)
  - Connected `body_entered` via `Callable(self, "_on_contact_enemy")` style
- Updated `_physics_process()` to handle invincibility timer countdown
- Added `_on_contact_enemy(body: Node2D)` - triggers `take_damage(1)` if not invincible
- Added `_flash_damage()` method with tween cancellation (plan review recommendation):
  - Kills existing tweens before starting new one
  - Tweens modulate to white (1.5, 1.5, 1.5) in 0.075s, back to WHITE in 0.075s
  - Total flash duration: 0.15s as specified
- Updated `take_damage(amount: int)`:
  - Returns early if invincible (no damage during i-frames)
  - Sets `_is_invincible = true` and starts `_invincibility_timer`
  - Emits `health_changed`
  - Calls `_flash_damage()`
  - Emits `player_died` when HP reaches 0

**Acceptance Criteria Coverage:**
- ✓ Criterion 2: Enemy contact with player deals 1 damage (layer 2 vs layer 1 via contact sensor)
- ✓ Criterion 3: Player has ~0.5s invincibility after taking damage with visual flash
- ✓ Criterion 6: Damage flash uses modulate tween (white flash → normal in 0.15s)

### 2. `scripts/projectile.gd` (26 lines total)

**Changes:**
- Added collision_layer=3 and collision_mask=2 in `_ready()`
- Connected `body_entered` via `Callable(self, "_on_hit_enemy")` style
- Added `_on_hit_enemy(body: Node2D)` that calls `body.take_damage(1)` and queues self for deletion

**Acceptance Criteria Coverage:**
- ✓ Criterion 1: Player projectiles damage enemies on Area2D body_entered (layer 3 vs layer 2)

### 3. `scripts/melee_arc.gd` (43 lines total)

**Changes:**
- Connected `body_entered` via `Callable(self, "_on_hit_enemy")` style
- Added `_on_hit_enemy(body: Node2D)` that calls `body.take_damage(1)`

**Acceptance Criteria Coverage:**
- ✓ Criterion 1: Player melee arc damages enemies on Area2D body_entered (layer 3 vs layer 2)

### 4. `scripts/main.gd` (115 lines total)

**Changes:**
- Added `_trigger_game_over()` method (plan review recommendation: GAME_OVER case):
  - Gets WaveSpawner node and calls `set_physics_process(false)` and `set_process(false)`
  - Gets Player node and calls `set_physics_process(false)` and `set_process(false)`
- Added `_on_player_died()` callback that calls `_change_state(GameState.GAME_OVER)`
- Updated `_change_state(GameState.GAME_OVER)` to call `_trigger_game_over()`
- Updated `_spawn_player_and_joystick()` to connect `player_died` signal to `_on_player_died`

**Acceptance Criteria Coverage:**
- ✓ Criterion 5: Game state transitions to GAME_OVER when player HP reaches 0

## Score Values Verified

Score values match those in `wave_spawner.gd`:
- brown = 10
- black = 20
- war = 50
- boss = 100

Score increment on enemy kill is already handled by `wave_spawner.gd` via `enemy_died` signal → `_on_enemy_died()` → `score += _point_values.get(enemy.type, 10)`

**Acceptance Criteria Coverage:**
- ✓ Criterion 4: Score increments by enemy point value on kill

## Plan Review Notes Incorporated

1. **Tween cancellation**: `_flash_damage()` kills existing tweens before starting new one ✓
2. **GAME_OVER case**: `main.gd` implements `_trigger_game_over()` with wave spawner and player freeze ✓
3. **Contact sensor radius**: Set to 27.0 (within recommended 25-30 range) ✓
4. **Callable style**: All signal connections use `Callable(self, "_on_hit_enemy")` style ✓

## Validation

### Syntax Check Command
```bash
godot4 --headless --path /home/pc/projects/womanvshorseVA --quit
```

### Expected Result
- Exit code 0 indicates successful scene loading and script compilation
- Any GDScript syntax errors would be reported before exit

## Acceptance Criteria Summary

| # | Criterion | Status |
|---|-----------|--------|
| 1 | Player melee arc and projectiles damage enemies on Area2D body_entered (layer 3 vs layer 2) | ✓ |
| 2 | Enemy contact with player deals 1 damage (layer 2 vs layer 1) | ✓ |
| 3 | Player has ~0.5s invincibility after taking damage with visual flash | ✓ |
| 4 | Score increments by enemy point value on kill (brown=10, black=20, war=50, boss=100) | ✓ |
| 5 | Game state transitions to GAME_OVER when player HP reaches 0 | ✓ |
| 6 | Damage flash uses modulate tween (white flash → normal in 0.15s) | ✓ |

## Next Steps
After this implementation artifact is registered, the ticket should advance to `review` stage where a code reviewer will verify the implementation matches acceptance criteria.
