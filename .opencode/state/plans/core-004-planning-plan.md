# Planning Artifact — CORE-004

## Ticket
- **ID:** CORE-004
- **Title:** Create HUD with health hearts, wave counter, and score
- **Wave:** 1
- **Lane:** ui-hud
- **Stage:** planning
- **Status:** todo

## Overview
Create a CanvasLayer-based HUD for the game showing three key UI elements: health hearts (top-left), wave counter (top-center), and score (top-right). All visuals are procedural — hearts via `_draw()`, text via Label nodes. HUD connects to game signals for real-time updates.

## Files to Create
1. `scripts/hud.gd` — CanvasLayer with `_draw()` hearts + Label nodes for wave/score

## Files to Modify
1. `scenes/main.tscn` — Add HUD as child of root
2. `scripts/main.gd` — Connect game signals to HUD

## Implementation Steps

### Step 1: Create scripts/hud.gd
- Extend `CanvasLayer`
- Add `@export var max_hearts: int = 3`
- Add `@export var heart_size: float = 24.0`
- Add `@export var heart_spacing: float = 8.0`
- Add internal state: `_current_hp: int`, `_current_wave: int`, `_current_score: int`
- Implement `_draw()` to draw hearts:
  - Filled red (`Color(1, 0, 0)`) for current HP
  - Grey (`Color(0.3, 0.3, 0.3)`) for lost HP
  - Hearts arranged left-to-right starting at `(20, 20)`
- Add `update_health(hp: int)` method — redraws on HP change
- Add `update_wave(wave: int)` method — updates wave Label
- Add `update_score(score: int)` method — updates score Label
- Wave Label: `Label.new()` at top-center, `horiz_alignment = CENTER`, text "Wave X"
- Score Label: `Label.new()` at top-right, `horiz_alignment = RIGHT`, text "Score X"

### Step 2: Add HUD to main scene
- Add `HUD` child node (type `CanvasLayer` or reference to hud.gd) in `scenes/main.tscn`
- Set `scripts/hud.gd` on the HUD node

### Step 3: Wire signals in scripts/main.gd
- Connect to player `health_changed` signal → `hud.update_health()`
- Connect to wave spawner `wave_started` signal → `hud.update_wave()`
- Add `score_changed` signal to main.gd and emit on enemy kill → `hud.update_score()`
- Note: Player, wave_spawner, and HUD nodes must all be accessible from main.gd

## Signal Wiring (assumed node paths)
- `player.health_changed` → `hud.update_health(hp)`
- `wave_spawner.wave_started(wave_number)` → `hud.update_wave(wave_number)`
- `main.score_changed(score)` → `hud.update_score(score)`

## Validation Plan

### Static Verification
1. Read `scripts/hud.gd` — confirm `extends CanvasLayer`, `@export max_hearts`, `_draw()` heart rendering, three update methods
2. Read `scenes/main.tscn` — confirm HUD node exists as child of root
3. Read `scripts/main.gd` — confirm signal connections exist
4. Confirm no imported assets — all procedural

### Smoke Test
1. `godot4 --headless --path . --quit` → exit code 0
2. Verify no script errors in output

## Risks
- Signal wiring assumes player and wave_spawner nodes are accessible from main.gd — may need path adjustments
- Wave/score Labels use Godot default font — acceptable per canonical spec ("no imported assets")
- `_draw()` heart positions fixed at top-left — may need to read viewport size for proper anchoring

## Acceptance Mapping
| # | Criterion | Covered By |
|---|-----------|-----------|
| 1 | scripts/hud.gd extends CanvasLayer with health, wave, score | Step 1 |
| 2 | Health hearts drawn procedurally (top-left), red filled / grey lost | Step 1 `_draw()` |
| 3 | Wave counter Label (top-center) updates on wave_started signal | Step 1 `update_wave()`, Step 3 |
| 4 | Score Label (top-right) updates on score_changed signal | Step 1 `update_score()`, Step 3 |
| 5 | All text uses Godot default font | Step 1 (no custom fonts) |
| 6 | HUD added to main scene and connects to game signals | Steps 2 & 3 |

## Notes
- Procedural hearts: draw circles using `_draw()` polygon approximation (or `draw_circle` if available in Godot 4)
- Heart shape: simple filled circle, 24px diameter
- Colors: `Color(1, 0, 0)` for filled, `Color(0.3, 0.3, 0.3)` for lost
- Labels: standard Godot `Label` node with `horiz_alignment` and `vert_alignment` set for proper positioning
