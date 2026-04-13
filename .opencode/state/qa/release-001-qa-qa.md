# QA Verification — RELEASE-001

**Ticket**: RELEASE-001 — Configure Android export and build debug APK  
**Stage**: QA  
**Lane**: release-readiness  
**QA Agent**: wvhva-tester-qa  
**Date**: 2026-04-10T11:35:16Z

---

## Checks Run

1. Verified export_presets.cfg for "Android Debug" preset configuration
2. Verified project.godot for ETC2/ASTC texture compression setting
3. Verified build/android/ directory and APK file existence
4. Executed godot4 --headless --export-debug command
5. Verified APK file size
6. Checked godot4 availability as environment prerequisite

---

## Acceptance Criteria Results

| # | Criterion | Result | Evidence |
|---|-----------|--------|----------|
| 1 | export_presets.cfg has 'Android Debug' preset with valid configuration | **PASS** | `name="Android Debug"` at line 6; `package/unique_name="com.wvh.va"` at line 38; `export_path="build/android/womanvshorseVA-debug.apk"` at line 14 |
| 2 | project.godot includes `textures/vram_compression/import_etc2_astc=true` under `[rendering]` | **PASS** | Line 16: `textures/vram_compression/import_etc2_astc=true` |
| 3 | build/android/ directory exists | **PASS** | Directory confirmed; APK file present at `build/android/womanvshorseVA-debug.apk` |
| 4 | godot4 --headless --export-debug produces an APK | **PASS** | Command executed with exit code 0: `godot4 --headless --export-debug "Android Debug" /home/pc/projects/womanvshorseVA/build/android/womanvshorseVA-debug.apk --path /home/pc/projects/womanvshorseVA` |
| 5 | APK file is non-zero size | **PASS** | APK size: **27,511,234 bytes** (~27 MB) |
| 6 | If godot4 unavailable, blocker documented | **N/A** | godot4 is available (version confirmed); export succeeded |

---

## Command Output

### godot4 availability check:
```
which godot4 → /usr/bin/godot4
godot4 --version → Godot Engine v4.6.2.official
```

### godot4 headless export:
```
Command: godot4 --headless --export-debug "Android Debug" /home/pc/projects/womanvshorseVA/build/android/womanvshorseVA-debug.apk --path /home/pc/projects/womanvshorseVA
Exit code: 0
```

### APK file:
```
-rw-r--r-- 1 pc pc 27511234 Apr 10 00:33 /home/pc/projects/womanvshorseVA/build/android/womanvshorseVA-debug.apk
```

---

## Blockers

**None.** All 6 acceptance criteria pass.

---

## Closeout Readiness

**READY.** RELEASE-001 has passed QA verification. All acceptance criteria satisfied:
- Android Debug export preset configured correctly with com.wvh.va package
- Texture compression enabled in project.godot
- APK successfully built via godot4 headless export (27 MB)
- All dependencies resolved and environment prerequisite met

The ticket is cleared to advance to smoke-test stage.
