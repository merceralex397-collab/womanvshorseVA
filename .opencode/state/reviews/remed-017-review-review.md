# Code Review — REMED-017

## Ticket
- ID: REMED-017
- Title: Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence
- Stage: review
- Finding source: EXEC-GODOT-006

## Verdict: APPROVED

---

## Review Summary

The implementation correctly fixes EXEC-GODOT-006 by reordering two classification checks in `classifyCommandFailure()` inside the `exit_code === 0` branch. No product code was changed. All three acceptance criteria are satisfied.

---

## Change Scope

**File modified:** `.opencode/tools/smoke_test.ts` (lines 605–608)

**Change:** Reordered classification checks so `isGodotFatalDiagnosticOutput()` is evaluated before `isClassNameReloadParseWarning()`.

### Before
```typescript
if (args.exitCode === 0) {
  if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
  if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
  return undefined
}
```

### After
```typescript
if (args.exitCode === 0) {
  if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
  if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
  return undefined
}
```

---

## Verification Findings

### 1. Reordering confirmed correct ✅
- `isGodotFatalDiagnosticOutput()` is now checked FIRST (line 606)
- `isClassNameReloadParseWarning()` is checked SECOND (line 607)
- The fallback `return undefined` remains at line 608

### 2. Helper functions unchanged ✅
- `isGodotFatalDiagnosticOutput()` (lines 581–585): Unchanged. Catches `Failed to load script "res:\/\//` pattern that matches the observed godot4 fatal diagnostic output.
- `isClassNameReloadParseWarning()` (lines 587–592): Unchanged. Catches the class_name RELOAD noise pattern with all three conditions: `exitCode === 0` AND `Could not parse global class` AND `Could not resolve class` AND `GDScript::reload`.

### 3. `commandBlocksPass()` logic unchanged ✅
- Lines 624–630: `syntax_error` classification still causes `commandBlocksPass()` to return `true`, blocking the smoke test pass.
- No changes to the blocking condition.

### 4. godot4 --headless --quit exits 0 with fatal diagnostic ✅
```
$ godot4 --headless --path . --quit
...
ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".
   at: load (modules/gdscript/gdscript.cpp:2907)
EXIT_CODE=0
```

With the new ordering:
- `isGodotFatalDiagnosticOutput(output)` fires first (matches `Failed to load script "res:\/\//`)
- Returns `"syntax_error"`
- `commandBlocksPass()` returns `true`
- Smoke test FAILS as intended (correct behavior for this defect)

### 5. No other changes ✅
- No changes to helper signatures, `commandBlocksPass()`, `classifySmokeFailure()`, or any other classification logic
- No product code (scripts/, scenes/) touched
- Type definitions unchanged

---

## Acceptance Criteria Check

| # | Criterion | Status |
|---|-----------|--------|
| 1 | EXEC-GODOT-006 no longer reproduces: smoke_test now correctly fails when Godot reports fatal script-load errors alongside exit 0 | ✅ VERIFIED |
| 2 | Classification rule: `exit_code===0 AND "Failed to load script"` → `syntax_error`; class_name RELOAD-only noise → `tooling_parse_warning` | ✅ IMPLEMENTED |
| 3 | FINISH-VALIDATE-001 smoke test will now fail with `syntax_error` when Godot reports script-load failures | ✅ CONFIRMED |

---

## Recommendations

None. The implementation is minimal, targeted, and correct.

---

## Conclusion

The fix correctly prioritizes fatal diagnostic detection over class_name reload noise. When `godot4 --headless --path . --quit` produces `Failed to load script` alongside exit 0, the smoke test will now correctly fail with `syntax_error` classification instead of incorrectly passing. No regressions introduced.
