---
name: stack-standards
description: Hold the project-local standards for languages, frameworks, validation, and runtime assumptions. Use when planning or implementing work that should follow repo-specific engineering conventions.
---

# Stack Standards

Before applying these rules, call `skill_ping` with `skill_id: "stack-standards"` and `scope: "project"`.

This repository is a Godot 4.6 Android action game with procedural 2D visuals and touch-only controls. The product target is a debug APK that launches a single-scene wave-combat game where all art remains programmatic GDScript output rather than imported asset files.

## Project Stack

- Engine: Godot 4.6
- Runtime target: Android landscape export
- Main config: `project.godot`
- Export config: `export_presets.cfg`
- Canonical debug APK path: `build/android/womanvshorseVA-debug.apk`
- Gameplay architecture: single-scene flow (`Title -> Playing -> GameOver`)
- Content route: procedural sprites and UI only; no external art pipeline or committed asset dependency

## Godot and Gameplay Rules

- Keep gameplay code compatible with Godot 4.6 and the current `project.godot` feature set.
- Preserve the touch-first Android design: left-half virtual joystick, right-half attack controls, landscape orientation.
- Keep the game procedurally rendered. Final visuals are colored-shape GDScript output, not placeholder textures or imported character art.
- Treat `project.godot`, `export_presets.cfg`, `.gd`, `.tscn`, `.tres`, and Android export surfaces as first-class review targets.
- Do not add online features, save systems, IAP, narrative systems, or non-touch control schemes without a canonical-brief change.

## Validation Commands

Use the smallest command set that proves the touched surface with current evidence.

- Project load / import check: `godot4 --headless --path . --quit`
- Android debug export: `godot4 --headless --path . --export-debug "Android Debug" build/android/womanvshorseVA-debug.apk`
- APK existence check: `test -f build/android/womanvshorseVA-debug.apk`
- APK content check: `unzip -l build/android/womanvshorseVA-debug.apk`

If Godot, Android SDK, Java, export templates, or the debug keystore are unavailable, return an explicit host-prerequisite blocker. Do not turn an unrun command into PASS evidence.

## Review and QA Gates

- Review must inspect the exact Godot, workflow, or ticket files changed by the ticket.
- QA must rerun the ticket's canonical Godot or export command when host prerequisites are present.
- Remediation tickets with `finding_source` must rerun the original finding-producing check or the exact acceptance command named by the finding before approval.
- `smoke_test` is the only legal producer of smoke-test artifacts.
- If `godot4 --headless --path . --quit` fails, the repo remains blocked on project-load repair or an explicit environment blocker.
- If the Android export command fails, release-proof tickets remain open.

## Release Proof

`RELEASE-001` is not complete until:

- `export_presets.cfg` still contains the Android Debug preset with export path `build/android/womanvshorseVA-debug.apk`
- `godot4 --headless --path . --export-debug "Android Debug" build/android/womanvshorseVA-debug.apk` succeeds or records an explicit environment blocker
- `build/android/womanvshorseVA-debug.apk` exists
- `unzip -l build/android/womanvshorseVA-debug.apk` shows Android package contents
- current trusted evidence shows touch controls, waves, scoring, game-over, and restart flow all work on the shipped build path

## Coding Standards

- Prefer small focused GDScript nodes and helpers over one oversized gameplay script.
- Keep runtime behavior deterministic enough for headless load checks and repeatable smoke evidence.
- Validate node paths, exported values, and scene references at the boundary before use.
- Remove dead placeholder logic once the final procedural behavior exists; do not keep fallback stubs just to satisfy an old artifact.
- Use ticket tools plus artifact registration for workflow state; do not advance queue state through raw file edits.
