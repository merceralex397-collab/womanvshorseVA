# Canonical Brief — Woman vs Horse VA

## Project Summary

A simple 2D top-down arena action game for Android where a warrior woman fights waves of enemy horses. Built with Godot 4.6, using procedural/programmatic sprites (colored shapes) inspired by Codex game-studio patterns. Touch controls. Single scene architecture.

## Goals

- Playable wave-based combat game on Android
- Clean procedural sprite rendering (colored shapes with distinct silhouettes)
- Touch controls: virtual joystick + attack buttons
- Progressive difficulty across waves
- Score tracking and display

## Non-Goals

- No story/narrative
- No character customization
- No level editor
- No online features
- No analytics or IAP
- No save system

## Constraints

- Runtime: Android (Godot 4.6 export)
- All visual content procedurally generated via GDScript (no asset files)
- Touch-only controls (landscape orientation)
- Single scene architecture: Title → Playing → GameOver
- No external dependencies beyond Godot engine

## Tooling and Model Constraints

- Provider: `minimax-coding-plan`
- Planner/reviewer model: `minimax-coding-plan/minimax-coding-plan/MiniMax-M2.7`
- Implementer model: `minimax-coding-plan/minimax-coding-plan/MiniMax-M2.7`
- Utility/helper model: `minimax-coding-plan/minimax-coding-plan/MiniMax-M2.7`

## Required Outputs

- repo structure
- docs
- ticket pack
- OpenCode agents, tools, plugins, commands, and local skills

## Canonical Truth Map

- Facts and decisions: `docs/spec/CANONICAL-BRIEF.md`
- Queue state and artifact metadata: `tickets/manifest.json`
- Transient stage state: `.opencode/state/workflow-state.json`
- Artifact bodies: the stage-specific directories under `.opencode/state/`
- Artifact registry: `.opencode/state/artifacts/registry.json`
- Restart surface: `START-HERE.md`

## Core Game Design

### Player Character
- Green rectangle body with white triangle sword indicator
- 3 hearts HP, displayed top-left
- Movement: 8-directional virtual joystick (left screen half)
- Melee attack: Tap right half (arc toward nearest enemy)
- Ranged attack: Hold+release right half (projectile in facing direction)

### Enemies
| Type | Visual | Speed | HP | Appears |
|------|--------|-------|----|---------|
| Brown Horse | Brown rectangle | Slow | 1 | Wave 1+ |
| Black Horse | Dark rectangle | Fast | 1 | Wave 3+ |
| War Horse | Red rectangle (larger) | Slow | 3 | Wave 6+ |
| Boss | Gold rectangle (large) | Variable | 10 | Every 5 waves |

### Wave Progression
- Wave 1: 3 brown → Wave 2: 5 brown → Wave 3: 3 brown + 2 black
- Wave 5: BOSS + 2 escorts → continues scaling

### UI/HUD
- Health hearts (top-left), wave counter (top-center), score (top-right)
- Title screen: "WOMAN vs HORSE" + START button
- Game Over: score + RESTART button

## Blocking Decisions

- All resolved. Procedural art is the final art style. No external assets needed.

## Non-Blocking Open Questions

- None

## Backlog Readiness

- Ready for immediate ticket generation. Game design is fully specified.

## Acceptance Signals

- APK compiles via `godot4 --headless --export-debug "Android Debug"`
- Game launches on Android
- Touch controls (joystick + attack) respond correctly
- Waves spawn and escalate
- Score increments on enemy defeat
- Game over triggers at 0 HP
- Restart returns to title

## Assumptions

- Godot 4.6.2 available on build machine
- Android SDK and export templates configured
- MiniMax-M2.7 model available for agent work

## Product Finish Contract

- deliverable_kind: Android game APK — woman fights waves of enemy horses
- placeholder_policy: Procedural/programmatic sprites acceptable. Colored shapes with basic animations. No placeholder art in final build.
- visual_finish_target: 2D top-down view with procedural sprites. Clean, readable gameplay. Inspired by Codex game-studio patterns.
- audio_finish_target: Minimal: procedural/generated SFX. Background music optional.
- content_source_plan: Procedural generation — sprites created programmatically via GDScript. No external assets.
- licensing_or_provenance_constraints: No external assets used. All content is procedurally generated.
- finish_acceptance_signals: APK compiles and installs. All waves playable. Touch controls work. Score tracking functions.
