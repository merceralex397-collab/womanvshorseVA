# Planning Artifact — REMED-017

## Ticket
- **ID:** REMED-017
- **Title:** Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence
- **Wave:** 24, Lane: remediation
- **Stage:** planning
- **Finding source:** EXEC-GODOT-006

---

## 1. Problem Statement

Historical smoke-test artifact (read-only evidence): `.opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-17T02-39-10-710Z-smoke-test.md`

That artifact reports **Overall Result: PASS** for FINISH-VALIDATE-001, but its command block for `godot4 --headless --path . --quit` shows:
- `exit_code: 0`
- `failure_classification: tooling_parse_warning`
- stderr contains both:
  - `SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase"...` (class_name RELOAD parse errors)
  - `ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".` (fatal script-load failure)

The overall smoke test PASSED because `commandBlocksPass()` does not treat `tooling_parse_warning` as a blocking classification. However, the "Failed to load script" line is a **fatal diagnostic** — Godot's runtime failed to load a required script. That should cause the smoke test to FAIL, not pass.

The same pattern of false PASS smoke artifacts (exit_code===0, tooling_parse_warning, fatal stderr present) has been implicitly accepted across REMED-012, REMED-014, and REMED-015, which addressed the tooling_parse_warning classification for class_name RELOAD errors but did not add a precedence rule that prevents fatal diagnostics from being masked by tooling_parse_warning.

---

## 2. Scope of the Fix

**Target file:** `.opencode/tools/smoke_test.ts`

**Target function:** `classifyCommandFailure()`

**Classification logic area:** The `exit_code === 0` branch of `classifyCommandFailure()`

**What changes:** Add an ordering rule so that `isGodotFatalDiagnosticOutput()` is evaluated **before** `isClassNameReloadParseWarning()`. When both are true (exit_code===0, class_name RELOAD parse errors present, AND fatal "Failed to load script" diagnostic present), the fatal diagnostic takes precedence and returns `syntax_error` (blocking) instead of `tooling_parse_warning` (non-blocking).

**What does NOT change:**
- `isGodotFatalDiagnosticOutput()` signature or pattern matching
- `isClassNameReloadParseWarning()` signature or pattern matching
- `isSyntaxErrorOutput()` or other classification helpers
- The `tooling_parse_warning` classification for class_name RELOAD errors without fatal diagnostics (REMED-014/REMED-015 behavior preserved)
- `commandBlocksPass()` logic (non-blocking classifications remain non-blocking)

---

## 3. Files Affected

| File | Change |
| --- | --- |
| `.opencode/tools/smoke_test.ts` | Reorder `isGodotFatalDiagnosticOutput()` before `isClassNameReloadParseWarning()` in the `exit_code === 0` branch of `classifyCommandFailure()` |

No product code files (`scripts/`, `scenes/`) are affected. No new files are created.

---

## 4. Implementation Approach

In `classifyCommandFailure()`, the `exit_code === 0` branch currently checks `isClassNameReloadParseWarning()` before `isGodotFatalDiagnosticOutput()`:

```typescript
if (args.exitCode === 0) {
  if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
  if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
  return undefined
}
```

When both functions match (class_name RELOAD errors AND "Failed to load script" fatal diagnostic), the early return for `tooling_parse_warning` masks the fatal diagnostic.

**Fix:** Move `isGodotFatalDiagnosticOutput()` before `isClassNameReloadParseWarning()`:

```typescript
if (args.exitCode === 0) {
  if (isGodotFatalDiagnosticOutput(output)) return "syntax_error"
  if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
  if (isSyntaxErrorOutput(output)) return "syntax_error"
  return undefined
}
```

**Behavior after fix:**
- `exit_code===0` + "Failed to load script" in stderr → `syntax_error` (blocking) → smoke test **FAILS**
- `exit_code===0` + class_name RELOAD parse errors **without** fatal diagnostics → `tooling_parse_warning` (non-blocking) → smoke test **PASSES** (REMED-014/REMED-015 preserved)
- `exit_code===0` + no parse/script-load errors → `undefined` → smoke test **PASSES**
- `exit_code!==0` + parse/script-load errors → `syntax_error` (unchanged)
- `exit_code!==0` + config errors → `configuration_error` (unchanged)

---

## 5. Verification Plan

### Static verification
- Read `smoke_test.ts` and confirm the reordering in `classifyCommandFailure()`
- Confirm `isGodotFatalDiagnosticOutput()` is evaluated before `isClassNameReloadParseWarning()` in the `exit_code === 0` branch
- Confirm no other changes were made to classification helpers or `commandBlocksPass()`

### Dynamic verification
Run the smoke_test tool against REMED-017 (or a test ticket with similar Godot finish-proof characteristics) and confirm:
1. `godot4 --headless --path . --quit` with class_name RELOAD parse errors AND "Failed to load script" stderr → `failure_classification: syntax_error` (not `tooling_parse_warning`)
2. `commandBlocksPass()` returns `true` for that command block
3. Overall smoke test result is **FAIL**
4. Artifact records `failure_classification: syntax_error` and `Overall Result: FAIL`

### Regression check
Run the smoke_test tool against REMED-014 or REMED-015's evidence path and confirm:
- Class_name RELOAD parse errors without fatal diagnostics still produce `tooling_parse_warning`
- Overall smoke test still **PASSES** for those tickets

---

## 6. Acceptance Criteria Mapping

| # | Criterion | Evidence |
| --- | --- | --- |
| 1 | `EXEC-GODOT-006` no longer reproduces | Smoke test FAILs when "Failed to load script" fatal diagnostic appears in Godot headless stderr (exit_code===0), classified as `syntax_error` not `tooling_parse_warning` |
| 2 | Quality checks rerun with fix approach evidence | `classifyCommandFailure()` reorders `isGodotFatalDiagnosticOutput()` before `isClassNameReloadParseWarning()`; Godot headless exit_code=0 with fatal diagnostics → `syntax_error`; class_name RELOAD without fatal diagnostics → `tooling_parse_warning`; smoke test FAIL artifact records both classification and overall result |
| 3 | History paths treated as read-only | No edits to `.opencode/state/artifacts/history/finish-validate-001/smoke-test/2026-04-17T02-39-10-710Z-smoke-test.md`; fix is captured on current writable surfaces (`.opencode/tools/smoke_test.ts`) and current ticket artifacts |

---

## 7. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Reordering breaks REMED-014/REMED-015 regression expectation | Low | High | The fix only changes behavior when BOTH `isGodotFatalDiagnosticOutput()` AND `isClassNameReloadParseWarning()` are true. Class_name RELOAD without fatal diagnostics still returns `tooling_parse_warning`. REMED-015 smoke artifact path (class_name RELOAD with exit_code=0, no "Failed to load script") is unaffected. |
| `isGodotFatalDiagnosticOutput` pattern does not match the "Failed to load script" line in the historical evidence | Low | Medium | Pattern `/Failed to load script "res:\/\//i` checks for `res:` + literal `/`. The evidence line has `res://scripts/wave_spawner.gd`. If the pattern mismatches, the fatal diagnostic is not matched and class_name RELOAD fires first — which matches REMED-015's observed behavior. In that case the ordering fix is non-ops for this specific evidence, but still improves the general case. |
| `isGodotFatalDiagnosticOutput` pattern matches more cases than intended (over-blocking) | Low | Medium | `isGodotFatalDiagnosticOutput` only fires in the `exit_code===0` branch. Non-zero exit codes use different classification paths. Over-blocking only occurs if Godot headless exits 0 with fatal diagnostics that should be treated as tooling artifacts — unlikely in normal operation. |

---

## 8. Non-Blocking Notes

- The fix is a single reordering operation in `classifyCommandFailure()` — no new helpers, no type changes, no file creations.
- Bootstrap is not required for this ticket (smoke_test tool modification only, no product code or runtime dependency changes).
- This ticket is a `split_scope` child of REMED-016 (`parallel_independent`). The parent remains open and non-foreground until this child work lands, per workflow rules.