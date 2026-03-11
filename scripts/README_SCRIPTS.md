# 📜 One Button Empire — Scripts Usage Guide

All files in this `scripts/` folder are **paste-ready Lua scripts** for **Roblox Studio's Command Bar**.

---

## How to Use

1. Open Roblox Studio and have your place file open.
2. Go to **View > Command Bar** to open the Command Bar at the bottom of the screen.
3. Open a script file from this folder in a text editor.
4. **Select all** the text and **copy** it.
5. **Paste** it into the Command Bar.
6. Press **Enter** to run it.
7. Check the Output window — you should see a ✅ success message.

> ⚠️ **Run scripts 01 and 02 first** — they create the folders and modules that all server and client scripts (03–15) depend on. Scripts 03–15 are otherwise independent of each other and can be run in any order. Script 16 (button model) and script 17 (workspace setup) can also be run independently at any time.

---

## Script Reference

| # | File | Creates | Parent Location |
|---|------|---------|-----------------|
| 01 | `01_Setup_RemoteEvents.lua` | `RemoteEvents` folder + all events | `ReplicatedStorage` |
| 02 | `02_Setup_ModuleScripts.lua` | `Modules` folder + UpgradeConfig, StageConfig, FormatNumber | `ReplicatedStorage` |
| 03 | `03_Server_DataManager.lua` | `DataManager` Script | `ServerScriptService` |
| 04 | `04_Server_ClickHandler.lua` | `ClickHandler` Script | `ServerScriptService` |
| 05 | `05_Server_UpgradeHandler.lua` | `UpgradeHandler` Script | `ServerScriptService` |
| 06 | `06_Server_PrestigeHandler.lua` | `PrestigeHandler` Script | `ServerScriptService` |
| 07 | `07_Server_WorldBuilder.lua` | `WorldBuilder` Script | `ServerScriptService` |
| 08 | `08_Server_EventManager.lua` | `EventManager` Script | `ServerScriptService` |
| 09 | `09_Server_LeaderboardManager.lua` | `LeaderboardManager` Script | `ServerScriptService` |
| 10 | `10_Server_GameManager.lua` | `GameManager` Script | `ServerScriptService` |
| 11 | `11_Client_ClickController.lua` | `ClickController` LocalScript | `StarterPlayerScripts` |
| 12 | `12_Client_UIController.lua` | `UIController` LocalScript | `StarterPlayerScripts` |
| 13 | `13_Client_CameraController.lua` | `CameraController` LocalScript | `StarterPlayerScripts` |
| 14 | `14_Client_SoundController.lua` | `SoundController` LocalScript | `StarterPlayerScripts` |
| 15 | `15_Client_EventController.lua` | `EventController` LocalScript | `StarterPlayerScripts` |
| 16 | `16_Setup_ButtonModel.lua` | `TheButton` Model placeholder | `Workspace` |
| 17 | `17_Setup_Workspace.lua` | World folders + Stage folders | `Workspace` / `ServerStorage` |

---

## Model Naming Conventions

All scripts reference models **by name**. Follow these naming conventions exactly:

### Button
- Name: `TheButton` in `Workspace`
- Must contain a `ClickDetector` (in any descendant part)
- Must contain a part with a `SurfaceGui` named `ButtonGui`

### Stage Models (in `ServerStorage`)
Folders are named `Stage_X_Name` where X is the stage number:
```
Stage_0_Void
Stage_1_DirtPatch
Stage_2_Campfire
Stage_3_Hut
Stage_4_Village
Stage_5_Town
Stage_6_Castle
Stage_7_Kingdom
Stage_8_Industrial
Stage_9_ModernCity
Stage_10_Futuristic
Stage_11_SpaceColony
Stage_12_GalacticEmpire
Stage_13_Universe
Stage_14_Multiverse
Stage_15_Singularity
```

Place **any models** you want inside these folders. The WorldBuilder script will:
1. Delete all existing models from `Workspace/WorldModels`
2. Clone all models from the new stage's folder into `Workspace/WorldModels`
3. Tween each part's size from 0 to its original size (build-in animation)

**You do not need to anchor models** — WorldBuilder handles positioning.

### Upgrade Billboards (in `Workspace/UpgradeBillboards`)
Place physical billboard/signpost models. Naming is flexible — UIController will attach SurfaceGuis dynamically.

### Event Templates (in `ServerStorage/EventTemplates`)
Optional model templates for events:
- `MeteorTemplate` — clickable meteor rock
- `GiftBoxTemplate` — clickable gift box
- `VolcanoTemplate` — volcano model

---

## Troubleshooting

### "Script already exists" error
Some scripts check for existing instances. If you get an error about a duplicate, delete the existing script/folder in the Explorer panel and re-run.

### Button not responding to clicks
1. Make sure `TheButton` model exists in `Workspace`
2. Make sure a `ClickDetector` exists inside the model
3. Make sure `ClickController` LocalScript is in `StarterPlayerScripts`
4. Check the Output window for error messages

### World not building on stage change
1. Make sure `WorldBuilder` script is in `ServerScriptService`
2. Make sure `Workspace/WorldModels` folder exists (run `17_Setup_Workspace.lua`)
3. If a stage folder in `ServerStorage` is empty, the world will just be empty — this is OK

### Data not saving
1. Make sure `DataManager` script is in `ServerScriptService`
2. In Studio, go to **Game Settings > Security** and enable **Studio Access to API Services**
3. DataStore won't work in offline mode — test with the full Roblox server

### UI not updating
1. Make sure `UIController` LocalScript is in `StarterPlayerScripts`
2. Make sure `RemoteEvents/UpdateUI` RemoteEvent exists in `ReplicatedStorage`
3. Check that `ButtonGui` SurfaceGui exists on `TheButton`

---

## Gamepass IDs

After creating gamepasses on the Roblox website, update these IDs in `ClickHandler` (script 04) and `PrestigeHandler` (script 06):

```lua
local GAMEPASS_IDS = {
    doubleClicks = 0,  -- Replace with your actual gamepass ID
    doubleAuto   = 0,  -- Replace with your actual gamepass ID
    vip          = 0,  -- Replace with your actual gamepass ID
    lucky        = 0,  -- Replace with your actual gamepass ID
}
```

Find these constants at the top of the relevant server scripts.

---

## Sound IDs

The `SoundController` (script 14) uses placeholder sound IDs. Replace them with your own:
- Find free sounds at the Roblox Sound Library
- Or purchase/create sounds and get their Asset IDs
- Update the `SOUND_IDS` table at the top of the SoundController source

---

## Re-Running Scripts

It is safe to re-run any setup script. They will either replace the existing instance or print a warning. However, re-running server/client scripts (03–15) while the game is running will create duplicate scripts — delete old ones from Explorer first.
