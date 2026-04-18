# Plan: FINISH-VALIDATE-001 — Validate Product Finish Contract

## Scope
Validate the declared Product Finish Contract is satisfied using current runnable evidence. The finish proof must demonstrate that the APK is loadable, all gameplay systems are in place, and user-observable interactions work — not just that the APK was exported.

## Files/Systems Affected
- `build/android/womanvshorseVA-debug.apk` — final APK (24MB+)
- `scripts/main.gd` — game state machine (TITLE/PLAYING/GAME_OVER)
- `scripts/player.gd` — player character with movement and attacks
- `scripts/virtual_joystick.gd` — touch joystick control
- `scripts/wave_spawner.gd` — wave progression and enemy spawning
- `scripts/hud.gd` — health hearts, wave counter, score display
- `scripts/enemy_base.gd`, `scripts/enemy_brown.gd`, `scripts/enemy_black.gd`, `scripts/enemy_war.gd`, `scripts/enemy_boss.gd` — enemy variants
- `scripts/melee_arc.gd`, `scripts/projectile.gd` — attack systems
- `scripts/audio_manager.gd` — procedural SFX
- Evidence from: VISUAL-001, AUDIO-001, RELEASE-001

## Implementation Steps

### Step 1: Verify Loadable Product
Run `godot4 --headless --path . --quit` and confirm exit code 0. This proves the project loads without parse errors and the product is runnable.

### Step 2: Map Evidence to Acceptance Signals
Document how each acceptance signal is satisfied by current evidence:

| Acceptance Signal | Evidence |
|-----------------|----------|
| APK compiles and installs | APK at `build/android/womanvshorseVA-debug.apk` (24MB+), godot4 export exit code 0 |
| All waves playable | wave_spawner.gd implements wave composition per canonical spec (brown wave 1+, black wave 3+, war wave 6+, boss every 5 waves) |
| Touch controls work | virtual_joystick.gd handles left-screen-half touch/drag for 8-directional movement; right-half tap for melee, hold+release for ranged |
| Score tracking functions | hud.gd displays score, updated via score_changed signal from wave_spawner.gd and player.gd on enemy kills |

### Step 3: Verify Finish-Direction Ticket Completion
Confirm all required tickets are done:
- VISUAL-001 (done) — ship-ready visual finish, no placeholder art
- AUDIO-001 (done) — procedural SFX complete, no external audio files
- RELEASE-001 (done) — APK export successful

### Step 4: Document User-Observable Interaction Evidence
From code inspection, enumerate the user-observable surfaces:

**Controls/Input:**
- Virtual joystick on left screen half: touch down starts input, drag updates direction, touch up clears input
- Right screen half tap: triggers melee arc attack toward nearest enemy
- Right screen half hold+release: fires ranged projectile in facing direction

**Visible Gameplay State/Feedback:**
- Player: green rectangle body + white triangle sword indicator
- Health hearts (top-left): red filled for current HP, grey for lost HP — drawn via _draw()
- Wave counter (top-center): updates on wave_started signal
- Score (top-right): updates on score_changed signal
- Arena: white rectangle outline border with optional dot grid
- Enemy visuals: brown/black/red/gold rectangles per variant, speed lines on black, pulsing on boss
- Melee arc: semi-transparent white sector visual
- Projectile: yellow circle
- Hit particles: orange-yellow burst on damage
- Death particles: larger burst on enemy kill

**Brief-Specific Progression/Content:**
- Wave 1: 3 brown horses → Wave 2: 5 brown → Wave 3: 3 brown + 2 black → Wave 5: BOSS + escorts → scaling continues
- Progressive difficulty: enemy count and type composition escalate per canonical spec
- 3 hearts HP, score increments on kill (brown=10, black=20, war=50, boss=100)
- Game over at 0 HP, restart returns to title screen

### Step 5: Validate Godot Headless Load
Run `godot4 --headless --path . --quit` and record exit code. If 0, the project loads cleanly and the product is a loadable game, not just an exported artifact.

## Validation Plan

**Static Verification:**
- [ ] APK exists at build/android/womanvshorseVA-debug.apk, non-zero size
- [ ] godot4 --headless --path . --quit exits 0
- [ ] Virtual joystick code handles InputEventScreenTouch/Drag on left screen half
- [ ] Melee arc triggers on right-half tap (InputEventScreenTouch pressed/released same index)
- [ ] Ranged attack triggers on right-half hold+release
- [ ] wave_spawner.gd implements all wave types per canonical spec
- [ ] HUD updates via correct signals (health_changed, wave_started, score_changed)
- [ ] No placeholder art or external assets in user-facing surfaces

**Smoke Test:**
- godot4 --headless --path . --quit must exit 0

## Risks and Assumptions

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Godot headless load succeeds but runtime behavior differs on Android | Low | Medium | APK export succeeded; godot4 load validates script parse and scene structure |
| Touch controls work in simulator but not on actual device | Low | High | Virtual joystick uses standard InputEventScreenTouch/Drug pattern; review code for device-specific assumptions |
| Performance issues on low-end Android devices | Low | Medium | Procedural sprites are lightweight; particles use _draw() not GPUParticles2D |

**Assumptions:**
- Godot 4.6.2 available on build machine
- Android SDK and export templates configured
- MiniMax-M2.7 model available for agent work

## Acceptance Criteria Mapping

| Criterion | How Satisfied |
|-----------|---------------|
| 1. Finish proof maps evidence to acceptance signals | This document (Step 2) provides explicit mapping table |
| 2. User-observable interaction evidence included | Step 4 documents all control inputs, visible state, and progression surfaces |
| 3. godot4 --headless --path . --quit succeeds | Step 1 and Step 5 run and verify; smoke test records exit code |
| 4. All finish-direction/visual/audio tickets completed | Step 3 confirms VISUAL-001, AUDIO-001, RELEASE-001 all done |

## Closeout Requirements
- Planning artifact registered
- godot4 headless load verified (exit code 0)
- All acceptance signals mapped to current evidence
- All dependency tickets verified done (VISUAL-001, AUDIO-001)
- Ticket transitions to plan_review for approval before implementation