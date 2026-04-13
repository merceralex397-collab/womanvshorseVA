# Plan Review — CORE-004

## Ticket
- **ID:** CORE-004
- **Title:** Create HUD with health hearts, wave counter, and score
- **Stage:** plan_review
- **Reviewer:** wvhva-team-leader

## Acceptance Criteria Review

| # | Criterion | Plan Coverage | Verdict |
|---|-----------|--------------|---------|
| 1 | scripts/hud.gd extends CanvasLayer with health, wave, and score display | Step 1 defines `extends CanvasLayer` with all three display elements | ✅ PASS |
| 2 | Health hearts drawn procedurally (top-left): red filled for current HP, grey for lost | Step 1 `_draw()` with `Color(1, 0, 0)` for filled, `Color(0.3, 0.3, 0.3)` for lost | ✅ PASS |
| 3 | Wave counter Label (top-center) updates on wave_started signal | Step 1 `update_wave()` method + Step 3 signal connection | ✅ PASS |
| 4 | Score Label (top-right) updates on score_changed signal | Step 1 `update_score()` method + Step 3 signal connection | ✅ PASS |
| 5 | All text uses Godot default font with theme overrides for size and color | Plan explicitly states "no custom fonts" | ✅ PASS |
| 6 | HUD is added to main scene and connects to game signals | Steps 2 & 3 cover main.tscn addition + signal wiring | ✅ PASS |

## Plan Quality Assessment

### Strengths
- All 6 acceptance criteria are explicitly mapped to implementation steps
- Uses Godot 4 static typing (`extends CanvasLayer`, `@export` vars)
- Procedural drawing approach consistent with project constraints (no imported assets)
- Signal wiring is clearly specified with assumed node paths
- Validation plan includes both static verification and smoke test

### Non-Blocking Notes
- Heart positions are fixed at top-left `(20, 20)` — acceptable for current spec scope
- Signal node paths assume `player`, `wave_spawner`, `hud` are accessible from main.gd — consistent with SETUP-001/CORE-003 architecture
- Wave/score Labels use Godot default font — per canonical spec this is acceptable ("no imported assets")

## Review Decision

**APPROVED**

The plan correctly covers all 6 acceptance criteria using Godot 4 patterns. The implementation approach (CanvasLayer + `_draw()` for hearts, Label nodes for text, signal-based updates) is sound and consistent with the project's procedural art constraints.

## GAP-001 (Non-blocking)
- Heart positions at fixed `(20, 20)` — no dynamic viewport anchoring. Acceptable for current scope.

## Recommendation
Advance CORE-004 to implementation.
