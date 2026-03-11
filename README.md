# 🔴 One Button Empire

> *"One button. Infinite universes. Every click matters."*

A Roblox incremental/clicker game where **one button builds an entire universe**. Click a giant physical button, watch your world evolve from a Dirt Patch all the way to The Singularity, buy upgrades from SurfaceGui billboards in-world, and trigger "The Big Bang" prestige to grow even faster.

---

## ✨ Features

- 16 world evolution stages (Void → The Singularity)
- Physical 3D button with click animations and particle effects
- In-world upgrade billboards (no boring 2D menu)
- Prestige system — "The Big Bang"
- 7 random events every 2–5 minutes
- 14 achievements
- Global leaderboards via OrderedDataStore
- Full anti-cheat click validation
- **You use your own models** — all scripts look up models by name from folders you create

---

## 🚀 Quick Start Guide

1. **Open Roblox Studio** and create a new Baseplate place.
2. **Open the Command Bar** — go to `View > Command Bar` in the Studio menu.
3. **Run the setup scripts in order** — paste the contents of each file in `scripts/` into the Command Bar and press Enter:
   1. `01_Setup_RemoteEvents.lua` — Creates all RemoteEvents & RemoteFunctions
   2. `02_Setup_ModuleScripts.lua` — Creates UpgradeConfig, StageConfig, FormatNumber modules
   3. `03_Server_DataManager.lua` through `10_Server_GameManager.lua` — Server scripts
   4. `11_Client_ClickController.lua` through `15_Client_EventController.lua` — Client scripts
   5. `16_Setup_ButtonModel.lua` — Creates a placeholder button (replace with your own)
   6. `17_Setup_Workspace.lua` — Sets up Workspace folders + ServerStorage stage folders
4. **Add your own models** — See the Model Setup Guide below.
5. **Playtest** — Press Play in Studio and click the button!

---

## 📜 Script Overview

| # | File | What It Creates | Location |
|---|------|-----------------|----------|
| 01 | `01_Setup_RemoteEvents.lua` | All RemoteEvents folder | ReplicatedStorage |
| 02 | `02_Setup_ModuleScripts.lua` | UpgradeConfig, StageConfig, FormatNumber | ReplicatedStorage/Modules |
| 03 | `03_Server_DataManager.lua` | DataManager server script | ServerScriptService |
| 04 | `04_Server_ClickHandler.lua` | ClickHandler (anti-cheat) | ServerScriptService |
| 05 | `05_Server_UpgradeHandler.lua` | UpgradeHandler | ServerScriptService |
| 06 | `06_Server_PrestigeHandler.lua` | PrestigeHandler | ServerScriptService |
| 07 | `07_Server_WorldBuilder.lua` | WorldBuilder | ServerScriptService |
| 08 | `08_Server_EventManager.lua` | EventManager | ServerScriptService |
| 09 | `09_Server_LeaderboardManager.lua` | LeaderboardManager | ServerScriptService |
| 10 | `10_Server_GameManager.lua` | GameManager (master) | ServerScriptService |
| 11 | `11_Client_ClickController.lua` | ClickController LocalScript | StarterPlayerScripts |
| 12 | `12_Client_UIController.lua` | UIController LocalScript | StarterPlayerScripts |
| 13 | `13_Client_CameraController.lua` | CameraController LocalScript | StarterPlayerScripts |
| 14 | `14_Client_SoundController.lua` | SoundController LocalScript | StarterPlayerScripts |
| 15 | `15_Client_EventController.lua` | EventController LocalScript | StarterPlayerScripts |
| 16 | `16_Setup_ButtonModel.lua` | Placeholder button model | Workspace |
| 17 | `17_Setup_Workspace.lua` | Workspace folders + ServerStorage stage folders | Workspace / ServerStorage |

---

## 🏗️ Model Setup Guide

All scripts look for models **by name** inside specific folders. You create your own 3D models in Roblox Studio and place them in these locations:

### The Button (`Workspace/TheButton`)
Run `16_Setup_ButtonModel.lua` to create a placeholder. Replace the parts with your own design. Requirements:
- Must be named **`TheButton`** and live in **Workspace**
- Must contain a **`ClickDetector`** part (or the part itself needs a ClickDetector)
- Must contain a **`SurfaceGui`** named `ButtonGui` on the top surface

### World Stage Models (`ServerStorage/Stage_X_Name`)
Run `17_Setup_Workspace.lua` to create all 16 empty folders. Place your models inside them:

| Folder | Stage |
|--------|-------|
| `Stage_0_Void` | Empty — nothing spawns |
| `Stage_1_DirtPatch` | A rock, a flower, some grass |
| `Stage_2_Campfire` | Fire pit, logs, tent |
| `Stage_3_Hut` | Wooden hut, small farm |
| `Stage_4_Village` | Multiple huts, well, fences |
| `Stage_5_Town` | Stone buildings, market, roads |
| `Stage_6_Castle` | Castle walls, towers, moat |
| `Stage_7_Kingdom` | Sprawling city, cathedral, harbor |
| `Stage_8_Industrial` | Factories, smokestacks, trains |
| `Stage_9_ModernCity` | Skyscrapers, highways, airport |
| `Stage_10_Futuristic` | Neon towers, holograms, flying cars |
| `Stage_11_SpaceColony` | Launch pads, orbital ring |
| `Stage_12_GalacticEmpire` | Planet, fleet of ships |
| `Stage_13_Universe` | Cosmic web, nebulae |
| `Stage_14_Multiverse` | Fractal portals |
| `Stage_15_Singularity` | Pure white environment |

> **Tip:** Models in stage folders do NOT need to be anchored — WorldBuilder will position and tween them into place automatically. If a folder is empty, the game still works; it just shows an empty world for that stage.

### Upgrade Billboards (`Workspace/UpgradeBillboards`)
Place physical billboard/signpost models here. Each model should be named after the upgrade it represents (e.g., `StrongerFinger`, `AutoClicker`). The UIController will attach SurfaceGuis to them automatically.

### Event Objects (`ServerStorage/EventTemplates`)
Create models for random events:
- `MeteorTemplate` — a meteor rock model (clickable)
- `GiftBoxTemplate` — a gift box model (clickable)
- `VolcanoTemplate` — a volcano model

---

## 📖 Documentation

See [`docs/GAME_DESIGN_DOCUMENT.md`](docs/GAME_DESIGN_DOCUMENT.md) for the full Game Design Document including all upgrade values, stage thresholds, prestige formula, event tables, and development roadmap.

See [`scripts/README_SCRIPTS.md`](scripts/README_SCRIPTS.md) for detailed per-script instructions and troubleshooting.

---

## 🗂️ Project Structure

```
clickghmae/
├── README.md                         ← This file
├── docs/
│   └── GAME_DESIGN_DOCUMENT.md       ← Full GDD
└── scripts/
    ├── README_SCRIPTS.md             ← Detailed script usage guide
    ├── 01_Setup_RemoteEvents.lua
    ├── 02_Setup_ModuleScripts.lua
    ├── 03_Server_DataManager.lua
    ├── 04_Server_ClickHandler.lua
    ├── 05_Server_UpgradeHandler.lua
    ├── 06_Server_PrestigeHandler.lua
    ├── 07_Server_WorldBuilder.lua
    ├── 08_Server_EventManager.lua
    ├── 09_Server_LeaderboardManager.lua
    ├── 10_Server_GameManager.lua
    ├── 11_Client_ClickController.lua
    ├── 12_Client_UIController.lua
    ├── 13_Client_CameraController.lua
    ├── 14_Client_SoundController.lua
    ├── 15_Client_EventController.lua
    ├── 16_Setup_ButtonModel.lua
    └── 17_Setup_Workspace.lua
```

---

## 📅 Development Roadmap

| Phase | Deliverables |
|-------|-------------|
| **1. Core Loop** | Button + clicking + basic UI + data saving |
| **2. World Stages** | All 16 stages with models, transitions, sounds |
| **3. Upgrades** | All upgrade trees, SurfaceGui billboards |
| **4. Prestige** | Big Bang system, prestige upgrades, animation |
| **5. Events** | Random event system (all 7 events) |
| **6. Polish** | Achievements, leaderboards, cosmetics, monetization |
| **7. Playtesting** | Balance tuning, anti-cheat hardening |
| **8. Launch** | Publish + initial ads |

