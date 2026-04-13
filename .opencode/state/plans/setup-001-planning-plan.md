# Plan: SETUP-001 — Create main scene with arena

## 1. Scope

Create the root main scene (`scenes/main.tscn`) with a Node2D root, arena border drawn procedurally as a white rectangle outline using `_draw()`, dark background, and game state machine script with Title/Playing/GameOver states. Set the scene as the main scene in `project.godot`.

## 2. Files and Systems Affected

| File | Action |
|------|--------|
| `scenes/main.tscn` | Create — Node2D root with Arena child node |
| `scripts/main.gd` | Create — game state machine, arena border drawing |
| `project.godot` | Modify — set scenes/main.tscn as main scene |

## 3. Implementation Steps

### Step 1: Create directory structure
- Ensure `scenes/` and `scripts/` directories exist

### Step 2: Create `scripts/main.gd`
- Extend `Node2D`
- Define `GameState` enum: `TITLE`, `PLAYING`, `GAME_OVER`
- Add `@export var current_state: GameState = GameState.TITLE`
- Implement `_change_state(new_state: GameState)` method that:
  - Sets `current_state = new_state`
  - Triggers any state-entry logic (future hook)
- Implement `_draw()` to render:
  - Dark background fill: `Color(0.05, 0.05, 0.1)` covering full viewport
  - Arena border: white rectangle outline, inset 40-50px from viewport edges, 3px thick
- Implement `_ready()` to call `update()` for initial draw

### Step 3: Create `scenes/main.tscn`
- Create a `.tscn` file with a `Node2D` as root node named "Main"
- Add a child `Node2D` named "Arena" (placeholder for future arena logic)
- Attach `scripts/main.gd` to the root Main node
- Set the scene to use the script

### Step 4: Update `project.godot`
- Find `[application]` section
- Set `run/main_scene="res://scenes/main.tscn"`
- Verify no placeholder values remain

### Step 5: Validate
- Run `godot4 --headless --path . --quit` to verify clean exit
- If Godot unavailable, fall back to syntax validation via `godot4 --headless --script scripts/main.gd`

## 4. Validation Plan

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| `scenes/main.tscn` exists | filesystem check | File present |
| `scripts/main.gd` exists | filesystem check | File present |
| GameState enum present | read file | Contains `enum GameState { TITLE, PLAYING, GAME_OVER }` |
| `_change_state()` method | read file | Method implemented |
| Arena border drawn | read `_draw()` code | White rect outline, inset ~40-50px |
| project.godot main scene | read config | `run/main_scene` points to `scenes/main.tscn` |
| Godot headless exit | `godot4 --headless --path . --quit` | Exit code 0, no errors |

## 5. Risks and Assumptions

| Risk | Mitigation |
|------|------------|
| Godot 4 not installed or not on PATH | Fallback to syntax check; document blocker if both fail |
| Viewport size unknown at draw time | Use `get_viewport_rect()` to get dynamic dimensions |
| Single-scene architecture may need restructuring later | Design is aligned with canonical brief's single scene requirement |

## 6. Blockers and Required Decisions

- **No blockers**: All decisions are resolved in the brief and implementation notes
- Godot 4 validation command: `godot4 --headless --path . --quit`

## 7. Dependencies

- None — this is the foundation ticket with no dependencies

## 8. Acceptance Mapping

| Criterion | Implementation |
|-----------|----------------|
| scenes/main.tscn exists with Node2D root and Arena child node | Created in Step 3 |
| scripts/main.gd implements GameState enum (TITLE, PLAYING, GAME_OVER) with _change_state() | Created in Step 2 |
| Arena border drawn procedurally as white rectangle outline inset from viewport edges | `_draw()` in Step 2 |
| project.godot references scenes/main.tscn as main scene | Modified in Step 4 |
| godot4 --headless --quit exits cleanly | Validated in Step 5 |