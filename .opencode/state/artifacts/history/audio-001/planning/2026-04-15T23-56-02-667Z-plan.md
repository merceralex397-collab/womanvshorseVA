# Planning Artifact: AUDIO-001 — Own Ship-Ready Audio Finish

## Ticket
- **ID**: AUDIO-001
- **Title**: Own ship-ready audio finish
- **Lane**: finish-audio
- **Wave**: 8
- **Stage**: planning

## Summary
Deliver the declared user-facing audio bar: Minimal procedural/generated SFX. Background music optional.

---

## 1. Scope

### Goals
- Generate all SFX procedurally via GDScript using Godot 4.6 AudioStreamGenerator
- No external audio files (.wav, .mp3, .ogg)
- Target combat-critical SFX: attack, hit, enemy death, player damage
- Optional: wave start chime

### Non-Goals
- Background music (explicitly optional per canonical brief)
- Complex synthesized music or ambient sound
- Audio volume/mute controls (out of scope)

---

## 2. Files and Systems Affected

### New Files
| File | Purpose |
|------|---------|
| `scripts/audio_manager.gd` | Central procedural audio manager using AudioStreamGenerator |
| `scripts/sfx_player.gd` | Helper node for playing procedural SFX via AudioStreamPlayer |

### Modified Files
| File | Change |
|------|---------|
| `scripts/player.gd` | Emit attack sound on melee/ranged attack |
| `scripts/melee_arc.gd` | Emit hit sound when arc damages enemy |
| `scripts/projectile.gd` | Emit hit sound on projectile impact |
| `scripts/enemy_base.gd` | Emit enemy death sound on death |
| `scripts/player.gd` (take_damage) | Emit player damage sound |
| `scripts/wave_spawner.gd` | Emit wave start sound on new wave |
| `scenes/main.tscn` | Add AudioManager node to scene tree |

### Godot Engine Components
- `AudioStreamGenerator` — generates PCM audio from GDScript sample buffers
- `AudioStreamPlayer` — plays generated AudioStream
- `AudioStreamGeneratorPlayback` — interface for writing sample data

---

## 3. Implementation Steps

### Step 1: Create AudioManager (scripts/audio_manager.gd)
- Extend `Node` (autoload-singleton pattern or scene-launched node)
- Provide static helper functions:
  - `play_attack_sfx()` — short sine sweep (high→low), ~120ms
  - `play_hit_sfx()` — percussive noise burst, ~80ms
  - `play_death_sfx()` — descending sine tone, ~200ms
  - `play_player_hit_sfx()` — harsh buzz (square wave), ~180ms
  - `play_wave_start_sfx()` — ascending chime (sine), ~250ms (optional)
- Use `AudioStreamGenerator` with `AudioStreamGeneratorPlayback` to write PCM samples
- Generate sine waves: `sample = amplitude * sin(phase * 2π * frequency / sample_rate)`
- Generate square waves: `sample = amplitude * sign(sin(phase * 2π * frequency / sample_rate))`
- Add simple ADSR envelope (Attack-Decay-Sustain-Release) for cleaner sound
- Buffer size: 1024-2048 samples for mobile compatibility

### Step 2: Create SFXPlayer helper (scripts/sfx_player.gd)
- Helper node for one-shot SFX playback
- Attach to game entities that need to trigger sounds
- Simple API: `play(sfx_type: String)` or static calls via AudioManager

### Step 3: Integrate AudioManager into main scene
- Add `AudioManager` node to `scenes/main.tscn`
- Configure as singleton or child of main — either approach works for this scope

### Step 4: Wire attack sound to player attacks
- In `player.gd`, call `AudioManager.play_attack_sfx()` in `_on_melee_attack()` and `_on_ranged_attack()`

### Step 5: Wire hit sound to melee arc and projectile impacts
- In `melee_arc.gd`, call `AudioManager.play_hit_sfx()` in `_on_hit_enemy()`
- In `projectile.gd`, call `AudioManager.play_hit_sfx()` in `_on_hit_enemy()`

### Step 6: Wire enemy death sound
- In `enemy_base.gd`, call `AudioManager.play_death_sfx()` before `enemy_died.emit()` in `take_damage()`

### Step 7: Wire player damage sound
- In `player.gd`, call `AudioManager.play_player_hit_sfx()` in `take_damage()`

### Step 8: Wire wave start sound (optional)
- In `wave_spawner.gd`, call `AudioManager.play_wave_start_sfx()` after `wave_started.emit()` in `start_next_wave()`

### Step 9: Static verification
- Confirm no `.wav`, `.mp3`, or `.ogg` files exist in the project
- Confirm all audio is generated via GDScript AudioStreamGenerator
- Verify godot4 --headless --quit exits clean

---

## 4. Validation Plan

### Static Verification Checklist
- [ ] No external audio files (.wav, .mp3, .ogg) in project
- [ ] `scripts/audio_manager.gd` exists with `AudioStreamGenerator` usage
- [ ] Attack sound wired to `player.gd` melee and ranged attacks
- [ ] Hit sound wired to `melee_arc.gd` and `projectile.gd` impacts
- [ ] Death sound wired to `enemy_base.gd` death path
- [ ] Player damage sound wired to `player.gd.take_damage()`
- [ ] Wave start sound wired to `wave_spawner.gd` (if implemented)
- [ ] All functions use static typing

### Smoke Test
- `godot4 --headless --path . --quit` exits with code 0

### Acceptance Criteria Mapping
| Criterion | Evidence |
|-----------|----------|
| Audio finish target met | AudioManager generates all SFX procedurally via AudioStreamGenerator |
| No placeholder/missing audio | Static verification confirms no external audio files; all sounds are generated in-code |

---

## 5. Risks and Assumptions

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Audio latency on mobile | Low | Medium | Keep sounds short (≤250ms); use small buffer sizes |
| AudioStreamGenerator CPU overhead | Low | Low | Sample generation is simple math; minimal CPU cost |
| Missing audio on first frame | Low | Low | AudioManager node ready before game entities spawn |
| Godot headless audio limitations | Low | Informational | Smoke test uses `--quit` only; audio playback not testable headless |

### Assumptions
- Godot 4.6 `AudioStreamGenerator` and `AudioStreamGeneratorPlayback` APIs are stable
- Mobile audio latency is acceptable for short SFX
- No audio file format or encoding issues (since no files are used)

---

## 6. Decision Blockers

**None identified.** The approach is technically straightforward using Godot 4.6's built-in audio generation APIs. Background music being optional removes the need for more complex audio infrastructure.

---

## 7. Technical Notes

### Godot 4.6 Procedural Audio Approach

**AudioStreamGenerator** generates audio from PCM sample buffers. The pattern:

```
1. Create AudioStreamGenerator resource
2. Create AudioStreamPlayer and set its stream to the generator
3. Get AudioStreamGeneratorPlayback via player.get_stream_playback()
4. Write samples: playback.push_frame(PackedVector2Array([left, right]))
```

**Sample Generation Math:**
- Sine wave: `sin(phase * 2π * frequency / sample_rate)`
- Square wave: `sign(sin(...))` with gain
- Noise: `randf() * 2 - 1` (uniform noise) or `randfn()` (Gaussian)
- Envelope: interpolate amplitude over sample count

**Mobile Considerations:**
- Buffer sizes of 1024–2048 samples work well
- Keep total sound duration under 300ms for responsive feel
- Mono is sufficient for SFX (can be mixed to stereo in playback)
