# Environment Bootstrap

## Ticket

- FINISH-VALIDATE-001

## Overall Result

Overall Result: FAIL

## Environment Fingerprint

- ee297f3cb60eaf3746abe9cbb09673ba205c854494df50391931cb5886e156ee

## Fingerprint Inputs

- input_files: .opencode/meta/asset-pipeline-bootstrap.json, android/scafforge-managed.json, export_presets.cfg, opencode.jsonc, project.godot
- repo_surface.project_godot: present
- repo_surface.export_presets: present
- repo_surface.android_support_surface: present
- repo_surface.asset_pipeline_metadata: present
- repo_surface.opencode_config: present
- env.JAVA_HOME: <unset>
- env.ANDROID_HOME: <unset>
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

- JAVA_HOME

## Blockers

- JAVA_HOME: JAVA_HOME is not set. Godot's Android Gradle build requires JAVA_HOME (not just java in PATH). Run: export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))) && echo $JAVA_HOME | install_command: export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

## Warnings

- None

## Notes

Bootstrap failed because required bootstrap prerequisites are missing: JAVA_HOME. Resolve the blockers or surface them to the user before implementation.

## Commands

No executable bootstrap commands were eligible to run.
