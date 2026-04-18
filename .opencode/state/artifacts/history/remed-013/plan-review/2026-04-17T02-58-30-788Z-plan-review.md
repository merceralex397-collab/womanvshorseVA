# Plan Review Artifact: REMED-013

## Ticket
- **ID**: REMED-013
- **Title**: GDScript calls APIs that are unavailable on the script's declared base type
- **Wave**: 20
- **Lane**: remediation
- **Stage**: plan_review
- **Finding Source**: EXEC-GODOT-009

## Verdict: APPROVED

## Acceptance Criteria Coverage

| # | Criterion | Covered By | Status |
|---|-----------|-----------|--------|
| 1 | EXEC-GODOT-009 no longer reproduces | Step 2 Godot headless validation (exit 0, no API errors) | ✓ |
| 2 | Current quality checks rerun with evidence tied to fix approach | Steps 1–3 static analysis + Godot headless validation | ✓ |

Both acceptance criteria are covered by the plan.

---

## Static Analysis Review

**hud.gd:**
- `extends Control` — Control extends CanvasItem
- `_draw()`, `draw_circle()`, `draw_colored_polygon()`, `queue_redraw()` are all valid CanvasItem APIs
- Verdict: APIs are compatible with declared base type ✓

**wave_spawner.gd:**
- `extends Node2D` — Node2D extends Node
- `get_viewport_rect()` is a valid method on Node (inherited by Node2D)
- Verdict: API is compatible with declared base type ✓

---

## Implementation Approach Soundness

- **Step 1** (Static Analysis): Confirms base type/API compatibility — already shown to be valid
- **Step 2** (Godot Headless): Canonical `godot4 --headless --path . --quit` with exit-code-only classification per REMED-012/REMED-014
- **Step 3** (Determine Fix): Binary outcome — finding resolved or targeted fix required
- **Step 4** (Code Changes): Minimal targeted fix only if Step 2 fails

The approach is technically sound. The finding was based on diagnoses against older base types (`CanvasLayer` for hud.gd, `Node` for wave_spawner.gd); current code already uses compatible base types.

---

## Decision Blockers

None. No blocking risks identified.

---

## Risks and Mitigations

| Risk | Severity | Likelihood | Status |
|------|----------|------------|--------|
| Finding was based on stale diagnosis; code already correct | Low | Medium | Mitigated: Godot headless confirms no API errors |
| wave_spawner.gd get_viewport_rect() behavior on Node2D | Low | Low | Mitigated: Godot headless will confirm or identify specific issue |

---

## Next Stage

- `approved_plan: true` → proceed to implementation
- Implementation will run Godot headless validation and either confirm no reproduction (AC1 satisfied) or apply targeted fix

---

## Recommendations to Implementer

1. Run `godot4 --headless --path . --quit` first — if exit 0 with no API errors, the finding is already resolved and most of the verification work is done
2. Record exact command output, exit code, and PASS/FAIL classification as evidence for AC1 and AC2
3. If errors appear, focus on the specific API call and move it to a CanvasItem-derived node per the plan's Step 4
