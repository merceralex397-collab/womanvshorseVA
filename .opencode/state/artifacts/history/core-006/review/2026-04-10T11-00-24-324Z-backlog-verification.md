# Backlog Verification — CORE-006: Create enemy variants (brown, black, war horse, boss)

## Verification Metadata
- **Ticket:** CORE-006
- **Requested by:** wvhva-backlog-verifier
- **Date:** 2026-04-10
- **Process version:** 7 (post-migration, pending process verification)
- **Process change summary:** Canonical Scafforge managed repair run from package repo against latest diagnosis basis 20260409-231521.

---

## Verdict: FAIL ❌

**CORE-006 fails backlog verification.** The smoke-test artifact claiming PASS is contradicted by the actual stderr output it contains, which shows parse errors that prevent the wave spawner from instantiating enemy variants. Acceptance criterion #6 ("Wave spawner can instantiate any variant by type name") is **blocked by parse errors**.

---

## Findings (Ordered by Severity)

### SEV-1: Smoke-test artifact fabricated as PASS despite parse errors (Critical)
- **Artifact:** `.opencode/state/smoke-tests/core-006-smoke-test-smoke-test.md`
- **Artifact summary says:** "Deterministic smoke test passed." / "Overall Result: PASS" / "exit_code: 0"
- **Actual stderr in the same artifact shows:**
  ```
  SCRIPT ERROR: Parse Error: Identifier "EnemyBrown" not declared in the current scope.
            at: GDScript::reload (res://scripts/wave_spawner.gd:78)
  SCRIPT ERROR: Parse Error: Identifier "EnemyBlack" not declared in the current scope.
            at: GDScript::reload (res://scripts/wave_spawner.gd:79)
  SCRIPT ERROR: Parse Error: Identifier "EnemyWar" not declared in the current scope.
            at: GDScript::reload (res://scripts/wave_spawner.gd:80)
  SCRIPT ERROR: Parse Error: Identifier "EnemyBoss" not declared in the current scope.
            at: GDScript::reload (res://scripts/wave_spawner.gd:81)
  ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".
  ```
- **Impact:** Acceptance criterion #6 is blocked. The wave spawner cannot instantiate any enemy variant at runtime.
- **Severity:** Critical — workflow integrity violation (fabricated smoke-test PASS)

### SEV-2: Wave spawner parse errors block enemy variant instantiation (Critical)
- **File:** `scripts/wave_spawner.gd` lines 76-82
- **Symptom:** During `godot4 --headless` script reload, `EnemyBrown`, `EnemyBlack`, `EnemyWar`, `EnemyBoss` are reported as "not declared in the current scope"
- **Symptom location:** `_create_enemy()` match arms at lines 78-81
- **Expected behavior:** `class_name` declarations in `enemy_brown.gd`, `enemy_black.gd`, `enemy_war.gd`, `enemy_boss.gd` should make these class names globally accessible
- **Actual behavior:** Script parser reports these identifiers as unknown during wave_spawner.gd reload
- **Impact:** Acceptance criterion #6 ("Wave spawner can instantiate any variant by type name") is not verifiable
- **Severity:** Critical — core acceptance criterion blocked

### SEV-3: hud.gd parse errors (Pre-existing, unrelated to CORE-006)
- **Artifact content in smoke-test stderr:**
  ```
  SCRIPT ERROR: Parse Error: Function "draw_circle()" not found in base self.
            at: GDScript::reload (res://scripts/hud.gd:47)
  SCRIPT ERROR: Parse Error: Function "queue_redraw()" not found in base self.
            at: GDScript::reload (res://scripts/hud.gd:51)
  ```
- **File:** `scripts/hud.gd` (lines 47 and 51)
- **Note:** `draw_circle()` and `queue_redraw()` ARE valid Godot 4 CanvasItem methods for use in `_draw()`. This parse error appears to be a systemic headless environment issue, not an implementation defect in CORE-006.
- **Severity:** Informational — unrelated to CORE-006 but indicates systemic headless validation issues

---

## Evidence References

| Source | Path | Key Content |
|--------|------|-------------|
| Smoke-test artifact | `.opencode/state/smoke-tests/core-006-smoke-test-smoke-test.md` | Claims PASS / exit_code 0; same file contains stderr with parse errors |
| Implementation artifact | `.opencode/state/implementations/core-006-implementation-implementation.md` | Source code showing all 4 variant scripts created with correct stats |
| Source script (brown) | `scripts/enemy_brown.gd` | `class_name EnemyBrown` / `extends EnemyBase` — correct |
| Source script (black) | `scripts/enemy_black.gd` | `class_name EnemyBlack` / `extends EnemyBase` — correct |
| Source script (war) | `scripts/enemy_war.gd` | `class_name EnemyWar` / `extends EnemyBase` — correct |
| Source script (boss) | `scripts/enemy_boss.gd` | `class_name EnemyBoss` / `extends EnemyBase` — correct |
| Wave spawner | `scripts/wave_spawner.gd` lines 76-82 | `_create_enemy()` match with `EnemyBrown.new()` etc. — source code correct |
| QA artifact | `.opencode/state/qa/core-006-qa-qa.md` | "Static Verification: 6/6 PASS" / "Smoke Test: BLOCKED (environment constraint)" |

---

## Workflow Drift

1. **Smoke-test artifact integrity violation:** The `smoke_test` tool recorded `exit_code: 0` and `Overall Result: PASS` despite parse errors appearing in the same artifact's stderr. A passing smoke test requires clean stderr, not just exit code 0 from a Godot headless invocation that may exit 0 even when script errors occur.

2. **QA artifact blocked smoke test but still recorded PASS:** The QA artifact (`.opencode/state/qa/core-006-qa-qa.md`) correctly notes "Smoke Test: BLOCKED (environment constraint)" but then still records "QA VERDICT: PASS (with smoke test blocker noted)". The QA verdict should have been `BLOCKED` when smoke test evidence is absent or unreliable.

3. **Trust chain corruption:** CORE-006's `verification_state` in `manifest.json` shows `"trusted"` despite the smoke test being unreliable. This is a process-verification gap, not an implementation gap — the source implementation appears correct, but the proof artifacts are unreliable.

---

## Recommendation

**REVOKE trust on CORE-006.**

Immediate actions required:
1. **Re-run smoke test** via the `smoke_test` tool (not via artifact tools) to get a clean stderr trace
2. **Resolve wave_spawner.gd parse errors** — the `EnemyBrown` etc. identifiers not being recognized suggests either:
   - A load-order issue where the variant scripts aren't being registered before wave_spawner.gd
   - A systemic headless environment issue preventing `class_name` registration
3. **Resolve hud.gd parse errors** — pre-existing issue blocking any godot headless validation from succeeding cleanly
4. **Re-verify** once smoke test passes with clean stderr; then run `ticket_reverify` to restore trust

CORE-006's implementation source code (4 variant scripts + wave_spawner match) is **correct per the artifact bodies**, but the **proof artifacts are unreliable** (fabricated smoke-test PASS + QA BLOCKED smoke test but still recording PASS verdict).

---

## Follow-up Ticket Required

Create a remediation ticket (REMED-00X) for:
1. CORE-006 re-verification after resolving parse errors
2. hud.gd parse error resolution (pre-existing blocker affecting all smoke tests)
3. Systemic smoke-test tool reliability — `godot4 --headless --quit` exits 0 even when scripts fail to parse

**This backlog verification itself is the required evidence for the follow-up ticket creation.**
