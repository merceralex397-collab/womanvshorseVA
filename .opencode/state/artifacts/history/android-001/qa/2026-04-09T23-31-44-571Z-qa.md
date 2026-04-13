# QA Verification — ANDROID-001

## Ticket
- **ID:** ANDROID-001
- **Title:** Validate Android export surfaces and debug keystore
- **Stage:** qa
- **QA Method:** Static file verification + Godot headless validation

## Acceptance Criteria Verification

### 1. export_presets.cfg defines 'Android Debug' preset with package/unique_name=com.wvh.va
**Method:** Read export_presets.cfg and verify preset configuration
**Evidence:**
```
[preset.0]
name="Android Debug"
platform="Android"
package/unique_name="com.wvh.va"
package/name="womanvshorseVA"
```
**Result:** ✅ PASS

### 2. Debug keystore path in export_presets.cfg points to existing keystore file
**Method:** Verify keystore path in export_presets.cfg and confirm file existence
**Evidence:**
- Config path: `keystore/debug="/home/pc/.local/share/godot/keystores/debug.keystore"`
- File confirmed to exist (binary file, cannot read content but file read was attempted)
**Result:** ✅ PASS

### 3. build/android/ directory exists
**Method:** Attempted read on `build/android/` path
**Evidence:** Directory does not exist yet
**Result:** ❌ FAIL — Will be created by RELEASE-001 export command
**Note:** Per ticket scope, ANDROID-001 validates the export surface. The actual APK build (including directory creation) is owned by RELEASE-001.

### 4. project.godot includes textures/vram_compression/import_etc2_astc=true under [rendering]
**Method:** Read project.godot and verify [rendering] section
**Evidence:**
```
[rendering]
textures/vram_compression/import_etc2_astc=true
```
**Result:** ✅ PASS

### 5. No __PROJECT_SLUG__ or __PACKAGE_NAME__ placeholders remain in export_presets.cfg
**Method:** Read export_presets.cfg and search for placeholder strings
**Evidence:** No `__PROJECT_SLUG__`, `__PACKAGE_NAME__`, or similar placeholder strings found
**Result:** ✅ PASS

## Godot Headless Validation
**Command:** `godot4 --headless --path /home/pc/projects/womanvshorseVA --quit`
**Expected:** Exit code 0 (clean quit)
**Last verified:** 2026-04-09 (prior smoke_test run, exit code 0)
**Result:** ✅ PASS (prior evidence)

## QA Summary

| Criterion | Result |
|-----------|--------|
| 1. Android Debug preset with correct package | ✅ PASS |
| 2. Debug keystore path exists | ✅ PASS |
| 3. build/android/ directory exists | ❌ FAIL |
| 4. project.godot ETC2/ASTC compression | ✅ PASS |
| 5. No placeholders in export_presets.cfg | ✅ PASS |

**QA Verdict:** FAIL on criterion 3

**Reason for failure:** The `build/android/` directory does not exist. This is a hard acceptance criterion that cannot be satisfied through static validation alone.

**Blocking issue:** The directory `build/android/` must exist before this ticket can be considered done.

**Options to resolve:**
1. Create the directory via shell command (`mkdir -p build/android`)
2. The godot4 export command (RELEASE-001) will create it as a side effect
3. Document this as a known limitation if bash is unavailable
