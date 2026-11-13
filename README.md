# SOL TO THE MOON

Arcade game for the Solana Breakpoint 2026 badge (ESP32-C5, Solana OS, Lua 5.5).

A SOL coin drops. Hold SELECT to charge power, release when it crosses the bat. Three kicks per run; the total is the score. 600 m qualifies for 1 !LAMP, 1100 m for 3 (requires DevRel allowance). During play, wind streaks show direction and three pips show kicks remaining; distance and each kick's score appear only on the result screen.

## Characters and UI

Ten original 16×18 logical-pixel sprites, shown at 4× (64×72 screen pixels): Duck, Cute Animal (fox), Beanie Degen, Senior Dev, Ponytail Dev, Bob Builder, Validator, Onchain Artist, DAO Scout, and Sabadinhos. Sabadinhos is hidden until completing stage one. The native screen is 320×240, with 320×218 available to apps; gameplay renders on an 80×54 canvas at 4×. Each character uses the same seafoam/peach/lavender family with multiple skin shades and distinct accessories. Art source: `scripts/character_art.py`. Preview sheets are `shots/character_study_light.png` and `shots/character_study_dark.png` (art studies, not emulator screenshots). Reference studies only: [Sonic Advance 2 animals](https://www.spriters-resource.com/game_boy_advance/sonicadv2/asset/76977) and [Final Fantasy V Advance portraits](https://www.spriters-resource.com/game_boy_advance/finalfantasy5advance/asset/5156). No third-party sprites copied.

Native `ui.label` supports sizes 12/14/20/32 and `mono`, but no arbitrary font-family. The menu uses built-in ABC Diatype labels and theme colors. Idle sprites alternate between two cached frames every 200 ms: the second removes one waist row, lifting the feet by one canvas pixel. No GIF decoder, file reads or per-frame image loading.

Four original, restrained London pixel backdrops (Westminster with Big Ben, Tower Bridge, Covent Garden, and Olympia with an arched hall and London Eye) appear as transparent 80×17 parallax strips during play. The menu has transparent 24×17 landmark emblems on the left and a character face on the right. The result scene shows total, individual kicks, personal best/rank, and brief confetti. Art sources: `scripts/map_art.py`, `scripts/token_art.py`; `shots/menu_final_study.png` and `shots/end_study.png` are generated layout studies, not badge screenshots.

## Controls

- SELECT: start immediately; during the run hold for charge and release to swing
- LEFT / RIGHT (menu): cycle unlocked characters in the right-hand panel
- UP (menu): cycle four maps in the left-hand panel (Westminster, Tower Bridge, Covent Garden, Olympia). Each run still has three kicks.
- DOWN (menu): cycle sticks (Brolly, Big Ben, Ledger; the last two unlock by best score)
- UP (end screen): local top-five rank board
- CANCEL: back to menu / exit

## Test and transfer

Use the `app.json` and `main.lua` files on the [app submission page](https://solana.com/breakpoint/badge/apps/submit). Try in emulator or Run on badge (desktop Chrome/Edge via USB); publishing is a separate step. Do not upload the entire repository, which includes Python tests and screenshots.

For local simulation, create `.venv` with Lua 5.5 `lupa` and run `sim.py`. `calib.py 10` runs a physics sweep. Both are headless; physical badge visual and performance QA remain necessary.

`lamps.award` pays only after DevRel sets an award cap for app id `moonshot`.
