# Plan Review — REMED-014

## Ticket

- **ID:** REMED-014
- **Title:** Godot headless parse errors for class_name declarations (EnemyBase, AudioManager, EnemyBrown/Black/War/Boss)
- **Stage:** plan_review

## Finding Source

EXEC-GODOT-CLASSNAME

## Plan Artifact

`.opencode/state/plans/remed-014-planning-plan.md`

---

## Review Result

**Decision: APPROVED**

---

## Analysis

### What the finding actually is

The smoke-test tool in `.opencode/tools/smoke_test.ts` misclassifies Godot headless reload errors as `syntax_error`. The `classifyCommandFailure` function (lines 586-605) returns `syntax_error` when:

1. `exit_code === 0` AND `isGodotFatalDiagnosticOutput(output)` matches

The `isGodotFatalDiagnosticOutput` helper (lines 581-584) matches:
- `SCRIPT ERROR:.*not declared in the current scope`
- `Failed to load script "res:\/\/`

These patterns fire on the Godot headless reload artifact where `wave_spawner.gd` references `EnemyBase`, `AudioManager`, and the four enemy variants — but exit code is still 0, meaning Godot actually loaded the project successfully despite those reload warnings.

The AUDIO-001 smoke-test artifact confirms this: `failure_classification: syntax_error` was assigned despite `exit_code: 0`.

### Plan soundness

The plan's 5-step approach is correct:

1. **Inspect smoke-test artifact** — confirms the exact error pattern and `failure_classification: syntax_error` despite exit_code 0 (lines 21-25 of the artifact).

2. **Identify classification logic location** — The plan names potential locations, but the concrete location is `.opencode/tools/smoke_test.ts`, specifically `isGodotFatalDiagnosticOutput` (lines 581-584) and the `exit_code === 0` branch in `classifyCommandFailure` (lines 597-599). Step 2 implicitly resolves to this through inspection.

3. **Update classification rule** — The proposed fix (classify as `tooling_parse_warning` instead of `syntax_error` when exit_code==0 AND class_name reload artifacts are present) correctly targets the root cause. The implementation should refine `isGodotFatalDiagnosticOutput` or add a subclassification guard that recognizes class_name reload ordering artifacts vs. genuine syntax errors.

4. **Rerun smoke_test for AUDIO-001** — This is the correct verification step.

5. **Verify no product code changes** — Correct safeguard.

### Validation plan

The four validation items (static verification, smoke test rerun, no regression, evidence recording) are all correct and traceable.

### Risks

The plan identifies the risk that "smoke-test tool does not have configurable classification rules" as medium likelihood with low impact. This is accurate — the classification IS hardcoded in the TypeScript tool. The mitigation ("document limitation and route as tooling artifact with exit-code-only validation") is workable but the plan should go further: the fix should modify `isGodotFatalDiagnosticOutput` or `classifyCommandFailure` directly in `.opencode/tools/smoke_test.ts` to add a `tooling_parse_warning` classification, not just document a limitation.

However, since `failure_classification` type (line 44) only defines six string literals and `tooling_parse_warning` is not one of them, adding this classification requires a TypeScript code change to the tool itself. The plan acknowledges no product code changes — this IS a tool code change, which is appropriate since the finding is about the smoke-test classification, not product code.

### Blockers

None. This is a tooling classification fix with no product code impact.

---

## Acceptance Criteria Coverage

| Criterion | Status |
|---|---|
| EXEC-GODOT-CLASSNAME no longer reproduces | Covered — step 4 (smoke test rerun) + step 2 (classification fix) |
| No behavioral changes to product code | Covered — step 5 + read-only declaration in scope |
| Smoke-test artifact records exact command + raw stderr + PASS | Covered — step 4 validation |

All three acceptance criteria are addressed by the plan.

---

## Non-Blocking Notes

1. **Classification type must be extended**: The `CommandResult["failure_classification"]` type (line 44) does not include `tooling_parse_warning`. The implementation step must also update this TypeScript type and add the new classification value to `classifyCommandFailure`.

2. **Godot reload artifact pattern is specific**: The class_name reload errors all share the pattern `SCRIPT ERROR: Parse Error: Could not parse global class "X" ... at: GDScript::reload (res://scripts/wave_spawner.gd:NN)` and `Identifier "X" not declared in the current scope ... at: GDScript::reload`. The fix should target this specific reload-in-wavespawner context, not broaden the syntax-error suppression too much.

3. **commandBlocksPass** (line 615-621) treats `syntax_error` as a blocking classification regardless of exit code. If a new `tooling_parse_warning` classification is added, it must NOT trigger `commandBlocksPass` (i.e., must be treated as non-fatal like `undefined`/`test_failure`).

---

## Verdict

Plan APPROVED. All three acceptance criteria covered. The implementation must add a `tooling_parse_warning` classification to the smoke-test tool's type system and ensure it does not block the smoke test when exit_code==0 and the error pattern matches the class_name reload artifact. No product code changes required.
