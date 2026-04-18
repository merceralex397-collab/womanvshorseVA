# REMED-009: GDScript calls APIs that are unavailable on the script's declared base type

## Summary

Remediate EXEC-GODOT-009 by correcting the validated issue and rerunning the relevant quality checks. Affected surfaces: project.godot, scripts/hud.gd, scripts/wave_spawner.gd.

## Wave

16

## Lane

remediation

## Parallel Safety

- parallel_safe: false
- overlap_risk: low

## Stage

closeout

## Status

done

## Trust

- resolution_state: superseded
- verification_state: reverified
- finding_source: EXEC-GODOT-009
- source_ticket_id: REMED-002
- source_mode: split_scope

## Depends On

None

## Follow-up Tickets

None

## Decision Blockers

None

## Acceptance Criteria

- [ ] The validated finding `EXEC-GODOT-009` no longer reproduces.
- [ ] Current quality checks rerun with evidence tied to the fix approach: Validate GDScript method calls against the declared base type and move draw/redraw or viewport-rect logic onto compatible CanvasItem-derived nodes before treating headless load as trustworthy.

## Artifacts

- None yet

## Notes


