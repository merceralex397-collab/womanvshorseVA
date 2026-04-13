# Backlog Verification — ANDROID-001

## Ticket
- **ID:** ANDROID-001
- **Title:** Validate Android export surfaces and debug keystore
- **Verification requested by:** wvhva-backlog-verifier agent
- **Process change:** Canonical Scafforge managed repair run (process version 7, 2026-04-10T05:58:09Z)
- **Verification timestamp:** 2026-04-10T11:20:00Z

---

## Verdict: **PASS — TRUST**

All 5 acceptance criteria are satisfied. The QA FAIL on criterion 3 was a timing artifact (checked before smoke test ran). The smoke test subsequently created `build/android/` and produced a signed APK at `build/android/womanvshorseVA-debug.apk`, proving the full export pipeline works.

---

## Acceptance Criteria Review

| # | Criterion | Evidence | Verdict |
|---|-----------|----------|---------|
| 1 | export_presets.cfg defines 'Android Debug' preset with package/unique_name=com.wvh.va | `preset.0.name="Android Debug"`, `package/unique_name="com.wvh.va"` (export_presets.cfg line 6, 38) | ✅ PASS |
| 2 | Debug keystore path in export_presets.cfg points to existing keystore file | `keystore/debug="/home/pc/.local/share/godot/keystores/debug.keystore"` — file confirmed to exist in implementation artifact | ✅ PASS |
| 3 | **build/android/ directory exists** | `build/android/womanvshorseVA-debug.apk` and `build/android/womanvshorseVA-debug.apk.idsig` confirmed present via glob/read — created by smoke-test `mkdir -p` command | ✅ PASS (resolved by smoke test) |
| 4 | project.godot includes textures/vram_compression/import_etc2_astc=true under [rendering] | `textures/vram_compression/import_etc2_astc=true` at project.godot line 16 | ✅ PASS |
| 5 | No __PROJECT_SLUG__ or __PACKAGE_NAME__ placeholders remain in export_presets.cfg | All values concrete: `com.wvh.va`, `womanvshorseVA`, `androiddebugkey`, etc. | ✅ PASS |

---

## Evidence Chain

### Plan Artifact
- Path: `.opencode/state/plans/android-001-planning-plan.md`
- Status: Current
- Summary: Flagged debug keystore as missing but resolved via path validation

### Implementation Artifact
- Path: `.opencode/state/implementations/android-001-implementation-implementation.md`
- Status: Current
- Summary: Static validation of export_presets.cfg, project.godot, debug keystore — all checks pass

### Review Artifact
- Path: `.opencode/state/reviews/android-001-review-review.md`
- Status: Current, APPROVED
- Summary: 4/5 criteria fully met; criterion 3 (build/android/ directory) deferred to RELEASE-001 with note that smoke test would create it

### QA Artifact
- Path: `.opencode/state/qa/android-001-qa-qa.md`
- Status: Current
- Summary: 4/5 pass. Criterion 3 flagged as FAIL because `build/android/` did not exist at time of QA run (2026-04-09T23:31:44)
- **Note:** This was a timing issue. The smoke test ran 2 minutes later and created the directory.

### Smoke Test Artifact
- Path: `.opencode/state/smoke-tests/android-001-smoke-test-smoke-test.md`
- Status: Current, PASS
- Commands executed:
  1. `mkdir -p /home/pc/projects/womanvshorseVA/build/android` → exit code 0
  2. `godot4 --headless --export-debug "Android Debug" .../build/android/womanvshorseVA-debug.apk` → exit code 0, APK built and signed
- APK signed successfully using debug keystore at `/home/pc/.local/share/godot/keystores/debug.keystore`
- APK location: `build/android/womanvshorseVA-debug.apk`

### Current State Verification (live)
- `build/android/womanvshorseVA-debug.apk` exists — confirmed via glob
- `export_presets.cfg` — no placeholders, package=com.wvh.va confirmed
- `project.godot` — `textures/vram_compression/import_etc2_astc=true` confirmed at line 16

---

## Smoke Test Stderr Analysis

```
ERROR: No project icon specified. Please specify one in the Project Settings under Application -> Config -> Icon
   at: load_icon_refs (platform/android/export/export_plugin.cpp:1897)
cannot connect to daemon at tcp:5037: Connection refused
```

- **Icon warning:** Non-blocking. Godot still produced and signed a valid APK. Icon is optional for debug builds.
- **adb daemon warning:** Non-blocking. This is a host-side ADB daemon, not required for export. The APK was signed and verified regardless.

Neither of these errors prevented APK creation, alignment, or signing. Exit code was 0.

---

## Process Change Impact

- **Process version:** 7 (changed at 2026-04-10T05:58:09Z)
- **ANDROID-001 stage artifacts:** Predate the process change (2026-04-09T23:xx)
- **ANDROID-001 smoke test exit code 0:** Evidence predates process change but the current APK still exists and is valid — implementation has not been invalidated
- **Bootstrap:** `ready` — no environment blockers
- **Pending process verification:** `true` — this backlog verification satisfies that requirement for ANDROID-001

---

## Findings Ordered by Severity

1. **None — all acceptance criteria satisfied**

## Workflow Drift or Proof Gaps

1. **GAP (non-blocking):** QA artifact flagged criterion 3 as FAIL at 23:31:44, but smoke test created the directory at 23:33:25. This is a sequencing gap, not an implementation failure. The smoke test resolved the deferred item.

---

## Follow-up Recommendation

**TRUST.** No reverification needed. The ticket holds.

- All 5 acceptance criteria satisfied
- APK successfully built and signed
- Follow-up ticket: RELEASE-001 (owns the actual APK build output verification)
- No reopening, rollback, or remediation tickets required

---

## Canonical Artifact Path
`.opencode/state/reviews/android-001-review-backlog-verification.md`
