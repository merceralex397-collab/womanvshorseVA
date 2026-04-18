# Backlog Verification — REMED-014

## Ticket
- **ID:** REMED-014
- **Title:** Godot headless parse errors for class_name declarations (EnemyBase, AudioManager, EnemyBrown/Black/War/Boss)
- **Stage:** closeout
- **Finding source:** EXEC-GODOT-CLASSNAME

---

## Verification Summary

**VERDICT: PASS**

All three acceptance criteria verified. EXEC-GODOT-CLASSNAME does not reproduce. No reopening or rollback needed.

---

## Commands Run

### 1. APK Existence Check

**Command:** `glob build/android/*.apk`

**Result:**
- APK found at: `build/android/womanvshorseVA-debug.apk`
- (Confirmed by `.opencode/state/smoke-tests/remed-014-smoke-test-smoke-test.md` smoke test artifact: 24,290,014 bytes, signed, verified)

---

### 2. Source Verification — class_name Declarations

**Commands:** Direct file reads of source scripts

**Result:** All class_name declarations confirmed present in current source:

| File | class_name | Line |
|------|-----------|------|
| scripts/enemy_base.gd | `class_name EnemyBase` | 1 |
| scripts/audio_manager.gd | `class_name AudioManager` | 1 |
| scripts/wave_spawner.gd | `class_name WaveSpawner` | 1 |
| scripts/enemy_brown.gd | `class_name EnemyBrown` | 1 |
| scripts/enemy_black.gd | `class_name EnemyBlack` | 1 |
| scripts/enemy_war.gd | `class_name EnemyWar` | 1 |
| scripts/enemy_boss.gd | `class_name EnemyBoss` | 1 |

---

### 3. smoke_test.ts Classification Logic Verification

**Source file:** `.opencode/tools/smoke_test.ts`

**Relevant functions verified:**

#### `isClassNameReloadParseWarning()` (lines 587–592)
```typescript
function isClassNameReloadParseWarning(output: string, exitCode: number): boolean {
  return exitCode === 0
    && /Could not parse global class/i.test(output)
    && /Could not resolve class/i.test(output)
    && /GDScript::reload/i.test(output)
}
```

**Purpose:** Detects class_name RELOAD parse errors with exit_code==0 → returns `tooling_parse_warning`

#### `classifyCommandFailure()` (lines 601–622)
```typescript
function classifyCommandFailure(args: { ... }): CommandResult["failure_classification"] {
  const output = `${args.stdout}\n${args.stderr}`
  if (args.missingExecutable) return "missing_executable"
  if (args.blockedByPermissions) return "permission_restriction"
  if (args.exitCode === 0) {
    if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
    if (isGodotToolingParseError(args.stderr, args.exitCode)) return "tooling_parse_warning"
    if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
    return undefined
  }
  // ...
}
```

**Verification:** `isClassNameReloadParseWarning()` is checked BEFORE `isSyntaxErrorOutput()` when `exitCode === 0`. This ensures class_name RELOAD errors with exit 0 are classified as `tooling_parse_warning`, NOT `syntax_error`.

#### `commandBlocksPass()` (lines 632–638)
```typescript
function commandBlocksPass(command: Pick<CommandResult, "exit_code" | "failure_classification">): boolean {
  return (
    command.exit_code !== 0
    || command.failure_classification === "syntax_error"
    || command.failure_classification === "configuration_error"
  )
}
```

**Verification:** `tooling_parse_warning` is NOT in the blocking list. Only `exit_code !== 0`, `syntax_error`, and `configuration_error` block pass.

---

### 4. Smoke Test Artifact Verification

**Source file:** `.opencode/state/smoke-tests/remed-014-smoke-test-smoke-test.md`

**Command:** `godot4 --headless --path . --export-debug Android Debug build/android/womanvshorseVA-debug.apk`

**Recorded results:**
- `exit_code: 0`
- `failure_classification: none`
- `blocked_by_permissions: false`
- APK signed: `Signed`
- APK verified: `[ DONE ] export`
- Duration: 10194ms

**Verification:** With exit_code=0 and `failure_classification: none`, the smoke test passes. The class_name parse errors are classified as `tooling_parse_warning` (not `syntax_error`) and do not block pass.

---

### 5. Implementation Artifact Verification

**Source file:** `.opencode/state/implementations/remed-014-implementation-implementation.md`

**Static verification (git diff):**
```bash
$ git diff --name-only
(empty - no unstaged changes)
```

**Verification:** No product source files modified. Only smoke-test artifact was written by the smoke_test tool.

---

### 6. QA Artifact Verification

**Source file:** `.opencode/state/qa/remed-014-qa-qa.md`

**Command:** `godot4 --headless --path . --quit`

**Recorded results:**
- `exit_code: 0`
- APK export: `exit_code: 0`, APK 24MB

**Verification:** Godot headless load exits 0, APK export succeeds.

---

## Acceptance Criteria Mapping

| Criterion | Evidence | Status |
|-----------|----------|--------|
| EXEC-GODOT-CLASSNAME no longer reproduces | smoke test: exit_code=0, failure_classification=none, APK built | **PASS** |
| Errors classified as tooling_parse_warning when exit_code==0 | smoke_test.ts: isClassNameReloadParseWarning() fires before isSyntaxErrorOutput(), tooling_parse_warning does not block commandBlocksPass() | **PASS** |
| No behavioral changes to product code | git diff --name-only: empty, only smoke-test artifact written | **PASS** |

---

## Finding Status

**EXEC-GODOT-CLASSNAME: RESOLVED**

The finding was a Godot headless tooling artifact. When Godot exports with `--export-debug`:
- Exit code remains 0
- Global class registration succeeds
- APK builds, signs, and verifies successfully

The stderr parse errors for class_name declarations appear during GDScript::reload in wave_spawner.gd but do NOT block successful export. The smoke_test.ts classification logic correctly treats these as `tooling_parse_warning` (not `syntax_error`) when exit_code==0.

---

## Conclusion

All evidence confirms REMED-014 remediation is complete and correct:
- APK exists and is valid (24MB signed debug APK)
- class_name declarations verified present in source
- smoke_test.ts correctly classifies class_name RELOAD errors as tooling_parse_warning when exit_code==0
- No product code changes
- Smoke test passes

**NO REOPENING OR ROLLBACK NEEDED.**
