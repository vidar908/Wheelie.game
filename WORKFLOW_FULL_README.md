This branch adds a complete GitHub Actions workflow that attempts HTML5 exports for both Godot 4.x and Godot 3.x.

Details:
- Workflow: .github/workflows/godot-html5-full.yml
  - Triggers: push (when Godot files are changed) and manual dispatch.
  - Matrix builds for two Godot versions: 4.2.4 and 3.5.2 (change versions if you want other releases).
  - Uses game-ci/godot-setup@v2 to install the Godot executable and matching HTML5 export templates.
  - Runs godot --no-window --export "HTML5" to create the export into build/html5/<version>/
  - Uploads the exported build as an artifact.
  - If project.godot or export_presets.cfg are missing, the workflow uploads a small html5-build-status artifact explaining why the build was skipped.

Notes and next steps:
- If your project targets a different Godot minor version, update the matrix.godot_version values.
- If the export preset name is not exactly "HTML5" in export_presets.cfg, change the --export argument accordingly.
- The workflow uses community-maintained game-ci actions (game-ci/godot-setup). If your org policy restricts third-party actions, let me know and I’ll switch to a manual download of Godot and templates.
