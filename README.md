# SOL TO THE MOON

PUMP a SOL coin across London. Three kicks, four maps, nearby scores. Built for the **Solana Breakpoint 2026 badge**.

**At a glance**

- **Platform:** ESP32-C5 · Solana OS · Lua 5.5. App ID: `moonshot`.
- **Play:** pick a map and character; press and hold SELECT to start the falling coin and charge power, then release near the bat. Three kicks per run.
- **Social:** nearby badges running this app exchange personal-best scores over mesh. Your rank and up to four peer scores appear on the results screen. Not Yearbook, not a global or verified-friends leaderboard.
- **Rewards:** code requests 1 !LAMP at 600 m or 3 at 1,100 m. **Inactive until DevRel approves a daily award cap.** Peer scores never determine rewards.
- **Status:** v1.0.2 tested in a headless simulator; physical-badge and two-badge mesh QA pending. **Not published in the badge App Store.**

[App Store copy](docs/STORE_COPY.md) · [DevRel brief and release checks](docs/DEVREL.md) · [Solana OS API](https://solana.com/breakpoint/badge/apps/docs)

## Test on a badge

Upload **`main.lua` + `app.json` only** at the [app submission page](https://solana.com/breakpoint/badge/apps/submit); use the emulator or USB **Run on badge** before publishing. The `dist/` ZIP is a local test artifact, not part of this GitHub repository. To test rankings, run the app on two badges on the same mesh channel, finish a run and press UP on the results screen.

A short parallax intro is followed by an input-safe ready beat. Release the launch press; a fresh SELECT press starts the coin falling and begins charging. Keep it held, then release at the bat. Early button mashing during the animation cannot waste a kick. Wind is shown by small, irregular drifting curls.

Menu: LEFT/RIGHT maps, UP/DOWN characters, SELECT play. During play: press and hold SELECT to start the drop; release at the bat. Results: DOWN cycles the next bat, UP opens ranks, SELECT replays. CANCEL during play pauses without advancing the coin; SELECT or CANCEL resumes, DOWN returns to the menu, RIGHT opens quit confirmation. CANCEL on the menu opens quit confirmation: SELECT/CANCEL stays, RIGHT exits. Scene changes render directly, without a colour overlay. The OS HOME button always exits and cannot be intercepted by an app.

Local tests (Python with `lupa`): `python sim.py`, `python sim_controls.py`, `python sim_final_controls.py` and `python calib.py 10`. The screenshots in `shots/` are **generated art studies, not badge captures**.
