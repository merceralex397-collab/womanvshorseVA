# Ticket Board

| Wave | ID | Title | Lane | Stage | Status | Resolution | Verification | Parallel Safe | Overlap Risk | Depends On | Follow-ups |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | SETUP-001 | Create main scene with arena | scene-foundation | closeout | done | done | trusted | no | high | - | - |
| 0 | SETUP-002 | Create player character with movement and virtual joystick | player-foundation | closeout | done | done | trusted | no | medium | SETUP-001 | - |
| 1 | CORE-001 | Implement attack system (melee arc + ranged projectile) | combat-system | closeout | done | done | trusted | no | medium | SETUP-002 | - |
| 1 | CORE-002 | Create enemy horse base class with charge behavior | enemy-system | closeout | done | done | trusted | yes | low | SETUP-001 | - |
| 1 | CORE-003 | Implement wave spawner with escalating difficulty | wave-system | closeout | done | done | reverified | no | medium | CORE-002 | - |
| 1 | CORE-004 | Create HUD with health hearts, wave counter, and score | ui-hud | closeout | done | done | reverified | yes | low | SETUP-001 | - |
| 1 | ANDROID-001 | Validate Android export surfaces and debug keystore | android-export | closeout | done | done | reverified | yes | low | SETUP-001 | - |
| 2 | CORE-005 | Implement collision and damage system | combat-system | closeout | done | done | reverified | no | medium | CORE-001, CORE-002 | - |
| 2 | CORE-006 | Create enemy variants (brown, black, war horse, boss) | enemy-system | closeout | done | done | reverified | yes | low | CORE-002 | - |
| 2 | UI-001 | Title screen scene | ui-screens | closeout | done | done | reverified | yes | low | SETUP-001 | - |
| 2 | UI-002 | Game over screen with score and restart | ui-screens | closeout | done | done | reverified | yes | low | SETUP-001 | - |
| 3 | POLISH-001 | Add particle effects for combat feedback | visual-polish | closeout | done | done | reverified | yes | low | CORE-005 | - |
| 4 | RELEASE-001 | Build Android runnable proof (debug APK) | release-readiness | closeout | done | done | trusted | no | medium | FINISH-VALIDATE-001 | - |
| 5 | REMED-001 | Remediation review artifact does not contain runnable command evidence | remediation | closeout | done | done | trusted | no | low | - | - |
| 6 | REMED-002 | Remediation review artifact does not contain runnable command evidence | remediation | closeout | done | done | trusted | no | low | - | REMED-012, REMED-013 |
| 7 | VISUAL-001 | Own ship-ready visual finish | finish-visual | closeout | done | done | trusted | no | medium | SETUP-001 | - |
| 8 | AUDIO-001 | Own ship-ready audio finish | finish-audio | closeout | done | done | trusted | no | medium | SETUP-001 | - |
| 9 | FINISH-VALIDATE-001 | Validate product finish contract | finish-validation | closeout | done | done | trusted | no | medium | VISUAL-001, AUDIO-001 | - |
| 10 | REMED-003 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 11 | REMED-004 | Remediation review artifact does not contain runnable command evidence | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 12 | REMED-005 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 13 | REMED-006 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 14 | REMED-007 | GDScript calls APIs that are unavailable on the script's declared base type | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 15 | REMED-008 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 16 | REMED-009 | GDScript calls APIs that are unavailable on the script's declared base type | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 17 | REMED-010 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 18 | REMED-011 | GDScript calls APIs that are unavailable on the script's declared base type | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 19 | REMED-012 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | done | trusted | no | low | - | - |
| 20 | REMED-013 | GDScript calls APIs that are unavailable on the script's declared base type | remediation | closeout | done | done | reverified | no | low | - | - |
| 21 | REMED-014 | Godot headless parse errors for class_name declarations (EnemyBase, AudioManager, EnemyBrown/Black/War/Boss) | remediation | closeout | done | done | trusted | no | low | - | - |
| 22 | REMED-015 | smoke_test tool classifies Godot class_name reload parse errors as syntax_error despite exit 0 | remediation | closeout | done | done | trusted | no | low | - | - |
| 23 | REMED-016 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 24 | REMED-017 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | superseded | reverified | no | low | - | - |
| 25 | REMED-018 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | superseded | reverified | no | low | - | REMED-019 |
| 26 | REMED-019 | Godot release smoke artifact reports PASS despite recorded runtime or command-failure evidence | remediation | closeout | done | done | trusted | no | low | - | - |
