# SOL TO THE MOON

Arcade game for the Solana Breakpoint 2026 badge (ESP32-C5, Solana OS, Lua 5.5).

A SOL coin drops. Hold SELECT to charge power, release when it crosses the bat. Three kicks per run; the total is the score. 600 m qualifies for 1 !LAMP, 1100 m for 3 (requires DevRel allowance). During play, wind streaks show direction and three pips show kicks remaining; distance and each kick's score appear only on the result screen.

## Characters and UI

Ten original 16×18 logical-pixel sprites: Duck, Cute Animal (fox), Beanie Degen, Senior Dev, Ponytail Dev, Bob Builder, Validator, Onchain Artist, DAO Scout, and Sabadinhos. Sabadinhos unlocks after the first kick. The native screen is 320×240, with 320×218 available to apps. Menu/results use an 80×54 canvas at 4×; gameplay is zoomed out on a 106×72 canvas at 3×. Art source: `scripts/character_art.py`. Preview sheets are art studies, not emulator screenshots.

Native `ui.label` supports sizes 12/14/20/32 and `mono`, but no arbitrary font-family. The menu uses built-in ABC Diatype labels and theme colors. Idle sprites alternate between two cached frames every 200 ms: the second removes one waist row, lifting the feet by one canvas pixel. No GIF decoder, file reads or per-frame image loading.

Four London pixel maps: Westminster (Big Ben and a distant London Eye), Tower Bridge, Covent Garden, and Olympia (one arched Grand Hall). The menu has transparent landmark emblems and character faces. A 0.6-second faux-3D parallax fly-in moves foreground faster than the skyline before each kick. The SOL coin uses only purple/green tones. `shots/menu_final_study.png` and `shots/end_study.png` are generated layout studies, not badge screenshots.

## Controls

- UP / DOWN (menu): cycle maps forward/back in the left-hand panel
- LEFT / RIGHT (menu): cycle unlocked characters in the right-hand panel
- SELECT: start immediately; during a kick hold for charge and release to swing
- DOWN (end screen): choose the next unlocked bat (Brolly, Big Ben, Ledger)
- UP (end screen): scores from you and badges met while running this same app
- CANCEL: back to menu / exit

## Test and transfer

Use the `app.json` and `main.lua` files on the [app submission page](https://solana.com/breakpoint/badge/apps/submit). Try in emulator or Run on badge (desktop Chrome/Edge via USB); publishing is a separate step. Do not upload the entire repository, which includes Python tests and screenshots.

For local simulation, create `.venv` with Lua 5.5 `lupa` and run `sim.py`. `calib.py 10` runs a physics sweep. Both are headless; physical badge visual and performance QA remain necessary.

The scoreboard uses the `mesh` permission to exchange personal-best scores with nearby badges **running this app**. It saves the last eight peers seen and shows the top five with your own best. This is not a global Yearbook ranking or a list of confirmed friends: scores are self-reported by peers and are **never** used for !LAMP awards. It needs at least two badges on the same event mesh channel (or a mesh bridge); test solo runs normally but shows only YOU. Mesh radio mode can interrupt Wi-Fi on older Solana OS builds, so verify !LAMP award behavior on the actual firmware.

`lamps.award` pays only after DevRel sets an award cap for app id `moonshot`.
