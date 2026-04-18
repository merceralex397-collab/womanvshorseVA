# Environment Bootstrap

## Ticket

- FINISH-VALIDATE-001

## Overall Result

Overall Result: PASS

## Environment Fingerprint

- fd88844daffe550d1fc0a3a111ac84c3be073b143f5f5074c83203d5a2fe67e2

## Fingerprint Inputs

- input_files: .opencode/meta/asset-pipeline-bootstrap.json, android/scafforge-managed.json, export_presets.cfg, opencode.jsonc, project.godot
- repo_surface.project_godot: present
- repo_surface.export_presets: present
- repo_surface.android_support_surface: present
- repo_surface.asset_pipeline_metadata: present
- repo_surface.opencode_config: present
- env.JAVA_HOME: /usr/lib/jvm/java-17-openjdk-amd64
- env.ANDROID_HOME: /home/rowan/Android/Sdk
- env.ANDROID_SDK_ROOT: /home/rowan/Android/Sdk
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

Dependency installation and bootstrap verification completed successfully.

## Commands

### 1. godot4 headless version

- reason: Verify the Godot runtime is available for headless validation.
- command: `godot4 --headless --version`
- exit_code: 0
- duration_ms: 19
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
