# SOL TO THE MOON

![SOL TO THE MOON arcade poster with four London pixel-art landmarks](shots/readme_banner.png)

**PUMP a SOL coin across London. Three kicks, four maps, nearby scores.**

Pick a character. Hold SELECT to drop the coin and charge. Release near the bat. Send it flying across Westminster, Tower Bridge, Covent Garden or Olympia.

## Every day

![Daily layer](shots/daily_study.png)

A new **Daily Map** with the same winds on every badge. Three daily quests. A day streak. Today's best. Resets at UTC midnight, no rewards attached.

## Gameplay

| Pick your run | Kick |
| --- | --- |
| ![Menu: cycling the four London maps and the character roster](shots/gifs/01_menu.gif) | ![One kick: drop, charge, hit and the coin flying across Westminster](shots/gifs/02_kick.gif) |

| Three kicks and the score | CANCEL pauses, never drops you out |
| --- | --- |
| ![A full three-kick run ending on the result screen](shots/gifs/03_full_run.gif) | ![CANCEL freezes play and asks before quitting](shots/gifs/04_pause.gif) |

*Rendered from the app's own draw calls with `make_gifs.py`. Simulator renders, not captures from the physical badge; fonts and colour on the badge screen will differ.*

**3 kicks** per run · **4 London maps** · **nearby best scores** over badge mesh

**Rewards proposed:** 600 m earns 1 !LAMP, 800 m earns up to 5 !LAMPs, with a target limit of 20 !LAMPs per player each UTC day. **Not active:** DevRel must approve and set the server-side cap. Nearby scores never determine rewards.

[Playtest on the badge](https://solana.com/breakpoint/badge/apps/submit) · [How it works and release status](docs/DEVREL.md) · [Store copy](docs/STORE_COPY.md)

<details>
<summary>Controls, build and status</summary>

- **Menu:** LEFT/RIGHT map, UP/DOWN character, SELECT play.
- **Kick:** after the short intro, release SELECT once. Press and hold it again to start the drop and charge, then release near the bat. CANCEL pauses play and quitting asks for confirmation. The OS HOME key cannot be intercepted.
- **Results:** DOWN selects the next bat, UP shows nearby ranks, SELECT replays. Ranks are self-reported by nearby badges running this app: not Yearbook, not a global or verified-friends leaderboard.
- **App:** `soltothemoon` v1.3.0 · Lua 5.5 · Solana OS · ESP32-C5. Upload `main.lua` and `app.json` only, or the matching local `dist/` ZIP. Run the emulator and the USB badge test before publishing.
- **Validation:** headless Lua simulations cover controls, game flow, rewards, identity and physics (`python sim.py`, `sim_controls.py`, `sim_final_controls.py`, `sim_rewards.py`, `sim_transition.py`, `sim_identity.py`, `sim_balance.py`, `sim_easy.py`, `sim_daily.py`, `calib.py 10`). `sim_render.py` rasterises the same draw calls for the GIFs above. Physical badge, two-badge mesh and App Store publication remain unverified.

</details>
