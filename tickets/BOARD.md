# Ticket Board

| ID | Title | Wave | Lane | Stage | Status | Depends On |
| --- | --- | --- | --- | --- | --- | --- |
| SETUP-001 | Create main scene with arena | 0 | scene-foundation | planning | todo | — |
| SETUP-002 | Create player character with movement and virtual joystick | 0 | player-foundation | planning | todo | SETUP-001 |
| CORE-001 | Implement attack system (melee arc + ranged projectile) | 1 | combat-system | planning | todo | SETUP-002 |
| CORE-002 | Create enemy horse base class with charge behavior | 1 | enemy-system | planning | todo | SETUP-001 |
| CORE-003 | Implement wave spawner with escalating difficulty | 1 | wave-system | planning | todo | CORE-002 |
| CORE-004 | Create HUD with health hearts, wave counter, and score | 1 | ui-hud | planning | todo | SETUP-001 |
| CORE-005 | Implement collision and damage system | 2 | combat-system | planning | todo | CORE-001, CORE-002 |
| CORE-006 | Create enemy variants (brown, black, war horse, boss) | 2 | enemy-system | planning | todo | CORE-002 |
| UI-001 | Title screen scene | 2 | ui-screens | planning | todo | SETUP-001 |
| UI-002 | Game over screen with score and restart | 2 | ui-screens | planning | todo | SETUP-001 |
| POLISH-001 | Add particle effects for combat feedback | 3 | visual-polish | planning | todo | CORE-005 |
| RELEASE-001 | Configure Android export and build debug APK | 4 | release-readiness | planning | todo | CORE-003, CORE-005, UI-001, UI-002 |
