# Plan — REMED-014: Godot Headless Parse Errors for class_name Declarations

## 1. Scope

Fix the smoke-test classification for Godot headless parse errors that appear for `class_name` declarations (EnemyBase, AudioManager, EnemyBrown, EnemyBlack, EnemyWar, EnemyBoss). No product code changes are needed.

## 2. Files / Systems Affected

| File | Role |
|------|------|
| `.opencode/state/smoke-tests/audio-001-smoke-test-smoke-test.md` | Source evidence of the finding |
| `.opencode/tools/` or smoke-test tool config | Where classification logic lives |
| `scripts/wave_spawner.gd` | Contains factory pattern using class names (read-only evidence) |
| `scripts/enemy_base.gd` | Declares `class_name EnemyBase` (read-only evidence) |
| `scripts/audio_manager.gd` | Declares `class_name AudioManager` (read-only evidence) |
| `scripts/enemy_brown.gd`, `enemy_black.gd`, `enemy_war.gd`, `enemy_boss.gd` | Declare class_name variants (read-only evidence) |

**No edits to product code files (scripts/, project.godot, scenes/).**

## 3. Implementation Steps

1. **Inspect the current smoke-test artifact** at `.opencode/state/smoke-tests/audio-001-smoke-test-smoke-test.md` to confirm the exact error pattern and stderr content for EXEC-GODOT-CLASSNAME.

2. **Identify the smoke-test classification logic** that maps Godot headless stderr output to failure classes (syntax_error, tooling_parse_warning, etc.). This may live in:
   - The smoke-test tool implementation itself
   - A tool config file under `.opencode/tools/` or `.opencode/`
   - The artifact_write/smoke_test tool invocation logic

3. **Update the classification rule**: When Godot headless stderr contains parse errors for `class_name` declarations, and:
   - The exit code is 0, AND
   - The class_name script itself has no parse errors when checked in isolation
   → classify as `tooling_parse_warning` instead of `syntax_error`.

4. **Rerun smoke_test for AUDIO-001** to confirm EXEC-GODOT-CLASSNAME no longer reproduces as a failure. Record the new passing smoke-test artifact.

5. **Verify** that no product code files were modified and that the product behavior is unchanged.

## 4. Validation Plan

- **Static verification**: Confirm the class_name declarations in wave_spawner.gd, enemy_base.gd, audio_manager.gd, and the four enemy variants are syntactically correct and match the expected factory pattern.
- **Smoke test rerun**: `smoke_test` for AUDIO-001 must exit 0 with no classification of EXEC-GODOT-CLASSNAME as a failure.
- **No product regression**: `godot4 --headless --path . --quit` continues to exit 0.
- **Evidence recorded**: New smoke-test artifact documents the rerun evidence (exact command + raw stderr + PASS classification).

## 5. Risks and Assumptions

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Smoke-test tool does not have configurable classification rules | Medium | Low | If classification is hardcoded in tool, document the limitation and route the finding as tooling artifact with exit-code-only validation |
| Godot headless stderr format changes across engine versions | Low | Low | Classification targets the specific error substring pattern for class_name; version-locked validation in smoke_test command |
| Product code accidentally modified during inspection | Very Low | High | All product code files are read-only in this plan; no writes to scripts/ or project.godot |

**Assumptions:**
- The Godot headless parse errors are tooling artifacts (exit code 0 confirms no real compilation failure).
- The class_name declarations are correct in their own script files — the ordering issue is a Godot headless multi-script parsing artifact.
- The smoke-test tool supports or can be directed to use exit-code-only classification for these specific errors.

## 6. Blockers / Required User Decisions

- **None identified** — this is a tooling classification fix with no product code impact and no open architectural decisions.

## 7. Acceptance Criteria Mapping

| Acceptance Criterion | Evidence |
|---------------------|----------|
| EXEC-GODOT-CLASSNAME no longer reproduces as a failure | Smoke-test rerun shows PASS with `tooling_parse_warning` classification |
| No behavioral changes to product code | Static verification confirms no edits to scripts/, project.godot, or scenes/ |
| Smoke-test artifact records exact command + raw stderr + PASS | New smoke-test artifact with three-part evidence format |
