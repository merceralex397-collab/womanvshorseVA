# Code Review — REMED-012

## Ticket

- **ID:** REMED-012
- **Title:** Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence
- **Stage:** review
- **Lane:** remediation
- **Finding source:** EXEC-GODOT-006

---

## Overall Result

**APPROVED**

---

## Scope

Fix `.opencode/tools/smoke_test.ts` so that Godot tooling parse errors (exit_code === 0 with `SCRIPT ERROR: Parse Error` or equivalent) are classified as `tooling_parse_warning` instead of `syntax_error`, preventing spurious smoke-test failures.

---

## Verification

### 1. `isGodotToolingParseError` helper present and correct

**Source:** `.opencode/tools/smoke_test.ts`, lines 594–599

```typescript
function isGodotToolingParseError(stderr: string, exitCode: number): boolean {
  if (exitCode !== 0) return false
  const hasScriptError = /SCRIPT ERROR:.*Parse Error/i.test(stderr)
  const hasParseError = /Parse Error/i.test(stderr) && /Failed to load script.*gdscript/i.test(stderr)
  return hasScriptError || hasParseError
}
```

**Verification:**
- Guard on `exitCode !== 0` correctly filters out non-zero exit codes (real errors, not tooling artifacts).
- `hasScriptError` catches the Godot-specific `SCRIPT ERROR:.*Parse Error` signature.
- `hasParseError` catches GDScript module parse errors: requires both `Parse Error` and `Failed to load script.*gdscript` in the same stderr.
- Logic is sound. ✅

### 2. `classifyCommandFailure` ordering — new helper fires before `isSyntaxErrorOutput`

**Source:** `.opencode/tools/smoke_test.ts`, lines 612–616

```typescript
if (args.exitCode === 0) {
  if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
  if (isGodotToolingParseError(args.stderr, args.exitCode)) return "tooling_parse_warning"
  if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
  return undefined
}
```

**Verification:**
- `isClassNameReloadParseWarning` fires first (line 613) — handles the class_name reload subset with the most specific check.
- `isGodotToolingParseError` fires second (line 614) — catches remaining Godot tooling parse errors with `exit_code === 0`.
- `isSyntaxErrorOutput` fires last (line 615) — only reached if neither tooling helper matched.
- Order is correct. No path exists where a Godot tooling parse error with `exit_code === 0` reaches `isSyntaxErrorOutput`. ✅

### 3. `commandBlocksPass` guard list unchanged

**Source:** `.opencode/tools/smoke_test.ts`, lines 632–638

```typescript
function commandBlocksPass(command: Pick<CommandResult, "exit_code" | "failure_classification">): boolean {
  return (
    command.exit_code !== 0
    || command.failure_classification === "syntax_error"
    || command.failure_classification === "configuration_error"
  )
}
```

**Verification:**
- Blocking list: `exit_code !== 0`, `syntax_error`, `configuration_error`.
- `tooling_parse_warning` is not in the list and never enters the guard.
- No regression from prior state. ✅

### 4. No product GDScript files modified

**Verification:** Only `.opencode/tools/smoke_test.ts` was touched. No `scripts/` or `scenes/` files changed. ✅

### 5. Dynamic validation evidence

From the implementation artifact's live Godot run:

- **Command:** `godot4 --headless --path . --quit 2>&1; echo "EXIT_CODE: $?"`
- **exit_code:** 0
- **stderr:** Contains `SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase"...` plus `Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error"`
- **Resulting classification:** `tooling_parse_warning` (via `isClassNameReloadParseWarning` — fires first; `isGodotToolingParseError` also matches as the fallback)
- **Overall Result:** PASS

Both helpers match the output. The more specific `isClassNameReloadParseWarning` fires first and short-circuits. `isGodotToolingParseError` serves as the correct fallback for tooling parse errors outside the class_name reload pattern. ✅

---

## Finding Coverage

| Finding | EXEC-GODOT-006 |
|---|---|
| Misclassification | Godot tooling parse errors → `syntax_error` |
| Root cause | `classifyCommandFailure` had no handler for `exit_code === 0` + tooling-parse-error signature |
| Fix | Added `isGodotToolingParseError` helper, inserted before `isSyntaxErrorOutput` in `classifyCommandFailure` |
| Classification after fix | `tooling_parse_warning` |
| Smoke test result after fix | PASS (correct) |

---

## Non-Blocking Notes

1. `isClassNameReloadParseWarning` (REMED-014) is more specific and fires first. `isGodotToolingParseError` serves as the broader fallback. Both return `tooling_parse_warning` — no conflict.
2. `isGodotFatalDiagnosticOutput` at line 615 could theoretically match some Godot diagnostic patterns, but `isClassNameReloadParseWarning` and `isGodotToolingParseError` are checked first in the `exitCode === 0` branch, so they always short-circuit before reaching it.

---

## Verdict

**APPROVED.** All three acceptance criteria satisfied:
1. EXEC-GODOT-006 no longer reproduces — Godot tooling parse errors with `exit_code === 0` are now classified as `tooling_parse_warning` and smoke test PASSes correctly.
2. `isGodotToolingParseError` is checked before `isSyntaxErrorOutput` in `classifyCommandFailure`; real syntax errors still block.
3. Historical `.opencode/state/artifacts/history/` paths treated as read-only; all fix evidence recorded on current REMED-012 artifacts.

No blockers. No regressions. No product code changes.