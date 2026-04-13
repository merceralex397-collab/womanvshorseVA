# Model Matrix

Default stack label: `framework-agnostic`

These values should come from an explicit user choice during scaffold generation, not from a hidden generator default.

- model tier: `standard`
- provider: `minimax-coding-plan`
- team lead / planner / reviewers: `minimax-coding-plan/MiniMax-M2.7`
- implementer: `minimax-coding-plan/MiniMax-M2.7`
- utilities, docs, and QA helpers: `minimax-coding-plan/MiniMax-M2.7`
- operating profile: `Standard-tier evidence-first profile`
- prompt density: `explicit checklists with selective examples and linked truth sources`
- repo-local profile skill: `.opencode/skills/model-operating-profile/SKILL.md`

Profile guidance:

- `Keep prompts explicit and bounded, but use lighter repetition. Preserve stop conditions and verification checklists while relying more on linked canonical docs than inline examples.`

If the project chooses a different runtime model strategy later, update the canonical brief, this file, and `.opencode/skills/model-operating-profile/SKILL.md` together.
