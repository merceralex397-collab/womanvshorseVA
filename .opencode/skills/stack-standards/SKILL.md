---
name: stack-standards
description: Godot 4.6 Android game standards — GDScript conventions, validation commands, export configuration, and quality gates for this repo.
---

# Stack Standards — Godot 4.6 Android

Before applying these rules, call `skill_ping` with `skill_id: "stack-standards"` and `scope: "project"`.

Current stack: `Godot 4.6 — GDScript — Android export`

## Language and Framework

- **Engine**: Godot 4.6 (GDScript only, no C# or GDExtension)
- **Target**: Android APK (landscape, touch controls)
- **Art pipeline**: Procedural (see `procedural-art` skill). No imported image/audio assets.
- **Scene architecture**: Single main scene with state machine (Title → Playing → GameOver)

## GDScript Quality Rules

- Use static typing on all function signatures and member variables
- Use `@export`, `@onready`, `class_name` (Godot 4.x syntax, not Godot 3.x)
- Prefix private members with `_`
- Use `snake_case` for files, functions, variables; `PascalCase` for classes; `UPPER_SNAKE_CASE` for constants
- Document every public function and exported variable with `##` doc comments
- Keep scripts under 300 lines; extract helpers into separate scripts when they grow

## Quality Gate Commands

These are the canonical validation commands for this project:

```bash
# 1. Project load check (verifies project.godot parses and imports resolve)
godot4 --headless --quit

# 2. GDScript syntax check (run on each .gd file)
godot4 --headless --check-only --script res://scripts/main.gd

# 3. Scene load check (verifies .tscn references resolve)
godot4 --headless --quit --path .

# 4. Debug APK build (full export validation)
godot4 --headless --export-debug "Android Debug" build/android/womanvshorseva-debug.apk
```

When `godot4` is not available in the environment, fall back to:
```bash
# Syntax-level validation using GDScript parser
grep -rn "extends\|class_name\|func " scripts/ --include="*.gd"
# File reference integrity check
grep -rn 'load("\|preload("' scripts/ --include="*.gd" | while read line; do
  path=$(echo "$line" | grep -oP 'res://[^"]+')
  [ -n "$path" ] && [ ! -f "${path#res://}" ] && echo "MISSING: $path in $line"
done
```

## Key Configuration Files

| File | Purpose | Pitfalls |
|------|---------|----------|
| `project.godot` | Engine config, window size, stretch mode | Must set landscape orientation and canvas_items stretch |
| `export_presets.cfg` | Android export preset | Must reference valid keystore or use debug signing |
| `scenes/main.tscn` | Root scene | Must be set as main scene in project.godot |

## Android Export Pitfalls

- The `export_presets.cfg` preset name must match the export command exactly (e.g., `"Android Debug"`)
- Debug signing works without a keystore; release signing requires one
- `build/android/` directory must exist before export (create with `mkdir -p`)
- Android export templates must be installed on the build machine

## Dependency Policy

- **Zero external dependencies.** This project uses only the Godot engine.
- No GDScript addons, no asset packs, no third-party plugins
- All visuals are procedurally generated (see `procedural-art` skill)

## Process Rules

- Use ticket tools to track work; do not silently advance stages without updating ticket state
- Artifacts produced by each stage must be registered via `artifact_write` / `artifact_register`
- Smoke tests run against the actual APK export or `godot4 --headless` project load, not mocked surrogates
- Include raw command output in all implementation and QA artifacts
