# Plan Review — REMED-017

## Ticket
- **ID:** REMED-017
- **Title:** Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence
- **Wave:** 24, Lane: remediation
- **Stage:** plan_review
- **Plan artifact:** `.opencode/state/plans/remed-017-planning-plan.md`

## Verdict: APPROVED

## Findings

### 1. Problem Statement Accuracy
The plan correctly identifies the root cause: in `classifyCommandFailure()` (`.opencode/tools/smoke_test.ts` lines 594–614), the `exit_code === 0` branch checks `isClassNameReloadParseWarning()` before `isGodotFatalDiagnosticOutput()`. When both match, the early `tooling_parse_warning` return (line 606) masks the fatal "Failed to load script" diagnostic (line 607), causing `commandBlocksPass()` to return `false` for that command block and producing a false PASS smoke artifact.

The historical evidence path `.opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-17T02-39-10-710Z-smoke-test.md` is correctly referenced as read-only context.

### 2. Fix Approach Soundness
**Proposed change:** Reorder `isGodotFatalDiagnosticOutput()` before `isClassNameReloadParseWarning()` in the `exit_code === 0` branch.

**Current code (line 605–608):**
```typescript
if (args.exitCode === 0) {
  if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
  if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
  return undefined
}
```

**Proposed code:**
```typescript
if (args.exitCode === 0) {
  if (isGodotFatalDiagnosticOutput(output)) return "syntax_error"
  if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
  if (isSyntaxErrorOutput(output)) return "syntax_error"
  return undefined
}
```

**Helper function verification:**
- `isClassNameReloadParseWarning()` (line 587–592): requires `exitCode === 0` + `Could not parse global class` + `Could not resolve class` + `GDScript::reload`. The historical stderr contains all three patterns. ✓
- `isGodotFatalDiagnosticOutput()` (line 581–585): pattern `/Failed to load script "res:\/\//i` matches the literal evidence line `Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error"`. ✓

**Classification behavior after fix:**
- `exit_code===0` + "Failed to load script" → `syntax_error` (blocking) → smoke test **FAILS** ✓
- `exit_code===0` + class_name RELOAD **without** fatal diagnostics → `tooling_parse_warning` (non-blocking) → PASS (REMED-014/REMED-015 preserved) ✓
- `exit_code===0` + no parse/script-load errors → `undefined` → PASS ✓

### 3. All 3 Acceptance Criteria Covered
| # | Criterion | Status |
|---|-----------|--------|
| 1 | EXEC-GODOT-006 no longer reproduces | Covered: fatal diagnostic + exit_code===0 → `syntax_error` → smoke test FAIL |
| 2 | Quality checks rerun with fix approach evidence | Covered: reordering verified statically, classification behavior verified in dynamic plan |
| 3 | History paths treated as read-only | Covered: fix on `.opencode/tools/smoke_test.ts` only, no edits to immutable history artifacts |

### 4. Godot 4 Tooling Patterns Correct
- No type changes, no new helpers, no file creations — single reordering operation ✓
- `isGodotFatalDiagnosticOutput()` already exists and is correctly used for fatal script-load diagnostics ✓
- REMED-014/REMED-015 classification for class_name RELOAD without fatal diagnostics is explicitly preserved ✓

### 5. Risks
| Risk | Likelihood | Impact | Mitigation | Status |
|------|------------|--------|------------|--------|
| Reordering breaks REMED-014/REMED-015 regression | Low | High | Only fires when BOTH helpers match; class_name RELOAD alone still → `tooling_parse_warning` | Acceptable |
| `isGodotFatalDiagnosticOutput` pattern mismatch | Low | Medium | Pattern `/Failed to load script "res:\/\//i` exactly matches evidence line | Acceptable |
| Over-blocking via `isGodotFatalDiagnosticOutput` | Low | Medium | Only fires in `exit_code===0` branch; non-zero exit codes use different paths | Acceptable |

### 6. Blocking Issues
None.

### 7. Non-Blocking Notes
- Bootstrap is not required (tooling-only change, no runtime dependencies) ✓
- Single-file, single-operation change minimizes risk surface ✓
- No product code (`scripts/`, `scenes/`) affected ✓
- Implementation is ready to proceed upon approval.

## Recommendations
1. During implementation, verify the reordering is the **only** change in `classifyCommandFailure()` — no edits to helper signatures or `commandBlocksPass()`
2. After implementation, run dynamic verification: `godot4 --headless --path . --quit` on a finish-validation ticket should produce `failure_classification: syntax_error` (not `tooling_parse_warning`) when fatal diagnostics are present
3. Confirm REMED-014/REMED-015 smoke artifacts (class_name RELOAD without fatal diagnostics) still PASS after the reordering change
