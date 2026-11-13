# SOL TO THE MOON

A three-kick arcade game for the **Solana Breakpoint 2026 badge**. Catch the falling SOL coin with a timed swing, use wind to your advantage, and chase a longer total across four London-inspired maps.

**At a glance**

- **Platform:** ESP32-C5 · Solana OS · Lua 5.5. App ID: `moonshot`.
- **Play:** pick a map and character; hold SELECT to charge, release to kick. Three kicks per run.
- **Social:** nearby badges running this app exchange personal-best scores over mesh. Your rank and up to four peer scores appear on the results screen. Not Yearbook, not a global or verified-friends leaderboard.
- **Rewards:** code requests 1 !LAMP at 600 m or 3 at 1,100 m. **Inactive until DevRel approves a daily award cap.** Peer scores never determine rewards.
- **Status:** v0.5.2 tested in a headless simulator; physical-badge and two-badge mesh QA pending. **Not published in the badge App Store.**

[DevRel brief and release checks](docs/DEVREL.md) · [Solana OS API](https://solana.com/breakpoint/badge/apps/docs)

## Test on a badge

Upload **`main.lua` + `app.json` only** at the [app submission page](https://solana.com/breakpoint/badge/apps/submit); use the emulator or USB **Run on badge** before publishing. The `dist/` ZIP is a local test artifact, not part of this GitHub repository. To test rankings, run the app on two badges on the same mesh channel, finish a run and press UP on the results screen.

A short parallax intro is followed by an input-safe ready beat: the launch press must be released and stay released briefly before the coin starts falling. Early button mashing during the animation cannot waste a kick. Wind is shown by small, irregular drifting curls rather than long straight streaks.

Menu: UP/DOWN maps, LEFT/RIGHT characters, SELECT play. During play: hold/release SELECT. Results: DOWN cycles the next bat, UP opens ranks, SELECT replays. CANCEL goes back.

Local tests (Python with `lupa`): `python sim.py` and `python calib.py 10`. The screenshots in `shots/` are **generated art studies, not badge captures**.
