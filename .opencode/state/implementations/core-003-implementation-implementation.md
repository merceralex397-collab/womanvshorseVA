# Implementation: CORE-003 — Wave Spawner with Escalating Difficulty

## Summary
Created `scripts/wave_spawner.gd` implementing a WaveSpawner node that manages wave progression with escalating difficulty per the canonical spec.

## Files Created

### `scripts/wave_spawner.gd`
- **class_name**: WaveSpawner
- **extends**: Node
- **Signals**: `wave_started(wave_number: int)`, `enemies_alive_changed(count: int)`

## Wave Composition (Correct per Canonical Spec)

| Wave | Composition |
|------|-------------|
| 1 | 3 brown |
| 2 | 5 brown |
| 3 | 3 brown + 2 black |
| 4+ | 3 brown + 2 black + scaling extra browns (capped at +5) |
| 5, 10, 15... | Regular composition + boss + 2 brown escorts |

## Key Implementation Details

### Signal Wiring
- `wave_started(wave_number: int)` — emitted when a new wave begins (for HUD updates)
- `enemies_alive_changed(count: int)` — emitted when enemy count changes (for HUD)

### Enemy Spawning
- Enemies spawn from random positions along arena edges (via `_get_spawn_position()`)
- Each enemy is added to parent node and connected to `enemy_died` signal
- `enemies_alive` counter tracks active enemies

### Wave Progression
- `start_next_wave()` is called on `_ready()` and when `enemies_alive` reaches 0
- Wave composition determined by `_get_wave_composition(wave: int)`
- Boss waves (every 5) add boss + 2 brown escorts on top of regular composition

### Enemy Creation
- Uses `EnemyBase.new()` and configures via exported vars:
  - **brown**: `body_color = Color(0.6, 0.4, 0.2)`, default speed (80), default size (25x35), HP=1
  - **black**: `body_color = Color(0.2, 0.2, 0.2)`, speed=150, default size, HP=1
  - **boss**: `body_color = Color(1.0, 0.84, 0.0)`, size=50x65, speed=100, HP=10

### Fixes Applied (vs provided draft)
1. **Spawn position now used**: `_spawn_wave_enemies()` now calls `_get_spawn_position()` and sets `enemy.global_position` before adding to scene
2. **Signal handler signature corrected**: `_on_enemy_died(_enemy: EnemyBase)` now properly accepts the enemy parameter from EnemyBase's `enemy_died(enemy: EnemyBase)` signal
3. **Wave 4+ scaling**: Added extra brown scaling for waves 4+ (mini(wave - 4, 5) extra browns)
4. **Boss speed**: Added explicit `speed=100.0` for boss variant

## Acceptance Criteria Verification

| Criterion | Status |
|-----------|--------|
| `scripts/wave_spawner.gd` extends Node with wave_number, enemies_alive tracking | ✅ |
| Enemies spawn from random positions on arena edges | ✅ (via `_get_spawn_position()`) |
| Wave composition follows canonical spec | ✅ |
| Next wave starts when enemies_alive reaches 0 | ✅ (in `_on_enemy_died`) |
| Emits `wave_started(wave_number)` signal | ✅ |
| Difficulty scales: enemy count increases | ✅ |

## Integration Note
The WaveSpawner should be added as a child of the main scene (or Arena node) in `main.gd` when `GameState.PLAYING` is entered. The `wave_started` and `enemies_alive_changed` signals should be connected to the HUD for display updates (to be implemented in CORE-004).
