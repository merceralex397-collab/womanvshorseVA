# Backlog Verification — REMED-015

## Ticket
- **ID:** REMED-015
- **Title:** smoke_test tool classifies Godot class_name reload parse errors as syntax_error despite exit 0
- **Wave:** 22
- **Lane:** remediation
- **Stage:** closeout
- **Status:** done
- **Finding:** EXEC-GODOT-CLASSNAME
- **Resolution state:** done
- **Verification state:** trusted (PENDING REVOCATION)

---

## Background

REMED-015 was completed 2026-04-17T03:17 with smoke test PASS, based on the `isClassNameReloadParseWarning` helper firing before `isGodotFatalDiagnosticOutput` in `classifyCommandFailure`. Process version 7 repair (2026-04-17T22:49:13) modified `smoke_test.ts`. This backlog verification checks whether the REMED-015 smoke test still passes with current code.

---

## Verification Steps

### Step 1 — Read current smoke_test.ts classification logic

**File:** `.opencode/tools/smoke_test.ts`

**Lines 606–609 (classifyCommandFailure exitCode===0 branch):**
```typescript
if (args.exitCode === 0) {
    if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
    if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
    return undefined
}
```

**Lines 587–593 (isClassNameReloadParseWarning):**
```typescript
function isClassNameReloadParseWarning(output: string, exitCode: number): boolean {
  if (exitCode !== 0) return false
  if (isGodotFatalDiagnosticOutput(output)) return false   // ← REMED-019 early-exit
  return /Could not parse global class/i.test(output)
    && /Could not resolve class/i.test(output)
    && /GDScript::reload/i.test(output)
}
```

**Lines 581–585 (isGodotFatalDiagnosticOutput):**
```typescript
function isGodotFatalDiagnosticOutput(output: string): boolean {
  return /SCRIPT ERROR:.*(?:not declared in the current scope|not found in base self|could not parse global class|could not resolve class)/i.test(output)
    || /Parse Error:\s*(?:Could not parse global class|Could not resolve class)/i.test(output)
    || /Failed to load script/i.test(output)   // ← matches the stderr
}
```

**Line 574 (isSyntaxErrorOutput):**
```typescript
return /syntax error|parse error|failed to load script|.../i.test(output)  // ← also matches
```

---

### Step 2 — Run godot4 --headless --path . --quit

**Command:** `godot4 --headless --path . --quit 2>&1; echo EXIT_CODE: $?`

**Raw stderr:**
```
Godot Engine v4.6.1.stable.official.14d19694e - https://godotengine.org

SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase" from "res://scripts/enemy_base.gd".
          at: GDScript::reload (res://scripts/wave_spawner.gd:77)
SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase" from "res://scripts/wave_spawner.gd:95)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBrown", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:79)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBlack", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:80)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyWar", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:81)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBoss", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:82)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBrown", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:83)
ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".
   at: load (modules/gdscript/gdscript.cpp:2907)

EXIT_CODE: 0
```

---

### Step 3 — Live smoke_test run

**Command:** `smoke_test(ticket_id=REMED-015, command_override=["godot4 --headless --path . --quit 2>&1; echo EXIT_CODE: $?"])`

**Result:**
- Overall: **FAIL**
- exit_code: 0
- failure_classification: **syntax_error** (should be tooling_parse_warning)
- blocked_by_permissions: false

---

## Classification Analysis

For `godot4 --headless --path . --quit` with the above stderr:

| Classifier | Pattern matched? | Result | Reached? |
|---|---|---|---|
| `isGodotFatalDiagnosticOutput(output)` | YES — `/Failed to load script/i` matches line 50 of stderr | returns true | ✓ fires first |
| `isSyntaxErrorOutput(output)` | YES — `/failed to load script/i` matches line 50 of stderr | returns true | ✓ |
| `isClassNameReloadParseWarning(output, 0)` | (would match class_name RELOAD pattern) | — | ✗ never reached |

**Classification chain:**
1. `classifyCommandFailure` enters `exitCode === 0` branch (line 606)
2. Line 607: `isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)` → **true** → returns `"syntax_error"`
3. Line 608: `isClassNameReloadParseWarning(...)` → **never reached**
4. Overall smoke test: **FAIL**

---

## Acceptance Criteria Evaluation

| # | Criterion | Expected | Actual | Result |
|---|---|---|---|---|
| 1 | EXEC-GODOT-CLASSNAME no longer blocks Godot finish-proof smoke tests when exit code is 0 | classification = tooling_parse_warning, overall PASS | classification = syntax_error, overall FAIL | **FAIL** |
| 2 | Classification rule: exit_code==0 + class_name RELOAD pattern → tooling_parse_warning | isClassNameReloadParseWarning fires and returns tooling_parse_warning | isClassNameReloadParseWarning is never reached | **FAIL** |
| 3 | FINISH-VALIDATE-001 smoke_test passes after fix applied | smoke test PASS | smoke test FAIL | **FAIL** |

---

## Root Cause

Process version 7 repair did not fix the `classifyCommandFailure` ordering. The REMED-019 modification to `isClassNameReloadParseWarning` (adding `if (isGodotFatalDiagnosticOutput(output)) return false`) is inert because `isClassNameReloadParseWarning` is called at line 608 — **after** `isGodotFatalDiagnosticOutput(output)` already returned `syntax_error` at line 607.

The fix requires:
- Move `isClassNameReloadParseWarning` check **before** the `isGodotFatalDiagnosticOutput || isSyntaxErrorOutput` check in the `exitCode === 0` branch, OR
- Change line 607 to `if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"` and restructure subsequent checks to not already return syntax_error when fatal diagnostics are present.

This is the same classification ordering bug that REMED-015 was supposed to solve and that REMED-019 partially addressed in `isClassNameReloadParseWarning` without ever reaching that function.

---

## Verification Verdict

**Result: BLOCKED**

**Reason: acceptance_refresh_required = true**

The canonical acceptance for REMED-015 requires `tooling_parse_warning` classification for class_name RELOAD errors with exit_code==0. Current code produces `syntax_error` — the exact defect REMED-015 was meant to fix. The canonical acceptance contract is stale given current `smoke_test.ts` behavior.

**Proposed replacement acceptance text:**
> The validated finding EXEC-GODOT-CLASSNAME no longer blocks Godot finish-proof smoke tests when exit code is 0. Classification rule in smoke_test.ts must have `isClassNameReloadParseWarning` evaluated **before** `isGodotFatalDiagnosticOutput` in the `exitCode === 0` branch, so class_name RELOAD errors with exit_code=0 produce `tooling_parse_warning` (not `syntax_error`). FINISH-VALIDATE-001 smoke_test passes after this ordering fix.

**Source artifact:** `.opencode/state/artifacts/history/remed-015/smoke-test/2026-04-17T22-58-12-942Z-smoke-test.md` (FAIL, exit_code=0, classification=syntax_error)

**No reverification recommended until classification ordering is corrected.**

---

## Finding Severity

- **Severity:** canonical acceptance drift (classification ordering regression)
- **Classification:** workflow_integrity_violation — smoke test that should pass is currently failing due to wrong code state
- **Trust impact:** REMED-015 verification_state should remain `trusted` but cannot be treated as fully verified until ordering fix is applied and smoke test passes

---

## Recommendation to Team Leader

1. Do NOT call `ticket_reverify` yet — the canonical acceptance needs refresh first
2. Fix the `classifyCommandFailure` `exitCode === 0` branch ordering so `isClassNameReloadParseWarning` fires before `isGodotFatalDiagnosticOutput || isSyntaxErrorOutput`
3. After fix: rerun smoke_test for REMED-015, then call `ticket_reverify` with updated evidence