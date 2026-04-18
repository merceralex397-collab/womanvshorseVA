# Planning Artifact: REMED-013

## Ticket
- **ID**: REMED-013
- **Title**: GDScript calls APIs that are unavailable on the script's declared base type
- **Wave**: 20
- **Lane**: remediation
- **Stage**: planning
- **Finding Source**: EXEC-GODOT-009

## Scope

Validate that the GDScript in hud.gd and wave_spawner.gd uses APIs that are compatible with its declared base types. Fix any base-type/API mismatches and verify Godot headless validation (`godot4 --headless --path . --quit`) exits 0 without API-not-available errors.

### Files Affected
| File | Current Base Type | APIs Called | Expected Valid? |
|------|-------------------|-------------|----------------|
| scripts/hud.gd | `extends Control` | `_draw()`, `draw_circle()`, `draw_colored_polygon()`, `queue_redraw()` | Yes — Control extends CanvasItem which provides these |
| scripts/wave_spawner.gd | `extends Node2D` | `get_viewport_rect()` | Yes — Node2D extends Node which provides this |

### Finding Evidence (from diagnosis bundle)
The diagnosis EXEC-GODOT-009 reported:
- `scripts/hud.gd: extends CanvasLayer but calls draw_circle()` — **current code extends Control, not CanvasLayer**
- `scripts/hud.gd: extends CanvasLayer but calls queue_redraw()` — **current code extends Control, not CanvasLayer**
- `scripts/wave_spawner.gd: extends Node but calls get_viewport_rect()` — **current code extends Node2D, not Node**

### Key Observation
The current code already shows corrected base types (`Control` and `Node2D`) that are compatible with the APIs being called. The finding may have been based on an older version of the files that has since been partially remediated.

---

## Implementation Approach

### Step 1: Static Code Analysis
Verify the declared base types and API calls in both files.

**hud.gd analysis:**
- Line 1: `extends Control` — Control IS a CanvasItem-derived node
- Line 38: `func _draw() -> void:` — Valid on CanvasItem
- Lines 55-56: `draw_circle(...)` — Valid on CanvasItem
- Line 65: `draw_colored_polygon(...)` — Valid on CanvasItem
- Line 69: `queue_redraw()` — Valid on CanvasItem
- **Verdict: APIs are valid for declared base type Control**

**wave_spawner.gd analysis:**
- Line 2: `extends Node2D` — Node2D extends Node
- Line 86: `get_viewport_rect()` — Method on Node class; Node2D inherits from Node
- **Verdict: API is valid for declared base type Node2D**

### Step 2: Dynamic Validation via Godot Headless
Run the canonical acceptance command:
```
godot4 --headless --path . --quit
```
- Capture exit code
- Capture stderr for any parse errors or API-not-available messages
- Classify any errors:
  - `syntax_error` pattern → actual defect
  - `class_name RELOAD` parse warnings → tooling artifacts (per REMED-014/REMED-012)
  - `API not available on base type` → actual defect requiring fix

### Step 3: Determine Fix or Confirmation
- **If Godot headless exits 0 with no API errors**: The finding does not reproduce on current code. Document this as the fix evidence and proceed to QA with confirmation.
- **If Godot headless shows API mismatches**: Identify the specific call, move it to a compatible CanvasItem-derived node (e.g., add a child Node2D to wave_spawner that calls get_viewport_rect), then retest.

### Step 4: If Fix Required — Code Changes
For hud.gd: No change expected (Control already correct)  
For wave_spawner.gd: If get_viewport_rect() proves incompatible, move viewport-size logic into a CanvasItem child node

---

## Godot Headless Validation Plan

### Command
```
godot4 --headless --path . --quit 2>&1
```

### Success Criteria
- Exit code 0
- No stderr containing "API not available" or "function not found in base"
- stderr may contain tooling_parse_warning class_name RELOAD patterns (handled by REMED-012/REMED-014)

### Evidence Recording
Record:
1. Exact command run
2. Raw stdout and stderr
3. Exit code
4. Explicit PASS/FAIL classification

---

## Acceptance Criteria Mapping

| # | Criterion | How Verified | Expected Result |
|---|-----------|--------------|----------------|
| 1 | The validated finding EXEC-GODOT-009 no longer reproduces | Godot headless validation exits 0 without API-not-available errors in stderr | PASS if no API errors |
| 2 | Current quality checks rerun with evidence tied to the fix approach | Static analysis confirms Control/_draw() compatibility and Node2D/get_viewport_rect() compatibility; Godot headless exit 0 | PASS |

---

## Risks and Mitigations

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Finding was based on stale diagnosis and code is already correct | Low | Medium | Verify via Godot headless; if exit 0, finding is resolved |
| wave_spawner.gd get_viewport_rect() behaves differently than expected on Node2D | Low | Low | If headless shows error, move to CanvasItem child |
| Prior remediation already fixed hud.gd but not wave_spawner.gd | Low | Medium | Check both files independently |

---

## Decision Blockers

None identified at planning stage. Godot headless validation will determine if any code changes are required.

---

## Next Stage After Planning

- If Godot headless passes with no API errors → Plan Review with confirmation that finding is resolved
- If Godot headless shows errors → Plan Review with proposed code changes
