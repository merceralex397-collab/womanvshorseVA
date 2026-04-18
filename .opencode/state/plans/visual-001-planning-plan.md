# Planning Artifact — VISUAL-001: Own Ship-Ready Visual Finish

## 1. Scope

Assess the current procedural visual surfaces against the declared ship bar ("2D top-down view with procedural sprites. Clean, readable gameplay. Inspired by Codex game-studio patterns.") and deliver any concrete polish needed to meet that bar before finish-validation.

**In scope:**
- Inspect all user-facing visual surfaces (player, enemies, HUD, arena, title/game-over, attacks, particles)
- Identify any prototype-grade or throwaway visual残留 (circles pretending to be hearts, outline-only arcs, bare solid colors with no animation)
- Apply targeted polish that raises visual fidelity to the Codex-inspired ship bar without changing gameplay mechanics
- Verify no placeholder assets remain

**Out of scope:**
- Gameplay changes
- New game systems
- Audio (owned by AUDIO-001)
- Structural code changes

---

## 2. Files and Systems Affected

| File | Visual Element | Change Type |
|------|--------------|-------------|
| `scripts/hud.gd` | Health hearts (`_draw()`) | Polish: upgrade circles to heart silhouettes |
| `scripts/main.gd` | Arena background and border | Polish: add subtle floor grid or texture |
| `scripts/melee_arc.gd` | Attack arc visual | Polish: fill the arc sector instead of outline-only |
| `scripts/enemy_base.gd` | Enemy hurt flash | Polish: ensure consistent white-flash timing |
| `scripts/enemy_war.gd` | War horse visual | Polish: add thicker body outline or darker shade differentiation |
| `scripts/enemy_boss.gd` | Boss pulse | Polish: amplify pulse (larger scale or brightness swing) |
| `scripts/title_screen.gd` | Title screen | Polish: add subtle procedural decorative element (e.g., line divider) |
| `scripts/game_over_screen.gd` | Game over screen | Polish: add subtle procedural decorative element |

No external assets. All changes use Godot `_draw()`, `Polygon2D`, or `ColorRect` only.

---

## 3. Implementation Steps

### Step 1: Inspect and Gap-Analysis (READ-ONLY)
Review all visual surfaces listed above. Confirm no placeholder or throwaway art remains. Document specific visual gaps against the Codex-inspired ship bar.

**Deliverable:** Gap list with priority (see Section 4).

### Step 2: HUD Heart Polish
- Change `_draw()` heart shapes from simple circles to actual heart silhouettes using `draw_circle` + `draw_rect` composition or a `PackedVector2Array` polygon
- Keep red/grey dual-color scheme
- Keep same positioning and sizing

### Step 3: Arena Background Polish
- Add a subtle grid or dot-pattern floor drawn via `_draw()` in `main.gd`
- Use a color slightly lighter than `BACKGROUND_COLOR` for contrast
- Keep border as-is

### Step 4: Melee Arc Polish
- Change from outline-only `draw_arc()` to a filled `draw_colored_polygon()` sector
- Semi-transparent white fill (alpha ~0.4) still fades to 0 — same timing

### Step 5: War Horse Visual Distinction
- Add a darker stroke/outline on War Horse body via `_draw()` in `enemy_war.gd` (override `_create_visual` or add a second Polygon2D outline)
- Or darken the body color slightly to differentiate from base enemy visually

### Step 6: Boss Pulse Amplification
- Expand boss modulate pulse range to include slight scale pulsing (`scale` vector) in addition to color
- Keep the existing sine-wave pattern; just add scale dimension

### Step 7: Title/Game-Over Polish
- Add a thin horizontal decorative line (via `_draw()`) between title text and button on both screens
- Use white with low alpha

### Step 8: Godot Headless Validation
- Run `godot4 --headless --path . --quit` to confirm no script errors introduced by visual changes
- Record exit code as proof

---

## 4. Validation Plan

### Static Verification Checklist

| # | Check | Method |
|---|-------|--------|
| 1 | HUD hearts are heart-shaped, not circles | Inspect `hud.gd` `_draw()` for heart polygon |
| 2 | Arena has subtle floor texture/grid | Inspect `main.gd` `_draw()` for grid/dot pattern |
| 3 | Melee arc is filled sector, not outline | Inspect `melee_arc.gd` `_draw()` for `draw_colored_polygon` |
| 4 | War horse visually distinct from base enemy | Inspect `enemy_war.gd` body/outline |
| 5 | Boss pulses with scale + color | Inspect `enemy_boss.gd` `_process()` for scale modulation |
| 6 | Title/game-over have decorative elements | Inspect `title_screen.gd` / `game_over_screen.gd` for decorative lines |
| 7 | No external/placeholder assets referenced | Grep for `.png`, `.jpg`, `.tres`, `.obj`, or any file extension in `scripts/` |

### Smoke Test
```
godot4 --headless --path . --quit
```
Exit code 0 = PASS.

### Acceptance Criteria Mapping

| Criterion | Evidence |
|-----------|----------|
| Visual finish target met: 2D top-down, procedural sprites, clean readable gameplay, Codex patterns | All 7 static checks pass; Godot headless exits 0 |
| No placeholder/throwaway visuals remain | Grep check returns no external asset references |

---

## 5. Risks and Assumptions

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Godot 4 `_draw()` performance on low-end Android | Low | Medium | All `_draw()` calls are minimal (hearts = 3 circles, grid = sparse lines, arc = one polygon). No GPU particles. |
| Visual changes break existing signal wiring or collision | Low | High | Godot headless validation after each change; smoke test at end |
| Hearts-as-circles was intentional simplicity | Low | Low | If circles are intentional, the upgrade to heart silhouettes is still valid polish; no gameplay change |
| Scope creep into gameplay changes | Low | Medium | Changes are strictly visual-only; no new systems or mechanics |

**Assumptions:**
- Godot 4.6.2 headless is available and working (proven by prior smoke tests)
- No external art assets are used anywhere in the project (confirmed by prior artifact reviews)
- All prior tickets' visual implementations are the current ground truth

---

## 6. Blockers and Required Decisions

**None identified.** All prior tickets completed with verified implementations. Bootstrap is ready. VISUAL-001 depends only on SETUP-001 (done).

**Open question for plan review:**
- Is the circle→heart-silhouette upgrade in HUD desired, or are circles considered acceptable given "procedural/programmatic sprites acceptable"? The plan treats this as valid polish toward the Codex visual bar.
