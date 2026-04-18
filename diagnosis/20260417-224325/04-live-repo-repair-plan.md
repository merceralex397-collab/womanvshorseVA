# Live Repo Repair Plan

## Preconditions

- Repo: /home/rowan/womanvshorseVA
- Audit stayed non-mutating. No repo or product-code edits were made by this diagnosis run.

## Triage Order

- package_first_count: 0
- subject_repo_follow_up_count: 0
- host_or_manual_prerequisite_count: 0

## Package Changes Required First

- None recorded.

## Post-Update Repair Actions

- Route 1 workflow-layer finding(s) into `scafforge-repair` for deterministic managed-surface refresh.

### REMED-020

- linked_report_id: WFLOW030
- action_type: safe Scafforge package change
- should_scafforge_repair_run: yes
- carry_diagnosis_pack_into_scafforge_first: no
- target_repo: subject repo
- summary: Host-operator must: (1) run the required host-only stages (project-skill-bootstrap via Scafforge), (2) update repair_follow_on.completed_stages in workflow-state.json, and (3) set outcome to 'clean' or 'source_follow_up' once all stages are done. After that the local agent regains ticket mutation access.

## Ticket Follow-Up

- No subject-repo ticket follow-up was recommended from the current diagnosis run.

## Reverification Plan

- After package-side fixes land, run one fresh audit on the subject repo before applying another repair cycle.
- After managed repair, rerun the public repair verifier and confirm restart surfaces, ticket routing, and any historical trust restoration paths match the current canonical state.
- Do not treat restart prose alone as proof; the canonical manifest and workflow state remain the source of truth.

