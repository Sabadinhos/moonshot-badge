# Moon Shot

Arcade game for the Solana Breakpoint 2026 badge (ESP32-C5, Solana OS, Lua 5.5).

A token drops. Hold SELECT to charge power, release when the token crosses the bat. Three swings, one per stage (Intelligence Summit, Scale or Die, Breakpoint). Total distance is the score. Reach 600 m for 1 !LAMP, 1100 m for 3.

## Controls

- SELECT: hold to charge, release to swing
- LEFT / RIGHT (menu): pick a stick (Brolly, Big Ben, Ledger; the last two unlock by best score)
- UP (menu or end screen): rank board (top 5, stored on the badge)
- CANCEL: back to menu / exit

## Files

- `main.lua` – the app (single file, ~20 KB, no bundled assets; all art is inline pixel art)
- `app.json` – manifest (permissions: `led`, `lamps`)
- `sim_env.py`, `sim.py`, `calib.py` – headless harness that stubs the Solana OS Lua API (needs `lupa`, Lua 5.5) for play-through tests and physics calibration
- `shots/` – screenshots from the official web emulator

## Test

```
uv venv .venv && uv pip install --python .venv/Scripts/python.exe lupa
.venv/Scripts/python.exe sim.py       # scripted 2-run play-through, asserts state machine
.venv/Scripts/python.exe calib.py 10  # distance/time sweep over power x timing x wind
```

Emulator: open https://solana.com/breakpoint/badge/emulator, console `lua put moonshot main.lua begin|<base64 lines>|end`, then `lua run moonshot`. Or drop the folder on https://solana.com/breakpoint/badge/apps/submit and use Try in emulator / Run on badge.

Measured on the emulator firmware: boots with ~43 KB Lua heap, no errors across menu, ranks, 3 swings, end screen.

## !LAMPs

`lamps.award` pays only after DevRel sets an award cap for the app. Proposal: 1 !LAMP at 600 m total, 3 at 1100 m, 10 per player per day.
