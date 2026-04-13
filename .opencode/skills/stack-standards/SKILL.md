---
name: stack-standards
description: Hold the project-local standards for languages, frameworks, validation, and runtime assumptions. Use when planning or implementing work that should follow repo-specific engineering conventions.
---

# Stack Standards

Before applying these rules, call `skill_ping` with `skill_id: "stack-standards"` and `scope: "project"`.

Current scaffold mode: `framework-agnostic`

## Universal Engineering Standards

These rules apply to all work in this repository regardless of stack.

### Code Quality
- Write code for readability first; optimise only when profiled evidence justifies it.
- Keep functions and methods focused on a single responsibility; extract helpers when a unit exceeds a single screen of logic.
- Every public or exported symbol must have a documentation comment that describes intent, not implementation.
- Delete dead code instead of commenting it out; use version control to recover removed code.

### Quality Gate Commands

Use the smallest stack-appropriate command set that proves the code still builds, references resolve, and the test surface is callable.

For this Godot 4.6 project:
- Build check: `godot4 --headless --check-only`
- Scene reference checks: `godot4 --headless --doctool .` (generates reference docs, verifies scene links)
- Autoload validation: verify autoload scripts load without errors via `godot4 --headless --script res://autoload_check.gd` (custom script)
- Project load/import verification: `godot4 --headless --export-debug "Android Debug" --output /tmp/test.apk` (export attempt to verify project integrity)
- No separate lint or type-check; GDScript is dynamically typed, errors caught at runtime/load
- No test framework configured; smoke tests cover runtime behavior

### Validation
- All external inputs (API payloads, file reads, environment variables) must be validated at the boundary before use.
- Assertions and precondition checks belong at the call site, not buried in utility helpers.
- Write tests for correctness-critical paths; treat flaky tests as bugs to fix before merge.

### Dependencies
- Add a dependency only when it solves a problem the project cannot reasonably solve itself.
- Pin dependency versions in lock files; never rely on floating ranges in production builds.
- Audit new dependencies for license compatibility before adding them.

### Process
- Use ticket tools to track work; do not silently advance stages without updating ticket state.
- Artifacts produced by each stage must be registered via `artifact_write` / `artifact_register`.
- Smoke tests run on the real binary or export target, not on a mocked surrogate.

