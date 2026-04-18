# Environment Bootstrap

## Ticket

- FINISH-VALIDATE-001

## Overall Result

Overall Result: PASS

## Environment Fingerprint

- 12d507bb276a4f811b7afa4797c4dc107149839bc904e07f38e207a3fdcbc1a5

## Fingerprint Inputs

- input_files: .opencode/meta/asset-pipeline-bootstrap.json, android/scafforge-managed.json, export_presets.cfg, opencode.jsonc, project.godot
- repo_surface.project_godot: present
- repo_surface.export_presets: present
- repo_surface.android_support_surface: present
- repo_surface.asset_pipeline_metadata: present
- repo_surface.opencode_config: present
- env.JAVA_HOME: /usr/lib/jvm/java-17-openjdk-amd64
- env.ANDROID_HOME: /home/rowan/Android/Sdk
- env.ANDROID_SDK_ROOT: <unset>
- env.BLENDER_MCP_BLENDER_EXECUTABLE: <unset>
- host_path.android_debug_keystore: /home/rowan/.android/debug.keystore
- host_path.godot_export_templates: /home/rowan/.local/share/godot/export_templates
- host_path.android_sdk_default: /home/rowan/Android/Sdk

## Stack Detections

### godot

- indicator_files: project.godot, export_presets.cfg
- missing_executables: none
- missing_env_vars: none
- warnings: none

## Missing Prerequisites

- None

## Blockers

- None

## Warnings

- None

## Notes

Dependency installation and bootstrap verification completed successfully in bootstrap-recovery mode.

## Commands

### 1. godot4 headless version

- reason: Verify the Godot runtime is available for headless validation.
- command: `godot4 --headless --version`
- exit_code: 0
- duration_ms: 70
- missing_executable: none
- failure_classification: none
- blocked_by_permissions: false

#### stdout

~~~~text
4.6.1.stable.official.14d19694e
~~~~

#### stderr

~~~~text
<no output>
~~~~
