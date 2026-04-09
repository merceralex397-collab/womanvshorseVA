# START HERE

<!-- SCAFFORGE:START_HERE_BLOCK START -->
## What This Repo Is

Woman vs Horse VA — a 2D top-down arena action game for Android where a warrior woman fights waves of enemy horses. Built with Godot 4.6, using procedural/programmatic sprites (colored shapes). Touch controls. Single scene architecture.

## Current State

Scaffold complete. Skills, agents, and ticket pack are populated with game-specific content. The repo is ready to begin implementation through the managed OpenCode workflow. Bootstrap has not yet been verified — the first ticket should run `environment_bootstrap` to confirm Godot 4.6 and Android SDK availability.

## Read In This Order

1. README.md
2. AGENTS.md
3. docs/AGENT-DELEGATION.md
4. docs/spec/CANONICAL-BRIEF.md
5. docs/process/workflow.md
6. tickets/manifest.json
7. tickets/BOARD.md

## Current Or Next Ticket

- ID: SETUP-001
- Title: Create main scene with arena
- Wave: 0
- Lane: scene-foundation
- Stage: planning
- Status: todo
- Resolution: open
- Verification: suspect

## Dependency Status

- current_ticket_done: no
- dependent_tickets_waiting_on_current: SETUP-002, CORE-002, CORE-004, UI-001, UI-002
- split_child_tickets: none

## Generation Status

- handoff_status: scaffold complete — skills, agents, and tickets populated
- process_version: 7
- parallel_mode: sequential
- pending_process_verification: false
- repair_follow_on_outcome: clean
- repair_follow_on_required: false
- repair_follow_on_next_stage: none
- repair_follow_on_verification_passed: true
- repair_follow_on_updated_at: Not yet recorded.
- bootstrap_status: missing
- bootstrap_proof: None
- process_changed_at: Not yet recorded.

## Post-Generation Audit Status

- audit_or_repair_follow_up: none recorded
- reopened_tickets: none
- done_but_not_fully_trusted: none
- pending_reverification: none
- repair_follow_on_blockers: none

## Known Risks

- Bootstrap not yet verified — godot4 and Android SDK availability must be confirmed before implementation work.
- Validation can fail for environment reasons until bootstrap proof exists.
- Historical completion should not be treated as current trust once defects or process drift are discovered.
- Delegation mistakes can cause lifecycle loops; check `docs/AGENT-DELEGATION.md` before improvising a new handoff path.

## Next Action

Run `environment_bootstrap` to verify Godot 4.6 and Android SDK availability. Then claim SETUP-001 and begin planning the main scene and arena.
<!-- SCAFFORGE:START_HERE_BLOCK END -->
