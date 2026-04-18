# Planning Artifact — REMED-015

## Ticket

- **ID:** REMED-015
- **Title:** smoke_test tool classifies Godot class_name reload parse errors as syntax_error despite exit 0
- **Wave:** 22
- **Lane:** remediation
- **Stage:** planning

---

## Problem Statement

The `smoke_test` tool auto-adds `godot4 --headless --path . --quit` as a second validation command for Godot finish-proof tickets (FINISH-VALIDATE-001, RELEASE-001). The `classifyCommandFailure` function in `.opencode/tools/smoke_test.ts` classifies the stderr output as `syntax_error` when `exit_code === 0` and `isGodotFatalDiagnosticOutput` matches — specifically the `Failed to load script "res://scripts/wave_spawner.gd"` pattern appearing in the class_name RELOAD error artifact.

This is the same error pattern that REMED-014 classified as `tooling_parse_warning`. However, REMED-014's fix only addressed the APK export smoke test (which directly calls `--export-debug`), not the auto-added `--quit` load validation command. The smoke_test tool does not read remediation ticket state when classifying auto-added commands.

**Evidence:** The FINISH-VALIDATE-001 smoke test artifact shows:
- Command 1 (APK export): `exit_code: 0` → `failure_classification: none` → PASS
- Command 2 (auto-added `--quit`): `exit_code: 0` → `failure_classification: syntax_error` → blocks overall PASS

**Class_name RELOAD error pattern to match:**
```
SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase" from "res://scripts/enemy_base.gd".
          at: GDScript::reload (res://scripts/wave_spawner.gd:77)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBrown", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:79)
...
ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse problem".
```

---

## Scope

**In scope:**
- `.opencode/tools/smoke_test.ts` — tooling classification fix only
- No product code changes (no changes to `scripts/`, `scenes/`, `project.godot`, or export artifacts)

**Out of scope:**
- Product code changes
- Changes to how REMED-014 classified the APK export command

---

## Files Affected

| File | Change |
|------|--------|
| `.opencode/tools/smoke_test.ts` | Classification rule + type extension + `commandBlocksPass` guard |

---

## Implementation Steps

### Step 1 — Inspect the existing classification logic (lines 586-605)

The current `classifyCommandFailure` function:

```typescript
function classifyCommandFailure(args: { ... }): CommandResult["failure_classification"] {
  const output = `${args.stdout}\n${args.stderr}`
  if (args.missingExecutable) return "missing_executable"
  if (args.blockedByPermissions) return "permission_restriction"
  if (args.exitCode === 0) {
    if (isGodotFatalDiagnosticOutput(output)) return "syntax_error"  // ← fires on class_name RELOAD
    return undefined
  }
  if (isSyntaxErrorOutput(output)) return "syntax_error"
  ...
}
```

The `isGodotFatalDiagnosticOutput` (lines 581-584) matches:
- `SCRIPT ERROR:.*(?:not declared in the current scope|not found in base self)/i`
- `Failed to load script "res:\/\//i`

The stderr from the auto-added `--quit` command contains `Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".` — which matches the second pattern.

### Step 2 — Extend the `failure_classification` type (line 44)

Current type:
```typescript
failure_classification?: "missing_executable" | "permission_restriction" | "syntax_error" | "test_failure" | "configuration_error" | "command_error"
```

Add `"tooling_parse_warning"`:
```typescript
failure_classification?: "missing_executable" | "permission_restriction" | "syntax_error" | "tooling_parse_warning" | "test_failure" | "configuration_error" | "command_error"
```

### Step 3 — Add class_name RELOAD classification rule in `classifyCommandFailure`

Add a helper function:
```typescript
function isClassNameReloadParseWarning(output: string): boolean {
  return (
    /Could not parse global class "[A-Za-z]+"/.test(output)
    && /Could not resolve class "[A-Za-z]+"/.test(output)
    && /GDScript::reload/.test(output)
  )
}
```

Then update the `exit_code === 0` branch in `classifyCommandFailure`:
```typescript
if (args.exitCode === 0) {
  if (isGodotFatalDiagnosticOutput(output) && !isClassNameReloadParseWarning(output)) return "syntax_error"
  if (isClassNameReloadParseWarning(output)) return "tooling_parse_warning"
  return undefined
}
```

This ensures:
- Genuine `Failed to load script` errors (without the class_name RELOAD pattern) → `syntax_error`
- Class_name RELOAD parse errors with exit_code==0 → `tooling_parse_warning`
- No regression to existing behavior for non-class_name cases

### Step 4 — Update `commandBlocksPass` to exclude `tooling_parse_warning` (lines 615-621)

Current:
```typescript
function commandBlocksPass(command: Pick<CommandResult, "exit_code" | "failure_classification">): boolean {
  return (
    command.exit_code !== 0
    || command.failure_classification === "syntax_error"
    || command.failure_classification === "configuration_error"
  )
}
```

Update to:
```typescript
function commandBlocksPass(command: Pick<CommandResult, "exit_code" | "failure_classification">): boolean {
  return (
    command.exit_code !== 0
    || command.failure_classification === "syntax_error"
    || command.failure_classification === "configuration_error"
    || command.failure_classification === "tooling_parse_warning"  // ← new
  )  // Wait — tooling_parse_warning should NOT block. Remove this line.
}
```

Actually, per REMED-014 plan-review note 3: "commandBlocksPass treats syntax_error as a blocking classification regardless of exit code. If a new tooling_parse_warning classification is added, it must NOT trigger commandBlocksPass."

So `tooling_parse_warning` must NOT be added to `commandBlocksPass`. The current `commandBlocksPass` logic (blocking on `syntax_error` and `configuration_error`) is correct — `tooling_parse_warning` should be treated like `undefined` or `test_failure` (non-blocking). No change to `commandBlocksPass` is needed.

### Step 5 — Static verification

Verify the following in `.opencode/tools/smoke_test.ts`:
1. Line 44: `failure_classification` type includes `"tooling_parse_warning"`
2. New `isClassNameReloadParseWarning` function is defined before `classifyCommandFailure`
3. `classifyCommandFailure` `exit_code === 0` branch checks for `isClassNameReloadParseWarning` and returns `"tooling_parse_warning"` before falling through to `syntax_error`
4. No changes to any `scripts/`, `scenes/`, or `project.godot` files

### Step 6 — Smoke test rerun for FINISH-VALIDATE-001

After applying the fix:
1. Run `smoke_test` for FINISH-VALIDATE-001
2. Expected result:
   - Command 1 (APK export): `exit_code: 0` → `failure_classification: none` → PASS
   - Command 2 (auto-added `--quit`): `exit_code: 0` → `failure_classification: tooling_parse_warning` → does NOT block
   - Overall: PASS

---

## Validation Plan

| Check | Method | Pass Criterion |
|-------|--------|---------------|
| 1. Type extended | Grep line 44 for `tooling_parse_warning` | Pattern present in type union |
| 2. Classification rule | Grep `isClassNameReloadParseWarning` after line 580 | Function defined |
| 3. `tooling_parse_warning` returned | Grep `return "tooling_parse_warning"` in `classifyCommandFailure` | Return statement present in exit_code===0 branch |
| 4. No product code changes | `git diff scripts/ scenes/ project.godot` | Empty diff |
| 5. FINISH-VALIDATE-001 smoke test | Run `smoke_test` for FINISH-VALIDATE-001 | Overall PASS with `tooling_parse_warning` on command 2 |
| 6. APK export still works | `godot4 --headless --path . --export-debug "Android Debug" build/android/womanvshorseVA-debug.apk` | exit code 0 |

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-------------|--------|------------|
| `tooling_parse_warning` inadvertently blocks if added to `commandBlocksPass` | low | high | Verify `commandBlocksPass` is unchanged (only `syntax_error` and `configuration_error` block) |
| Class_name RELOAD pattern is too broad and misclassifies genuine errors | medium | medium | Pattern requires all three conditions: `Could not parse global class` + `Could not resolve class` + `GDScript::reload` in same output |
| Tooling change causes regression in other smoke-test scenarios | low | medium | Static verification of type and classification rule; smoke test rerun on FINISH-VALIDATE-001 as live proof |

---

## Acceptance Criteria Mapping

| Criterion | Covered By |
|-----------|------------|
| EXEC-GODOT-CLASSNAME no longer blocks Godot finish-proof smoke tests when exit code is 0 | Steps 3+6: classification rule + smoke test rerun proving overall PASS |
| Classification rule added in smoke_test.ts matching class_name RELOAD pattern → tooling_parse_warning | Steps 2+3: type extension + classification rule |
| FINISH-VALIDATE-001 smoke_test passes after fix | Step 6: smoke test rerun |

---

## Blockers

None identified. This is a tooling classification fix with no product code changes required.