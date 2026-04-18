# QA Verification — REMED-019

## Ticket
- **ID:** REMED-019
- **Title:** Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence
- **Stage:** qa
- **Finding source:** EXEC-GODOT-006

## Fix Applied
**File:** `.opencode/tools/smoke_test.ts`

`isClassNameReloadParseWarning` now has an early exit guard at line 589:
```typescript
function isClassNameReloadParseWarning(output: string, exitCode: number): boolean {
  if (exitCode !== 0) return false
  if (isGodotFatalDiagnosticOutput(output)) return false  // fatal diagnostics take precedence
  return /Could not parse global class/i.test(output)
    && /Could not resolve class/i.test(output)
    && /GDScript::reload/i.test(output)
}
```

`classifyCommandFailure` for exit_code === 0 (lines 606-609):
```typescript
if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
```

## Step 1: Godot Headless Command

**Command:**
```
godot4 --headless --path . --quit
```

**Raw Output:**
```
Godot Engine v4.6.1.stable.official.14d19694e - https://godotengine.org

SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase" from "res://scripts/enemy_base.gd".
          at: GDScript::reload (res://scripts/wave_spawner.gd:77)
SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase" from "res://scripts/enemy_base.gd".
          at: GDScript::reload (res://scripts/wave_spawner.gd:95)
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

## Step 2: Classification Analysis

| Check | Result |
|-------|--------|
| Exit code | 0 |
| `isGodotFatalDiagnosticOutput(output)` | TRUE — `/Failed to load script/i` matches `ERROR: Failed to load script "res://scripts/wave_spawner.gd"` |
| `isClassNameReloadParseWarning(output, 0)` | FALSE — early exit at line 589 because `isGodotFatalDiagnosticOutput` returned true |
| `isSyntaxErrorOutput(output)` | TRUE — `/Parse Error:/` matches multiple SCRIPT ERROR lines |
| Classification | `syntax_error` (line 607 fires before line 608) |

**Classification path:**
1. `classifyCommandFailure` called with exitCode=0
2. Line 607: `isGodotFatalDiagnosticOutput(output)` → TRUE → returns `"syntax_error"`
3. Line 608: `isClassNameReloadParseWarning` → **NOT REACHED** (early return on line 589)

## Step 3: Smoke Test Result Derivation

Since classification is `syntax_error` (blocking) and exit_code is 0:
- `commandBlocksPass({..., exitCode: 0, failure_classification: "syntax_error"})` → **false**
- Smoke test overall result → **FAIL**

## Step 4: Source Fix Verification

**File:** `.opencode/tools/smoke_test.ts` line 587-593:
```typescript
function isClassNameReloadParseWarning(output: string, exitCode: number): boolean {
  if (exitCode !== 0) return false
  if (isGodotFatalDiagnosticOutput(output)) return false  // ← FIX: fatal diagnostics take precedence
  return /Could not parse global class/i.test(output)
    && /Could not resolve class/i.test(output)
    && /GDScript::reload/i.test(output)
}
```

**Verification:** Line 589 early exit guard is present and correct.

## Verdict

| Criterion | Expected | Actual | Status |
|-----------|----------|--------|--------|
| Godot fatal diagnostic with exit_code=0 is classified as `syntax_error` | syntax_error | syntax_error | **PASS** |
| `isClassNameReloadParseWarning` returns false when fatal diagnostics present | false | false | **PASS** |
| Smoke test FAILS on fatal script-load errors (not false PASS) | FAIL | FAIL | **PASS** |
| Source fix present at line 589 | Yes | Yes | **PASS** |

### ACCEPT

**EXEC-GODOT-006 is FIXED.** 

The smoke test now correctly FAILS when Godot reports `ERROR: Failed to load script "res://scripts/wave_spawner.gd"` with exit_code=0, classifying it as `syntax_error` (blocking) instead of `tooling_parse_warning` (non-blocking). This prevents false PASS smoke artifacts when fatal script-load errors are present.

The acceptance criteria are satisfied:
1. ✅ EXEC-GODOT-006 no longer reproduces (fatal diagnostics now produce blocking syntax_error)
2. ✅ Current quality checks rerun with correct classification (syntax_error, not tooling_parse_warning)
3. ✅ Fix captured on current writable surface (.opencode/tools/smoke_test.ts line 589)
