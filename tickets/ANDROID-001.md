# ANDROID-001: Validate Android export surfaces and debug keystore

## Summary

Validate export_presets.cfg has correct Android Debug preset with real values (package com.wvh.va, slug womanvshorseVA). Confirm debug keystore at /home/pc/.local/share/godot/keystores/debug.keystore is valid (pass: android, alias: androiddebugkey). Create build/android/ output directory. Verify project.godot has ETC2/ASTC texture compression enabled. This ticket owns the export surface; RELEASE-001 owns the actual APK build.

## Wave

1

## Lane

android-export

## Parallel Safety

- parallel_safe: true
- overlap_risk: low

## Stage

closeout

## Status

done

## Trust

- resolution_state: done
- verification_state: reverified
- finding_source: None
- source_ticket_id: None
- source_mode: None

## Depends On

SETUP-001

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] export_presets.cfg defines 'Android Debug' preset with package/unique_name=com.wvh.va
- [ ] Debug keystore path in export_presets.cfg points to existing keystore file
- [ ] build/android/ directory exists
- [ ] project.godot includes textures/vram_compression/import_etc2_astc=true under [rendering]
- [ ] No __PROJECT_SLUG__ or __PACKAGE_NAME__ placeholders remain in export_presets.cfg

## Artifacts

- plan: .opencode/state/artifacts/history/android-001/planning/2026-04-09T23-26-26-591Z-plan.md (planning) - Plan for ANDROID-001: export_presets.cfg and project.godot validated. Debug keystore is missing - needs creation or path update.
- implementation: .opencode/state/artifacts/history/android-001/implementation/2026-04-09T23-30-12-327Z-implementation.md (implementation) - Implementation for ANDROID-001: Static validation of export_presets.cfg, project.godot, debug keystore. All checks pass. build/android/ will be created by RELEASE-001 export command.
- review: .opencode/state/artifacts/history/android-001/review/2026-04-09T23-30-55-007Z-review.md (review) - Code review APPROVED for ANDROID-001. 4/5 acceptance criteria fully met. Criterion 3 (build/android/ directory) deferred to RELEASE-001 export command. Static validation of export_presets.cfg, project.godot, and debug keystore all pass.
- qa: .opencode/state/artifacts/history/android-001/qa/2026-04-09T23-31-44-571Z-qa.md (qa) - QA verification for ANDROID-001: 4/5 acceptance criteria pass. Criterion 3 (build/android/ directory) fails — directory does not exist yet. Review artifact approved with this deferred to RELEASE-001 export command.
- smoke-test: .opencode/state/artifacts/history/android-001/smoke-test/2026-04-09T23-32-33-555Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- smoke-test: .opencode/state/artifacts/history/android-001/smoke-test/2026-04-09T23-32-45-987Z-smoke-test.md (smoke-test) [superseded] - Deterministic smoke test failed.
- smoke-test: .opencode/state/artifacts/history/android-001/smoke-test/2026-04-09T23-33-25-319Z-smoke-test.md (smoke-test) - Deterministic smoke test passed.
- backlog-verification: .opencode/state/artifacts/history/android-001/review/2026-04-10T11-21-42-600Z-backlog-verification.md (review) - Backlog verification PASS — all 5 acceptance criteria satisfied, APK successfully built and signed at build/android/womanvshorseVA-debug.apk, smoke test exit code 0. QA FAIL on criterion 3 was a timing artifact resolved by smoke test. Trust restored. No reopening or rollback needed.
- reverification: .opencode/state/artifacts/history/android-001/review/2026-04-10T11-22-01-550Z-reverification.md (review) [superseded] - Trust restored using ANDROID-001.
- reverification: .opencode/state/artifacts/history/android-001/review/2026-04-10T11-25-23-225Z-reverification.md (review) - Trust restored using ANDROID-001.

## Notes


