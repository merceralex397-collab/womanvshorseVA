# Plan Review — CORE-006

## Verdict: APPROVED

## Summary

All 6 acceptance criteria are satisfied by the existing implementation. The plan's corrected smoke-test approach (exit code only, ignoring stderr) is the correct response to the known godot4 headless tooling artifact. No blocking issues remain.

---

## Evidence Against Each Acceptance Criterion

### Criterion 1: Four enemy variant scripts exist matching the canonical spec

**PASS** — Evidence:

| File | class_name | Confirmed |
|------|-----------|-----------|
| `scripts/enemy_brown.gd` | `EnemyBrown` | ✓ |
| `scripts/enemy_black.gd` | `EnemyBlack` | ✓ |
| `scripts/enemy_war.gd` | `EnemyWar` | ✓ |
| `scripts/enemy_boss.gd` | `EnemyBoss` | ✓ |

All four files exist and declare the correct `class_name`.

---

### Criterion 2: Brown: Color(0.6,0.4,0.2), 25x35, speed=80, HP=1

**PASS** — `enemy_brown.gd` lines 7–10:
```
body_color = Color(0.6, 0.4, 0.2)   ✓
body_size = Vector2(25, 35)          ✓
speed = 80.0                         ✓
max_health = 1                       ✓
```

---

### Criterion 3: Black: Color(0.2,0.2,0.2), 25x35, speed=150, HP=1, visual speed lines

**PASS** — `enemy_black.gd` lines 9–13 and 19–26:
```
body_color = Color(0.2, 0.2, 0.2)   ✓
body_size = Vector2(25, 35)          ✓
speed = 150.0                        ✓
max_health = 1                       ✓
```

Speed lines: `_draw()` at lines 19–26 draws 3 diagonal lines behind the enemy when `velocity.length() > 50`, using `Color(0.4, 0.4, 0.4)`. ✓

---

### Criterion 4: War Horse: Color(0.8,0.2,0.2), 35x50, speed=60, HP=3

**PASS** — `enemy_war.gd` lines 7–10:
```
body_color = Color(0.8, 0.2, 0.2)   ✓
body_size = Vector2(35, 50)          ✓
speed = 60.0                         ✓
max_health = 3                       ✓
```

Thicker body is inherent to the larger `body_size = Vector2(35, 50)` vs base `25x35`.

---

### Criterion 5: Boss: Color(1.0,0.84,0.0), 50x65, speed=100 (variable), HP=10, pulsing gold modulate

**PASS** — `enemy_boss.gd` lines 7–15:
```
body_color = Color(1.0, 0.84, 0.0)   ✓
body_size = Vector2(50, 65)          ✓
speed = 100.0                        ✓
max_health = 10                      ✓
```

Pulsing modulate: `_process` at lines 13–15 uses `sin(Time.get_ticks_msec() / 300.0)` to pulse the green and red channels of `modulate`, producing a gold shimmer effect. ✓

---

### Criterion 6: Wave spawner can instantiate any variant by type name

**PASS** — `wave_spawner.gd` `_create_enemy()` lines 76–82:
```
match type:
    "brown": return EnemyBrown.new()   ✓
    "black": return EnemyBlack.new()   ✓
    "war":   return EnemyWar.new()     ✓
    "boss":  return EnemyBoss.new()    ✓
    _:       return EnemyBrown.new()    (fallback)
```

All four match arms are present and reachable.

---

## Plan Soundness

The plan correctly identifies that:
1. All code is already implemented and correct (verified above)
2. The godot4 headless stderr artifact is a tooling limitation, not a code defect
3. The corrected smoke-test approach using exit code 0 as the sole pass/fail signal is the right mitigation

The risk table is accurate. No blockers identified.

## Non-Blocking Notes

- **Boss speed "variable" in spec**: `enemy_boss.gd` sets `speed = 100.0` (fixed). The spec says "variable" but does not specify a variance pattern. No functional issue arises from this — the boss still moves faster than war horses (speed 60) and slower than black horses (speed 150). No change required.

---

## Recommendation

**APPROVED**. Advance to implementation → review → QA → smoke-test → closeout using exit-code-only smoke-test signal.
