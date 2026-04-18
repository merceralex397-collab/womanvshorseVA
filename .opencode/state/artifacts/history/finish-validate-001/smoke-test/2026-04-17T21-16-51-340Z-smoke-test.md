# Smoke Test

## Ticket

- FINISH-VALIDATE-001

## Overall Result

Overall Result: FAIL

## Notes

The smoke-test run failed because the smoke-test surface is not configured correctly.

## Commands

### 1. command override 1

- reason: Explicit smoke-test command override supplied by the caller.
- command: `godot4 --headless --path . --quit`
- exit_code: 0
- duration_ms: 164
- missing_executable: none
- failure_classification: syntax_error
- blocked_by_permissions: false

#### stdout

~~~~text
Godot Engine v4.6.1.stable.official.14d19694e - https://godotengine.org
~~~~

#### stderr

~~~~text
SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase" from "res://scripts/enemy_base.gd".
          at: GDScript::reload (res://scripts/wave_spawner.gd:77)
SCRIPT ERROR: Parse Error: Could not parse global class "EnemyBase" from "res://scripts/enemy_base.gd".
          at: GDScript::reload (res://scripts/wave_spawner.gd:95)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBrown", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:79)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBlack", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:80)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyWar", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:81)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBoss", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:82)
SCRIPT ERROR: Parse Error: Could not resolve class "EnemyBrown", because of a parser error.
          at: GDScript::reload (res://scripts/wave_spawner.gd:83)
ERROR: Failed to load script "res://scripts/wave_spawner.gd" with error "Parse error".
   at: load (modules/gdscript/gdscript.cpp:2907)
~~~~
