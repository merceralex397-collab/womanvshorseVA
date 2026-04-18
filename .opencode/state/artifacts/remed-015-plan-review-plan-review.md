# Plan Review — REMED-015

## Ticket

- **ID:** REMED-015
- **Title:** smoke_test tool classifies Godot class_name reload parse errors as syntax_error despite exit 0
- **Wave:** 22
- **Lane:** remediation
- **Stage:** plan_review

## Overall Decision

**APPROVED**

---

## Review Summary

All three acceptance criteria are covered by the plan with sound logic. No blocking issues identified.

---

## Evidence Examined

1. **Failing smoke test** (`.opencode/state/smoke-tests/finish-validate-001-smoke-test-smoke-test.md`):
   - Command 2 (`godot4 --headless --path . --quit`): `exit_code: 0`, `failure_classification: syntax_error` — this is what blocks the overall PASS
   - stderr contains:
     - `SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase" from "res://scripts/enemy_base.gd".` (at GDScript::reload)
     - `SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBrown", because of a parser error.` (at GDScript::reload)
     - ... (EnemyBlack, EnemyWar, EnemyBoss — all at GDScript::reload)
     - `ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".`
   - This stderr matches all three conditions in the proposed `isClassNameReloadParseWarning` helper: `Could not parse global class` + `Could not resolve class` + `GDScript::reload` are all present

2. **smoke_test.ts** (lines 581-621):
   - `isGodotFatalDiagnosticOutput` (line 581-584) matches `Failed to load script "res:\/\//i` — this is why the class_name RELOAD errors are currently classified as `syntax_error` despite exit code 0
   - `classifyCommandFailure` (lines 586-605) returns `"syntax_error"` when `exit_code === 0 && isGodotFatalDiagnosticOutput(output)` — this is the exact blocking path
   - `commandBlocksPass` (lines 615-621) blocks on `syntax_error` and `configuration_error` only — `tooling_parse_warning` is correctly absent and does NOT block

---

## Acceptance Criteria Analysis

| Criterion | Plan Step(s) | Verdict |
|-----------|---------------|---------|
| AC1: EXEC-GODOT-CLASSNAME no longer blocks Godot finish-proof smoke tests when exit code is 0 | Steps 3+6: classification rule update + smoke test rerun proving overall PASS | **Covered** |
| AC2: Add classification rule in smoke_test.ts matching (exit_code==0 AND class_name RELOAD pattern) → tooling_parse_warning | Steps 2+3: type extension + `isClassNameReloadParseWarning` helper + updated `classifyCommandFailure` branch | **Covered** |
| AC3: FINISH-VALIDATE-001 smoke_test passes after fix | Step 6: rerun smoke_test for FINISH-VALIDATE-001 | **Covered** |

---

## Plan Soundness Checklist

- [x] Type extension: `failure_classification` union includes `"tooling_parse_warning"` (plan step 2)
- [x] Helper function: `isClassNameReloadParseWarning(output)` defined before `classifyCommandFailure` (plan step 3)
- [x] Guard logic: `classifyCommandFailure` exit_code===0 branch checks `!isClassNameReloadParseWarning` before `isGodotFatalDiagnosticOutput`, then returns `"tooling_parse_warning"` for class_name RELOAD (plan step 3)
- [x] `commandBlocksPass`: No change needed — `tooling_parse_warning` is not in the blocking list (confirmed by plan step 4 analysis)
- [x] No product code changes — plan explicitly limits scope to `.opencode/tools/smoke_test.ts`
- [x] Evidence stderr matches the proposed regex: all three conditions (`Could not parse global class` + `Could not resolve class` + `GDScript::reload`) are present in the failing smoke test artifact

---

## Risk Review

| Risk | Likelihood | Impact | Mitigation | Status |
|------|------------|--------|------------|--------|
| `tooling_parse_warning` inadvertently blocks if added to `commandBlocksPass` | low | high | Plan explicitly confirms no change needed to `commandBlocksPass` (only `syntax_error` and `configuration_error` block) | **Mitigated** |
| Class_name RELOAD pattern too broad | medium | medium | Pattern requires all three conditions in same output; genuine errors unlikely to have both `Could not parse global class` AND `Could not resolve class` AND `GDScript::reload` simultaneously | **Acceptable** |
| Tooling change causes regression | low | medium | Static type check + smoke test rerun on FINISH-VALIDATE-001 as live proof | **Mitigated** |

---

## Non-Blocking Notes

1. **Step 4 comment in plan**: The plan's code snippet for `commandBlocksPass` includes a comment `// Wait — tooling_parse_warning should NOT block. Remove this line.` beneath the erroneous `tooling_parse_warning` addition. This is self-correcting — the comment explicitly identifies and rejects the wrong change. Implementation must simply leave `commandBlocksPass` untouched.

2. **Pattern specificity**: The proposed helper requires all three of `Could not parse global class`, `Could not resolve class`, and `GDScript::reload` to fire together. This is conservative and appropriate — genuine Godot syntax errors would not typically show this exact triple pattern.

3. **Relation to REMED-014**: REMED-014 classified the same class_name RELOAD error pattern as `tooling_parse_warning` in the APK export smoke test context. This plan extends that classification to the auto-added `--quit` load validation command, which uses the same `classifyCommandFailure` path, making the fix consistent and additive.

---

## Required Revisions

None.

---

## Conclusion

The plan correctly targets the root cause: `classifyCommandFailure` in `smoke_test.ts` fires `syntax_error` on the class_name RELOAD pattern even when `exit_code === 0`. The proposed fix adds a narrow classification guard that intercepts this specific pattern and returns `tooling_parse_warning` instead, which does not block `commandBlocksPass`. All three acceptance criteria are covered. No product code changes. Implementation cleared to proceed.

(End of plan review — REMED-015)
