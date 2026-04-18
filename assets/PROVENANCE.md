# Asset Provenance

Track every sourced or generated asset added to this repo in the same ticket that introduces it.

## Rules

- Every entry must use a repo-relative path under `assets/` or a Godot `res://` import path.
- Generated assets must record the exact workflow or tool used to create them.
- Third-party assets must keep the source URL and precise license value.
- Record tool-stack license policy separately from model/checkpoint license policy when AI-assisted generation is used.
- Procedural or intentionally no-external-asset repos must still record the active route and any generated runtime content surfaces.
- Placeholder policy: Procedural/programmatic sprites acceptable. Colored shapes with basic animations. No placeholder art in final build.
- Licensing/provenance constraints: No external assets used. All content is procedurally generated.
- Finish acceptance signals: APK compiles and installs. All waves playable. Touch controls work. Score tracking functions.

| asset_path | source_or_workflow | license | author | acquired_or_generated_on | notes |
| --- | --- | --- | --- | --- | --- |
