# Planning Artifact — REMED-019

## Ticket
- **ID:** REMED-019
- **Title:** Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence
- **Wave:** 26
- **Lane:** remediation
- **Stage:** planning
- **Finding source:** EXEC-GODOT-006
- **Source:** split_scope child of REMED-018 (parallel_independent)

---

## Problem Statement

The smoke_test.ts classification logic for Godot headless validation (`godot4 --headless --path . --quit`) has a persistent regex bug that allows false-PASS smoke artifacts when Godot emits fatal script-load diagnostics.

### Root Cause Analysis

**Current state of `isGodotFatalDiagnosticOutput()` at line 581–585 of `.opencode/tools/smoke_test.ts`:**

```typescript
function isGodotFatalDiagnosticOutput(output: string): boolean {
  return /SCRIPT ERROR:.*(?:not declared in the current scope|not found in base self|could not parse global class|could not resolve class)/i.test(output)
    || /Parse Error:\s*(?:Could not parse global class|Could not resolve class)/i.test(output)
    || /Failed to load script "res:\/\//i.test(output)  // <-- BUG: regex requires literal \/\/
}
```

**The bug:** The regex `/Failed to load script "res:\/\//i` requires literal `\/\/` (escaped forward slashes), but Godot outputs `res://` (with unescaped `://`). This causes `isGodotFatalDiagnosticOutput()` to return **FALSE** for the actual fatal error:

```
ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".
```

**Classification flow with exit_code===0:**
1. `isClassNameReloadParseWarning(output, 0)` → TRUE → returns `"tooling_parse_warning"` (non-blocking) — **exits early**
2. `isGodotFatalDiagnosticOutput(output)` → **never evaluated** because of early return
3. `isSyntaxErrorOutput(output)` → never evaluated
4. Overall smoke test result: **PASS** (false positive)

**Evidence from REMED-017 smoke test artifact** (`.opencode/state/artifacts/history/remed-017/smoke-test/2026-04-17T18-28-53-144Z-smoke-test.md`):
- Exit code: 0
- stderr contains: `ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".`
- Overall Result: **FAIL** with `failure_classification: syntax_error`

The REMED-017 QA artifact (`qa/2026-04-17T18-27-54-665Z-qa.md`) confirms the smoke test was producing the correct FAIL result with `syntax_error` classification. However, the actual source code at line 584 still contains the OLD buggy regex with `\/\/`.

**Conclusion:** The REMED-017 implementation artifact described the intended fix but the actual source file was never updated, OR the fix was applied and then reverted. The fix documented in REMED-017's implementation is identical to what REMED-019 must apply.

### What REMED-019 Must Address

The fix is to change the regex at line 584 from:
```typescript
|| /Failed to load script "res:\/\//i.test(output)
```
to:
```typescript
|| /Failed to load script/i.test(output)
```

---

## Scope

### Files to Modify

| File | Change |
|------|--------|
| `.opencode/tools/smoke_test.ts` | Line 584: fix regex in `isGodotFatalDiagnosticOutput()` from `/Failed to load script "res:\/\//i` to `/Failed to load script/i` |

### No other files affected
- No product code (scripts/, scenes/)
- No project.godot
- No ticket manifest changes

---

## Implementation Steps

### Step 1: Fix the regex in `isGodotFatalDiagnosticOutput()`

**File:** `.opencode/tools/smoke_test.ts`, line 584

**Before:**
```typescript
function isGodotFatalDiagnosticOutput(output: string): boolean {
  return /SCRIPT ERROR:.*(?:not declared in the current scope|not found in base self|could not parse global class|could not resolve class)/i.test(output)
    || /Parse Error:\s*(?:Could not parse global class|Could not resolve class)/i.test(output)
    || /Failed to load script "res:\/\//i.test(output)  // BUG
}
```

**After:**
```typescript
function isGodotFatalDiagnosticOutput(output: string): boolean {
  return /SCRIPT ERROR:.*(?:not declared in the current scope|not found in base self|could not parse global class|could not resolve class)/i.test(output)
    || /Parse Error:\s*(?:Could not parse global class|Could not resolve class)/i.test(output)
    || /Failed to load script/i.test(output)  // FIXED
}
```

**Rationale:** The simplified pattern `/Failed to load script/i` matches the fatal script-load diagnostic regardless of path format. The original pattern required literal `\/\/` which never matched Godot's actual `res://` output.

### Step 2: Verify classification logic ordering is correct

The `classifyCommandFailure()` function for `exitCode === 0` currently evaluates:
1. `isClassNameReloadParseWarning()` → returns `"tooling_parse_warning"` if true (early return)
2. `isGodotFatalDiagnosticOutput()` → returns `"syntax_error"` if true

When both patterns match (class_name RELOAD errors AND fatal script-load error both present in stderr), `isClassNameReloadParseWarning()` returns TRUE first and exits with `tooling_parse_warning`. This masks the fatal diagnostic.

However, the REMED-017 smoke test showed `failure_classification: syntax_error`, suggesting that `isClassNameReloadParseWarning()` was returning FALSE in that specific run (perhaps because not all three conditions were met), allowing `isGodotFatalDiagnosticOutput()` to fire.

The regex fix ensures that when `isClassNameReloadParseWarning()` does NOT match (e.g., if the stderr pattern changes), the fatal diagnostic is still caught by `isGodotFatalDiagnosticOutput()`.

**Note:** If after the regex fix the smoke test still PASSES with `tooling_parse_warning`, additional classification ordering changes would be needed (prioritize `isGodotFatalDiagnosticOutput()` before `isClassNameReloadParseWarning()`). However, based on the REMED-017 evidence, the regex fix alone should be sufficient.

---

## Validation Plan

### Static Verification (before running smoke test)

1. **Read `.opencode/tools/smoke_test.ts` lines 581–585** and confirm the regex is:
   - **BEFORE (buggy):** `/Failed to load script "res:\/\//i.test(output)`
   - **AFTER (fixed):** `/Failed to load script/i.test(output)`

### Dynamic Verification (run smoke test)

2. **Run smoke test for REMED-019:**
   ```
   smoke_test(ticket_id="REMED-019")
   ```

3. **Expected result:**
   - Command: `godot4 --headless --path . --quit`
   - Exit code: 0
   - stderr contains both class_name RELOAD errors AND fatal script-load error
   - `isGodotFatalDiagnosticOutput()` → TRUE (regex fix matches)
   - `classifyCommandFailure()` → `"syntax_error"` (blocking)
   - `commandBlocksPass()` → TRUE
   - Overall smoke test result: **FAIL** with `failure_classification: syntax_error`

4. **Verify the FAIL is the correct/intended behavior:**
   - Acceptance criterion #2 says "Make smoke_test fail when Godot export/load output contains parse or script-load errors"
   - A FAIL result means EXEC-GODOT-006 is properly detected (not falsely passing)

### Post-Fix Verification

5. **Verify regex is applied:**
   - Read `.opencode/tools/smoke_test.ts` line 584 after modification
   - Confirm pattern is `/Failed to load script/i`

---

## Acceptance Criteria Mapping

| # | Criterion | Evidence |
|---|-----------|----------|
| 1 | EXEC-GODOT-006 no longer reproduces | `godot4 --headless --path . --quit` produces fatal script-load diagnostic; `isGodotFatalDiagnosticOutput()` with fixed regex `/Failed to load script/i` correctly matches; `classifyCommandFailure()` returns `"syntax_error"` (blocking) |
| 2 | smoke_test fails on fatal script-load errors with correct classification | `failure_classification: syntax_error` (blocking); `commandBlocksPass()` returns TRUE; overall smoke test result is FAIL |
| 3 | Fix captured on current writable surfaces, not in immutable history | Fix applied to `.opencode/tools/smoke_test.ts` line 584; no history artifacts mutated |

---

## Risks and Assumptions

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Regex fix doesn't address ordering issue (class_name RELOAD check fires first, masks fatal diagnostic) | Medium | High | If smoke test still PASSES after regex fix, additional classification ordering fix required (reorder `isGodotFatalDiagnosticOutput()` before `isClassNameReloadParseWarning()` in exit_code===0 branch) |
| Subsequent Godot/environment changes alter error message format | Low | Medium | The `/Failed to load script/i` pattern is broad enough to catch variations |
| Stale lease on superseded ticket blocks claim | Low (was experienced) | Medium | Used `lease_cleanup` to clear stale lease on REMED-017 |

---

## Non-Blocking Open Questions

1. **Why did REMED-017's smoke test show FAIL if the source code still has the old regex?** The most likely explanation is that the fix was temporarily applied and then reverted, OR there's a timing issue with the checkpoint system. The important thing is that the CURRENT source has the bug and REMED-019 must fix it.

2. **Should `isClassNameReloadParseWarning()` be reordered before `isGodotFatalDiagnosticOutput()` in the exit_code===0 branch?** Currently `isClassNameReloadParseWarning()` fires first and returns `tooling_parse_warning` (non-blocking), which masks the fatal diagnostic. If after fixing the regex the smoke test still PASSES, we need to reorder so `isGodotFatalDiagnosticOutput()` fires first. However, per REMED-014/REMED-015, class_name RELOAD errors should be `tooling_parse_warning`, so we don't want to completely block on them. A proper fix would prioritize fatal diagnostics over class_name RELOAD warnings.

---

## Decision Blockers

None at planning stage. The fix is well-understood and low-risk.

---

## Next Action

After this plan is approved:
1. Move to `plan_review` stage via `ticket_update`
2. Apply the regex fix to `.opencode/tools/smoke_test.ts` line 584
3. Run `smoke_test` and verify it produces FAIL with `syntax_error` classification
4. Proceed through: plan_review → implementation → review → QA → smoke_test → closeout
