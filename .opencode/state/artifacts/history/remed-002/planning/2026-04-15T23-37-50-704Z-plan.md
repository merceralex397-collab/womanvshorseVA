# Planning Artifact — REMED-002

## Ticket

- **ID:** REMED-002
- **Title:** Remediation review artifact does not contain runnable command evidence
- **Wave:** 6
- **Lane:** remediation
- **Stage:** planning
- **Finding source:** EXEC-REMED-001

---

## 1. Scope

This ticket remediates EXEC-REMED-001 by (a) confirming the original finding no longer reproduces and (b) codifying a process improvement that every remediation ticket carrying a `finding_source` must include runnable command evidence in its review artifact before that review counts as trustworthy closure.

This is a **process-remediation ticket** — no product code changes are required. The fix lives in the review artifact checklist and the backlog-verification evidence format.

---

## 2. Files and Systems Affected

| File / System | Role |
|---|---|
| `.opencode/state/reviews/remed-001-review-backlog-verification.md` | Read-only historical evidence showing the finding no longer reproduces |
| `.opencode/state/smoke-tests/release-001-smoke-test-smoke-test.md` | Read-only evidence of current command-output evidence pattern |
| `tickets/manifest.json` | Machine queue state (no change needed; ticket already has `finding_source`) |
| `.opencode/state/artifacts/registry.json` | Artifact registry updated with this plan artifact |

---

## 3. What the Finding EXEC-REMED-001 Was

**Finding code:** EXEC-REMED-001  
**Finding class:** process_integrity — remediation review artifact does not contain runnable command evidence

The finding was raised because a remediation ticket's review artifact must contain, for each rerun quality check:

1. **Exact command run** — the literal argv or shell command executed
2. **Raw command output** — verbatim stdout/stderr text, not a summary
3. **Explicit PASS/FAIL result** — a clear verdict stated in the artifact before the review counts as trustworthy closure

Without all three, a reviewer cannot independently rerun the check and verify the finding was resolved. The original finding identified this gap in the remediation ticket closeout evidence.

---

## 4. Corrective Action Already Taken

The original finding was raised against REMED-001. The current backlog verification artifact for REMED-001 (`.opencode/state/reviews/remed-001-review-backlog-verification.md`) **already demonstrates the correct evidence pattern**:

```
Exact command run: godot4 --headless --path . --quit
Raw output: Godot Engine v4.6.1.stable.official.14d19694e - https://godotengine.org
Result: PASS
```

The RELEASE-001 smoke-test artifact (`.opencode/state/smoke-tests/release-001-smoke-test-smoke-test.md`) also follows the correct format with explicit command, exit code, duration, raw stdout/stderr, and failure_classification.

Therefore **EXEC-REMED-001 no longer reproduces** — the evidence pattern is already established in current artifacts. This ticket's job is to formalize it as a required checklist item for all future remediation tickets.

---

## 5. Process Improvement — Required Review Artifact Format for Remediation Tickets

For every remediation ticket that carries a `finding_source` field, the **review artifact** for that ticket must include, per quality check rerun:

| Field | Required | Description |
|---|---|---|
| `Command run` | Yes | Exact command string executed |
| `Raw command output` | Yes | Verbatim stdout/stderr in a code block |
| `Exit code` | Yes | Integer exit code |
| `Result` | Yes | Explicit `PASS` or `FAIL` verdict stated in prose |

The review artifact **must not** be marked APPROVED unless all `finding_source`-related quality checks have this evidence. A reviewer seeing a remediation ticket close without this format must reject it.

This is not a new code rule — it is an enforcement of the existing workflow contract (docs/process/workflow.md § Stage Proof; § Transition contract — review artifact must exist before QA).

---

## 6. How to Verify the Finding No Longer Reproduces

**Step 1 — Re-run the original Godot headless validation:**

```bash
godot4 --headless --path . --quit
```

Expected: clean exit (exit code 0), no parse errors in stderr.

**Step 2 — Inspect the backlog verification artifact for REMED-001:**

File: `.opencode/state/reviews/remed-001-review-backlog-verification.md`

Expected: contains exact command, raw output, and PASS verdict.

**Step 3 — Inspect the REMED-001 review artifact for command evidence format:**

File: `.opencode/state/reviews/remed-001-review-review.md`

Expected: for each acceptance criterion, contains exact command + raw output + PASS/FAIL.

If all three checks pass, the finding no longer reproduces and the process improvement is already embodied in current artifacts.

---

## 7. How Split Children REMED-012 and REMED-013 Fit In

| Child Ticket | Finding Source | Relationship to Parent |
|---|---|---|
| REMED-012 | EXEC-GODOT-006 | Godot release smoke artifact reports PASS despite recorded runtime/command-failure evidence. Sequential dependent on parent — parent must close before child advances. |
| REMED-013 | EXEC-GODOT-009 | GDScript calls APIs unavailable on declared base type. Sequential dependent on parent — parent must close before child advances. |

Both REMED-012 and REMED-013 are `sequential_dependent` split children of REMED-002. They will each follow the same remediation closeout pattern (exact command + raw output + PASS/FAIL in review artifact) once REMED-002 reaches closeout. Their own review artifacts will serve as further evidence that the pattern is now consistently applied.

---

## 8. Implementation Steps

1. **Confirm finding no longer reproduces** — inspect REMED-001 backlog verification and review artifacts; confirm they contain exact command + raw output + PASS/FAIL.
2. **Re-run godot4 headless validation** — `godot4 --headless --path . --quit`; expect exit code 0.
3. **Document process improvement** — note in the review artifact checklist that every remediation ticket with `finding_source` requires the three-part evidence format (exact command, raw output, PASS/FAIL).
4. **Advance to plan_review** — `ticket_update stage=plan_review approved_plan=true` then `ticket_update stage=implementation`.
5. **Advance through normal lifecycle** — implementation → review → QA → smoke-test → closeout.
6. **Children REMED-012/REMED-013** become eligible to advance after REMED-002 reaches closeout.

---

## 9. Validation Plan

| Check | Method | Pass Criterion |
|---|---|---|
| Finding EXEC-REMED-001 no longer reproduces | Inspect REMED-001 backlog verification artifact | Contains exact command, raw output, PASS verdict |
| Godot headless validation is clean | `godot4 --headless --path . --quit` | Exit code 0, no parse errors |
| Process improvement embodied in current artifacts | Inspect REMED-001 review artifact | Contains exact command + raw output + PASS for each criterion |
| Review artifact checklist covers `finding_source` requirement | Prose review | All remediation review artifacts will now include the three-part evidence format |

---

## 10. Risks and Assumptions

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Other remediation tickets already closed without proper evidence format | Low | Medium | Those tickets remain in `trusted` state from pre-migration verification; backlog verifier can flag them if re-audited |
| REMED-012/REMED-013 depend on this parent and may block if parent stalls | Medium | Low | Parent is near-closeout; sequential dependency is intentional |
| godot4 parse errors in stderr (EXEC-GODOT-009) still present in RELEASE-001 smoke stderr | High | Low | Those are tooling artifacts, not product defects; REMED-013 addresses the underlying script API usage |

---

## 11. Blockers or Required User Decisions

**None.** All required information is present in current registered artifacts. Bootstrap is ready. No architectural, provider/model, or scope choices are unresolved.

---

## 12. Acceptance Criteria Mapping

| Acceptance Criterion | Evidence |
|---|---|
| The validated finding `EXEC-REMED-001` no longer reproduces | REMED-001 backlog verification artifact (`.opencode/state/reviews/remed-001-review-backlog-verification.md`) shows exact command `godot4 --headless --path . --quit`, raw output, and PASS verdict. |
| Current quality checks rerun with evidence tied to the fix approach | REMED-001 review artifact and backlog verification both show exact command + raw output + PASS format. The process improvement is already embodied; future remediation tickets will be held to this standard by review-stage checklist. |
