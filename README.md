# SOL TO THE MOON

Arcade game for the Solana Breakpoint 2026 badge (ESP32-C5, Solana OS, Lua 5.5).

A Solana-mark token drops. Hold SELECT to charge power, release when it crosses the bat. Three swings across Intelligence Summit, Scale or Die, and Breakpoint. Total distance is the score. 600 m qualifies for 1 !LAMP, 1100 m for 3 (requires DevRel allowance).

## Characters and UI

Ten original 16×18 logical-pixel sprites, shown at 4× (64×72 screen pixels): Duck, Cute Animal (fox), Beanie Degen, Senior Dev, Ponytail Dev, Bob Builder, Validator, Onchain Artist, DAO Scout, and Sabadinhos. Sabadinhos is hidden until completing stage one. The native screen is 320×240, with 320×218 available to apps; gameplay renders on an 80×54 canvas at 4×. Each character uses the same seafoam/peach/lavender family with multiple skin shades and distinct accessories. Art source: `scripts/character_art.py`. Preview sheets are `shots/character_study_light.png` and `shots/character_study_dark.png` (art studies, not emulator screenshots). Reference studies only: [Sonic Advance 2 animals](https://www.spriters-resource.com/game_boy_advance/sonicadv2/asset/76977) and [Final Fantasy V Advance portraits](https://www.spriters-resource.com/game_boy_advance/finalfantasy5advance/asset/5156). No third-party sprites copied.

Native `ui.label` supports sizes 12/14/20/32 and `mono`, but no arbitrary font-family. The menu uses built-in ABC Diatype labels and theme colors. Idle sprites alternate between two cached frames every 200 ms: the second removes one waist row, lifting the feet by one canvas pixel. No GIF decoder, file reads or per-frame image loading.

The menu places a transparent 24×17 London landmark emblem on the left and only the character's face on the right. No boxed skyline or screenshot-style map thumbnail remains. Three original, restrained London pixel backdrops (Westminster, Tower Bridge, Covent Garden) still appear as transparent 80×17 parallax strips during play, with the characters' muted lavender/seafoam/warm-neutral palette. The icons and in-game strips are cached at startup. Art source: `scripts/map_art.py`; `shots/menu_final_study.png` is a generated layout study, not a badge screenshot.

## Controls

- SELECT: start immediately; during the run hold for charge and release to swing
- LEFT / RIGHT (menu): cycle unlocked characters in the right-hand panel
- UP (menu): cycle maps in the left-hand panel (Westminster, Tower Bridge, Covent Garden); the preview and in-game skyline, sky, and ground switch together. Each run still has the same three swings.
- DOWN (menu): cycle sticks (Brolly, Big Ben, Ledger; the last two unlock by best score)
- UP (end screen): local top-five rank board
- CANCEL: back to menu / exit

## Test and transfer

Use the `app.json` and `main.lua` files on the [app submission page](https://solana.com/breakpoint/badge/apps/submit). Try in emulator or Run on badge (desktop Chrome/Edge via USB); publishing is a separate step. Do not upload the entire repository, which includes Python tests and screenshots.

For local simulation, create `.venv` with Lua 5.5 `lupa` and run `sim.py`. `calib.py 10` runs a physics sweep. Both are headless; physical badge visual and performance QA remain necessary.

`lamps.award` pays only after DevRel sets an award cap for app id `moonshot`.
