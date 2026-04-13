---
name: model-operating-profile
description: Apply the `Standard-tier evidence-first profile` operating profile for the selected downstream models. Use when shaping prompts, delegation briefs, review asks, or evidence requests for this repo.
---

# Model Operating Profile

Before reading anything else, call `skill_ping` with `skill_id: "model-operating-profile"` and `scope: "project"`.

Selected runtime profile:

- model tier: `standard`
- provider: `minimax-coding-plan`
- team lead / planner / reviewers: `minimax-coding-plan/MiniMax-M2.7`
- implementer: `minimax-coding-plan/MiniMax-M2.7`
- utilities, docs, and QA helpers: `minimax-coding-plan/MiniMax-M2.7`
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
