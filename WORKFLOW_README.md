This branch adds a GitHub Actions workflow that reports whether a Godot project and export_presets.cfg are present in the repository.

Why:
- Your repo currently does not contain Godot project files (project.godot, export_presets.cfg). The previous HTML5 build workflow failed repeatedly because the project is missing from the default branch.

What this workflow does:
- Runs on pushes that touch typical Godot files or on manual dispatch.
- Checks for project.godot and export_presets.cfg.
- If either file is missing, it creates and uploads a small artifact (html5-build-status) explaining why the build was skipped.
- If both files exist, it writes a placeholder status indicating where to add the Godot download and export steps.

Next steps (recommended):
- If you want CI to produce an HTML5 build automatically, add your Godot project files (project.godot and export_presets.cfg) to the repository, and update the "Prepare to build" step in the workflow to download the matching Godot executable and export templates, then run `godot --export "HTML5" <output>`.
- Alternatively, I can update the workflow to add the full Godot download + export steps for a specific Godot version (3.x or 4.x) once you confirm which version to target.
