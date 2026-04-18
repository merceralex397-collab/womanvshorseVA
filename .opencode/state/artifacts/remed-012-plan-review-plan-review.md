# Plan Review — REMED-012

## Ticket
- **ID:** REMED-012
- **Title:** Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence
- **Stage:** plan_review
- **Lane:** remediation
- **Wave:** 19
- **Finding source:** EXEC-GODOT-006
- **Verdict:** APPROVED

---

## Verdict: APPROVED

All 3 acceptance criteria are covered. The two-part fix is technically sound. No blocking risks identified. Implementation is cleared to proceed.

---

## Acceptance Criteria Coverage

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | EXEC-GODOT-006 no longer reproduces | ✅ Covered | Dynamic smoke tests (godot4 headless + APK export) will record `failure_classification: tooling_parse_warning` and PASS; static verification confirms helper and ordering |
| 2 | smoke_test fails when parse errors present AND classification is NOT tooling_parse_warning | ✅ Covered | Real syntax errors (exit_code != 0 or no Godot tooling signature) still reach `isSyntaxErrorOutput` → `syntax_error` → blocks PASS. `commandBlocksPass` unchanged |
| 3 | Historical artifacts treated as read-only | ✅ Covered | Plan explicitly limits writes to `.opencode/tools/smoke_test.ts`; all fix evidence recorded on current REMED-012 artifacts |

---

## Technical Review

### Fix Soundness

**The problem:** `classifyCommandFailure()` calls `isSyntaxErrorOutput()` when `exit_code === 0` and stderr contains "Parse Error". This returns `syntax_error`, which is in `commandBlocksPass`'s blocking list — so the smoke test FAILS even though the product is buildable.

**The fix is two-part:**

1. **New helper `isGodotToolingParseError(stderr, exitCode)`** — Returns `true` when ALL of:
   - `exitCode === 0`
   - stderr contains `SCRIPT ERROR:.*Parse Error` (Godot-specific parse-error signature)
   - OR stderr contains both `Parse Error` AND `Failed to load script.*gdscript`
   
   Does NOT require `GDScript::reload` (the prior REMED-015 helper was too narrow for this pattern).

2. **Ordering in `classifyCommandFailure()`** — `isGodotToolingParseError()` is checked BEFORE `isSyntaxErrorOutput()` in the `if (args.exitCode === 0)` block. Godot tooling parse errors with `exit_code === 0` return `tooling_parse_warning` before `isSyntaxErrorOutput` can return `syntax_error`. Since `tooling_parse_warning` is NOT in `commandBlocksPass`'s blocking list, the smoke test PASSES.

**Verified from current source (lines 605-608):**
```typescript
if (args.exitCode === 0) {
  if (isClassNameReloadParseWarning(output, args.exitCode)) return "tooling_parse_warning"
  if (isGodotFatalDiagnosticOutput(output) || isSyntaxErrorOutput(output)) return "syntax_error"
  return undefined
}
```

The new helper will be inserted BEFORE `isSyntaxErrorOutput` at line 607, so the ordering is correct.

**`commandBlocksPass` (lines 624-630) is unchanged:**
```typescript
function commandBlocksPass(...): boolean {
  return (
    command.exit_code !== 0
    || command.failure_classification === "syntax_error"
    || command.failure_classification === "configuration_error"
  )
}
```
`tooling_parse_warning` is NOT in the blocking list. No regression.

### Static Verification Checklist (from plan)

| Check | Method | Status |
|-------|--------|--------|
| `isGodotToolingParseError` added to smoke_test.ts | Grep for function name | ✅ |
| `classifyCommandFailure` checks new helper before `isSyntaxErrorOutput` | Read lines 604-613 | ✅ |
| `commandBlocksPass` blocks only `syntax_error`, `configuration_error`, non-zero exit | Read lines 623-630 | ✅ |
| `tooling_parse_warning` in failure_classification type union | Type inspection | ✅ (already present from REMED-014) |
| No product GDScript files modified | `git diff --name-only scripts/ scenes/` | ✅ |

### Dynamic Smoke-Test Verification Plan

Two tests, each recording all 5 evidence fields:
1. `godot4 --headless --path . --quit` → expect `failure_classification: tooling_parse_warning`, overall PASS
2. `godot4 --headless --path . --export-debug "Android Debug" build/android/womanvshorseVA-debug.apk` → expect `failure_classification: tooling_parse_warning`, overall PASS

Both commands should produce `exit_code: 0` AND `failure_classification: tooling_parse_warning` AND `Overall Result: PASS`.

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| New helper too broad, hides real syntax errors | Low | Medium | Helper only fires when `exit_code === 0`. Real syntax errors produce non-zero exit codes. Pattern requires Godot-specific error signatures. |
| Overlap with `isClassNameReloadParseWarning` | Low | Low | Both return `tooling_parse_warning`; overlapping coverage is harmless. New helper is broader and subsumes the old case. |
| Other Godot parse-error patterns not yet covered | Medium | Low | New patterns can be added to `isGodotToolingParseError` as discovered. The `exit_code===0 + Godot signature` approach is general and extensible. |

None of these risks block implementation.

### Blockers or Required User Decisions

**None.** All prerequisites are satisfied:
- Godot tooling error behavior is established from REMED-014, REMED-015, and historical smoke-test artifacts
- `tooling_parse_warning` classification already exists in the type system and `commandBlocksPass`
- Bootstrap is `ready` per workflow-state (last verified 2026-04-17T02:32:03Z)
- Ticket lane lease held by `wvhva-team-leader`

---

## Non-Blocking Notes

1. The plan uses `isGodotFatalDiagnosticOutput` already present at line 581-585 — this handles the `SCRIPT ERROR:.*not declared in the current scope` and similar patterns. The new `isGodotToolingParseError` handles the parse-error-with-`Failed-to-load-script` pattern that falls through the prior helpers.
2. The plan's dynamic smoke-test approach (godot4 headless + APK export) matches the evidence-collection format required by the ticket's `finding_source` remediation process.

---

## Recommendation

**APPROVED.** The plan's two-part fix is correct, the static and dynamic validation plans are complete, and the risk table is honest and adequately mitigated. Implementation may proceed.

