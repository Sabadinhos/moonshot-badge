# Moon Shot

Arcade game for the Solana Breakpoint 2026 badge (ESP32-C5, Solana OS, Lua 5.5).

A Solana-mark token drops. Hold SELECT to charge power, release when it crosses the bat. Three swings across Intelligence Summit, Scale or Die, and Breakpoint. Total distance is the score. 600 m qualifies for 1 !LAMP, 1100 m for 3 (requires DevRel allowance).

## Characters and UI

Original 16×18 logical-pixel sprites, shown at 4× (64×72 screen pixels): Base Character, Cute Animal (fox), Beanie Degen, Senior Dev, and Sabadinhos. Sabadinhos is hidden until completing stage one. The native screen is 320×240, with 320×218 available to apps; gameplay renders on an 80×54 canvas at 4×. Reference studies only: [Sonic Advance 2 animal sheet](https://www.spriters-resource.com/game_boy_advance/sonicadv2/asset/76977) and [Final Fantasy V Advance portraits](https://www.spriters-resource.com/game_boy_advance/finalfantasy5advance/asset/5156). No third-party sprites copied. Preview sheets are `shots/character_study_light.png` and `shots/character_study_dark.png` (art studies, not emulator screenshots).

Native `ui.label` supports sizes 12/14/20/32 and `mono`, but no arbitrary font-family. The menu uses built-in ABC Diatype labels and theme colors, so it adapts to light/dark mode. Canvas art uses cached `ui.load` images and `on_tick` bob/shimmer rather than GIF decoding on the badge.

## Controls

- SELECT: start immediately; during the run hold for charge and release to swing
- LEFT / RIGHT (menu): cycle unlocked skins
- DOWN (menu): cycle sticks (Brolly, Big Ben, Ledger; the last two unlock by best score)
- UP (menu or end screen): local top-five rank board
- CANCEL: back to menu / exit

## Test and transfer

Use the `app.json` and `main.lua` files on the [app submission page](https://solana.com/breakpoint/badge/apps/submit). Try in emulator or Run on badge (desktop Chrome/Edge via USB); publishing is a separate step. Do not upload the entire repository, which includes Python tests and screenshots.

For local simulation, create `.venv` with Lua 5.5 `lupa` and run `sim.py`. `calib.py 10` runs a physics sweep. Both are headless; physical badge visual and performance QA remain necessary.

`lamps.award` pays only after DevRel sets an award cap for app id `moonshot`.
