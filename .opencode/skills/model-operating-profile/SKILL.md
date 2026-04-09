---
name: model-operating-profile
description: Apply the `Standard-tier evidence-first profile` operating profile for the selected downstream models. Use when shaping prompts, delegation briefs, review asks, or evidence requests for this repo.
---

# Model Operating Profile

Before reading anything else, call `skill_ping` with `skill_id: "model-operating-profile"` and `scope: "project"`.

Selected runtime profile:

- model tier: `standard`
- provider: `minimax-coding-plan`
- team lead / planner / reviewers: `minimax-coding-plan/minimax-coding-plan/MiniMax-M2.7`
- implementer: `minimax-coding-plan/minimax-coding-plan/MiniMax-M2.7`
- utilities, docs, and QA helpers: `minimax-coding-plan/minimax-coding-plan/MiniMax-M2.7`
- operating profile: `Standard-tier evidence-first profile`
- prompt density: `explicit checklists with selective examples and linked truth sources`

Use this profile when drafting:

- task prompts
- delegation briefs
- review requests
- handoff expectations

Profile guidance:

`Keep prompts explicit and bounded, but use lighter repetition. Preserve stop conditions and verification checklists while relying more on linked canonical docs than inline examples.`

Required rules:

- keep stop conditions and verification checklists explicit
- reference canonical truth surfaces directly when they already contain the durable procedure
- use examples only where the workflow would otherwise stay ambiguous
- keep tasks bounded and evidence-first
- surface blockers clearly instead of improvising around them

When ambiguity is likely, prefer a concrete output shape such as:

```text
Goal
Constraints
Expected output
Evidence required
Blockers
```

## MiniMax-M2.7 — Repo-Proven Guidance

These notes are based on observed behavior in this project context:

- **GDScript generation**: The model handles GDScript 4.x syntax well but occasionally uses Godot 3.x patterns (e.g., `yield` instead of `await`, `onready` instead of `@onready`). Delegation briefs should specify "Godot 4.6 GDScript" explicitly and reference the `godot-android-game` skill.
- **Procedural art**: When generating `_draw()` code or Polygon2D setup, provide the exact color values and sizes from the `procedural-art` skill to avoid the model inventing its own visual language.
- **Scene tree references**: Specify node paths explicitly in delegation briefs. The model tends to assume `$NodeName` paths that may not match the actual scene tree.
- **Prompt density**: Keep delegation briefs under 2000 tokens. Include the exact file paths to create/modify and the acceptance criteria from the ticket. Omit background context the model can load from skills.
- **Evidence requirements**: Always request command output in implementation artifacts. The model will claim success without evidence if not explicitly required to include it.
