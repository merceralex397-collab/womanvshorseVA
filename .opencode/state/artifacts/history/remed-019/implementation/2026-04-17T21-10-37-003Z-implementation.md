# Implementation Artifact — REMED-019

## Ticket
- **ID:** REMED-019
- **Title:** Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence
- **Stage:** implementation
- **Finding source:** EXEC-GODOT-006

## Exact Change Made

**File:** `.opencode/tools/smoke_test.ts`
**Function:** `isClassNameReloadParseWarning` (lines 587–593)

**Before:**
```typescript
function isClassNameReloadParseWarning(output: string, exitCode: number): boolean {
  return exitCode === 0
    && /Could not parse global class/i.test(output)
    && /Could not resolve class/i.test(output)
    && /GDScript::reload/i.test(output)
}
```

**After:**
```typescript
function isClassNameReloadParseWarning(output: string, exitCode: number): boolean {
  if (exitCode !== 0) return false
  if (isGodotFatalDiagnosticOutput(output)) return false
  return /Could not parse global class/i.test(output)
    && /Could not resolve class/i.test(output)
    && /GDScript::reload/i.test(output)
}
```

## Evidence of Godot Stderr Motivating This Fix

```
SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase" from "res://scripts/enemy_base.gd".
          at: GDScript::reload (res://scripts/wave_spawner.gd:77)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBrown", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:79)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBlack", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:80)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyWar", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:81)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBoss", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:82)
ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".
   at: load (modules/gdscript/gdscript.cpp:2907)
EXIT_CODE: 0
```

The output contains both:
1. **Class_name RELOAD parse errors** (matched by `isClassNameReloadParseWarning`): multiple `Could not parse global class` and `Could not resolve class` lines with `GDScript::reload`
2. **Fatal script-load error** (matched by `isGodotFatalDiagnosticOutput`): `ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".`

With `exitCode === 0`, the original `isClassNameReloadParseWarning` returned `true` for this mixed output, producing `tooling_parse_warning` even though a fatal diagnostic was also present.

## Why This Fix Is Order-Independent

The original classification flow checked `isGodotFatalDiagnosticOutput` before `isClassNameReloadParseWarning` in `classifyCommandFailure`:

```typescript
if (args.exitCode === 0) {
  if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
  if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
  return undefined
}
```

However, the Godot output above contains patterns from **both** classification functions:
- `isClassNameReloadParseWarning` matches: `/Could not parse global class/i`, `/Could not resolve class/i`, `/GDScript::reload/i` — all present
- `isGodotFatalDiagnosticOutput` matches: `/Failed to load script/i` — present

The fatal diagnostic check was placed first, but `isClassNameReloadParseWarning` was also returning `true` for the same output, creating a race condition. If the evaluation order ever changed or if both conditions were combined in a way that didn't short-circuit, the wrong classification would win.

By adding an **early exit** inside `isClassNameReloadParseWarning` that returns `false` when fatal diagnostics are present, the function now correctly yields to the higher-priority classification regardless of call order:

```typescript
function isClassNameReloadParseWarning(output: string, exitCode: number): boolean {
  if (exitCode !== 0) return false
  if (isGodotFatalDiagnosticOutput(output)) return false  // fatal diagnostics take precedence
  return /Could not parse global class/i.test(output)
    && /Could not resolve class/i.test(output)
    && /GDScript::reload/i.test(output)
}
```

This makes the classification **deterministic and order-independent**: fatal script-load errors always produce `syntax_error`, and pure class_name reload parse errors (without fatal diagnostics) continue to produce `tooling_parse_warning`.

## No Product Code Affected

This change is confined to `.opencode/tools/smoke_test.ts`. No Godot scripts, scenes, or project configuration files are modified.
