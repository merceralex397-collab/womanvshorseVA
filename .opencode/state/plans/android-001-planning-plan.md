# Plan: ANDROID-001 — Validate Android export surfaces and debug keystore

## Verification Summary

### export_presets.cfg — ✅ VALID
- Preset name: "Android Debug" ✅
- package/unique_name="com.wvh.va" ✅
- package/name="womanvshorseVA" ✅
- keystore/debug="/home/pc/.local/share/godot/keystores/debug.keystore" ✅
- keystore/debug_user="androiddebugkey" ✅
- keystore/debug_password="android" ✅
- export_path="build/android/womanvshorseVA-debug.apk" ✅
- No __PROJECT_SLUG__ or __PACKAGE_NAME__ placeholders ✅

### project.godot — ✅ VALID
- textures/vram_compression/import_etc2_astc=true under [rendering] ✅

### build/android/ directory — TO CREATE
- mkdir -p build/android

### Debug keystore — ❌ MISSING
- Path: /home/pc/.local/share/godot/keystores/debug.keystore
- Status: MISSING
- Resolution needed: Generate debug keystore or update export_presets.cfg path

## Acceptance Criteria Status
| Criterion | Status |
|-----------|--------|
| export_presets.cfg 'Android Debug' preset with package=com.wvh.va | ✅ |
| Debug keystore path points to existing file | ❌ MISSING |
| build/android/ directory exists | TO CREATE |
| project.godot ETC2/ASTC texture compression | ✅ |
| No placeholder values in export_presets.cfg | ✅ |

## Next Steps
1. Create build/android/ directory
2. Generate debug keystore at expected path, OR update export_presets.cfg to point to an existing keystore
