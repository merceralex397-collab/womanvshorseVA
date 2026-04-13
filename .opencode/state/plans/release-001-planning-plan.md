# Planning Artifact — RELEASE-001

## Configure Android Export and Build Debug APK

**Ticket**: RELEASE-001  
**Lane**: release-readiness  
**Wave**: 4  
**Stage**: planning  
**Dependencies**: ANDROID-001, CORE-003, CORE-005, POLISH-001, UI-001, UI-002 (all done/reverified)

---

## 1. Scope

RELEASE-001 owns the final Android export verification and fresh debug APK build confirmation. The infrastructure (export_presets.cfg, project.godot settings, build directory) is already in place from prior tickets. This ticket's job is to:

1. Verify the export surfaces are correctly configured
2. Produce a fresh debug APK via `godot4 --headless --export-debug`
3. Confirm the APK is valid (exists, non-zero size)
4. Record smoke-test proof

---

## 2. Files and Systems Affected

| File/Directory | Purpose |
|---|---|
| `export_presets.cfg` | Android Debug preset — must be verified present and valid |
| `project.godot` | Must have `textures/vram_compression/import_etc2_astc=true` under `[rendering]` |
| `build/android/` | Output directory — must exist |
| `build/android/womanvshorseVA-debug.apk` | Final APK deliverable |

---

## 3. Pre-Build Verification

Before running the export, verify the following in order:

### Step 1: Verify export_presets.cfg
- [ ] File exists at repo root
- [ ] Contains `[preset.0]` section labeled "Android Debug"
- [ ] `platform/GodotPayment.java` not referenced (no IAP)
- [ ] No placeholder strings (`__PROJECT_SLUG__`, `__PACKAGE_NAME__`) remain
- [ ] Package name is `com.wvh.va`

### Step 2: Verify project.godot
- [ ] `[rendering]` section exists
- [ ] Contains `textures/vram_compression/import_etc2_astc=true`

### Step 3: Verify build directory
- [ ] `build/android/` directory exists (create via `mkdir -p build/android` if absent)

---

## 4. APK Build Command

Run the Godot headless export:

```bash
godot4 --headless --export-debug "Android Debug" build/android/womanvshorseVA-debug.apk
```

**Note**: `godot4` is the correct binary name on this system (verified by prior smoke tests). The target "Android Debug" must match the preset name exactly as it appears in `export_presets.cfg`.

---

## 5. Post-Build Validation

After the export command completes:

### Step 4: APK existence and size check
- [ ] `build/android/womanvshorseVA-debug.apk` exists (`test -f`)
- [ ] File size is greater than 0 bytes (`stat -c%s` or `wc -c`)

### Step 5: Smoke test proof
- [ ] Command exit code is 0 — **this is the authoritative pass/fail signal**
- [ ] Stdout/stderr output is captured but **not used for pass/fail determination**

**Known tooling artifact**: `godot4 --headless --export-debug` may emit parse errors or warnings to stderr on some configurations. These are **not** indicators of build failure. The exit code is the only reliable signal.

---

## 6. Acceptance Criteria Mapping

| # | Criterion | Verification Method |
|---|---|---|
| 1 | export_presets.cfg has 'Android Debug' preset with valid configuration | Static file check — preset name, package name, no placeholders |
| 2 | project.godot includes `textures/vram_compression/import_etc2_astc=true` under `[rendering]` | Static file grep |
| 3 | build/android/ directory exists | `test -d build/android` |
| 4 | `godot4 --headless --export-debug "Android Debug" build/android/womanvshorseVA-debug.apk` produces an APK | Exit code 0 from export command |
| 5 | APK file is non-zero size | `stat -c%s build/android/womanvshorseVA-debug.apk > 0` |
| 6 | If godot4 is unavailable, blocker is documented with exact missing prerequisite | N/A — godot4 confirmed available from bootstrap evidence |

---

## 7. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| godot4 headless stderr parse errors causing false FAIL on naive stderr checking | Known tooling artifact | Medium | Use exit code 0 as sole pass/fail signal; ignore stderr content |
| export_presets.cfg preset name mismatch | Low | High | Verify preset name matches exactly: "Android Debug" |
| Disk space exhaustion during export | Low | High | Check `df -h build/` before export if concerns arise |
| godot4 binary not in PATH | Low | High | Use `which godot4` or `command -v godot4` as pre-check; document blocker if missing |

---

## 8. Blocker Handling

If `godot4` is unavailable or the export fails with exit code non-zero:

1. Document the exact error output
2. Identify the missing prerequisite (e.g., godot4 not in PATH, Android SDK misconfigured, export templates missing)
3. Report as blocker to team leader with:
   - Exact command attempted
   - Exit code
   - Relevant stderr excerpt
   - Suggested remediation

---

## 9. Implementation Order

```
1. Pre-build verification (static checks)
       ↓
2. mkdir -p build/android  (if directory absent)
       ↓
3. godot4 --headless --export-debug "Android Debug" build/android/womanvshorseVA-debug.apk
       ↓
4. Post-build validation (exit code 0, APK exists, non-zero size)
       ↓
5. Write planning artifact → register → advance to plan_review
```

---

## 10. Derived State

After planning artifact is written and registered:
- Ticket stage advances to `plan_review`
- `approved_plan` set to `true` after plan review approval
- Ticket stage advances to `implementation` (which for RELEASE-001 is primarily the build execution itself)
- Smoke test artifact produced by `smoke_test` tool between QA and closeout
