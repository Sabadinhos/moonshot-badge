# DevRel brief: SOL TO THE MOON

- **App ID:** `moonshot`
- **Target:** Breakpoint 2026 badge, ESP32-C5, Solana OS (Lua)
- **Manifest permissions:** `led`, `lamps`, `mesh`

## What the player does

Pick one of four London maps with LEFT/RIGHT and a character with UP/DOWN. SELECT starts the short parallax intro; after releasing the launch press, a fresh SELECT press starts the falling SOL coin and charges power while held. Release near the bat. Three kicks make a run; the sum of their distances is the final score. Wind changes the flight, with small drifting curls indicating its direction. Early input during the intro cannot consume a kick. An end screen shows the results. Maps, characters, bats and personal best persist on that badge.

## Nearby scores

Badges running this same app exchange **personal-best scores** through `mesh.send` / `on_mesh`. The results screen shows the player's own score and up to four peers in a top-five view; up to eight recent peers are stored locally. Peers must be reachable on the same event mesh channel (or via a bridge). This is not Yearbook integration, a global leaderboard, authenticated friendships or real-time multiplayer. Peer scores are self-reported, not independently verified, and **never affect rewards**.

## Rewards: proposed, not active

The app requests 1 !LAMP for a run of at least 600 m, or 3 !LAMPs for at least 1,100 m, via `lamps.award`. There is no approved daily award cap yet, so the request does **not** pay until DevRel grants an allowance to app ID `moonshot`. The scoring thresholds are in the client and are not fraud-resistant; DevRel should review reward rules and an appropriate per-player daily cap before enabling payments. Players need an X-linked owner account to earn. The current in-app message only shows a reward when the award callback reports a positive grant.

## Release and test

- `main.lua` and `app.json` are the upload package. The tested ZIP is produced locally under `dist/`; the GitHub repository also includes test and art sources, so do not upload the entire repository.
- Local Lua simulation covers menu controls, fresh-press-to-drop timing and pause/resume, three-kick play, persistence, results, reward callback and mesh message validation; the physics sweep, transition-width regression and source-art/package checks passed for v1.0.1. The revised transition still needs badge display QA.
- **Not yet verified on the physical badge.** Before App Store publication, run the ZIP via the submission page's emulator / USB **Run on badge**; test rendering, memory, input, two-badge mesh exchange and the interaction between mesh radio and Wi-Fi. A sign-in and linked X account are required to publish.
- Publishing without an award cap is possible. Once a cap exists, subsequent code/file/permission changes require organiser approval. Ask DevRel for the cap separately after the gameplay and reward policy are validated.

[Solana OS Lua API](https://solana.com/breakpoint/badge/apps/docs) · [Submit / test](https://solana.com/breakpoint/badge/apps/submit)
