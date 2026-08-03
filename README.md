# Wheelie Challenge

Small 2D motorcycle stunt game prototype built with Godot 4 (GDScript).

Overview

Wheelie Challenge is a compact 2–3 minute 2D motorcycle stunt game. Ride through a single track, perform wheelies, jumps and flips, collect coins, and try to finish with the highest score before 3 crashes end your run.

Features in this prototype
- Basic Godot 4 project files and scenes
- Player motorcycle with simplified controls (accelerate/brake/lean)
- Scoring manager implementing the scoring system from the spec
- Track scene with placeholder ramps, coins and finish line
- HUD for score/time/coins/crashes
- Victory and Game Over scenes reporting totals
- Simple SVG placeholder art you can replace later

Controls
- Right Arrow: Accelerate
- Left Arrow: Brake
- Up Arrow: Lean back (use while moving to do a wheelie)
- Down Arrow: Lean forward

Scoring (implemented)
- Wheelie: +100 points per second while in wheelie state
- Small jump: +150
- Big jump: +300
- Perfect landing: +100
- Collect coin: +50
- Backflip / Frontflip: +500 each
- Crash: -250 (3 crashes -> Game Over)

Running the project
1. Install Godot 4 (recommended) from https://godotengine.org/
2. Clone this repository and switch to the branch `feature/initial-prototype`.
3. Open the project folder in Godot and run the `scene/Main.tscn` scene.

Notes and next steps
- Art and SFX are placeholders (SVGs and SFX README). Replace assets in `assets/sprites/` and `assets/sfx/`.
- Track layout is minimal and tuned for ~2–3 minute runs; tweak ramp spacing and friction as needed.
- If you want this autoloaded (GameManager singleton), add `scripts/game_manager.gd` as an Autoload in Project Settings.

Credits
- Prototype created by vidar908 with help from GitHub Copilot Chat Assistant.
