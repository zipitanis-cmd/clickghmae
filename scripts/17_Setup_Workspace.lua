-- ONE BUTTON EMPIRE: Setup Workspace
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates all required Workspace folders and ServerStorage stage folders.
--
-- Run this AFTER 01_Setup_RemoteEvents.lua and 02_Setup_ModuleScripts.lua
-- but BEFORE playtesting.

local ServerStorage = game:GetService("ServerStorage")
local Lighting      = game:GetService("Lighting")

-- ─────────────────────────────────────────────────────────────────────────────
-- WORKSPACE FOLDERS
-- ─────────────────────────────────────────────────────────────────────────────

-- WorldModels: WorldBuilder places stage models here at runtime
local function ensureWorkspaceFolder(name)
    local existing = workspace:FindFirstChild(name)
    if existing then
        print("  ⚠️  Workspace/" .. name .. " already exists — keeping it.")
        return existing
    end
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = workspace
    print("  ✅ Created Workspace/" .. name)
    return folder
end

ensureWorkspaceFolder("WorldModels")
ensureWorkspaceFolder("UpgradeBillboards")
ensureWorkspaceFolder("EventObjects")

-- ─────────────────────────────────────────────────────────────────────────────
-- SERVERSTORAGE FOLDERS — One per world stage
-- Put your 3D models for each stage inside these folders!
-- ─────────────────────────────────────────────────────────────────────────────

local stageFolders = {
    -- { folderName,           description }
    {"Stage_0_Void",           "Stage 0: Empty — nothing spawns here"},
    {"Stage_1_DirtPatch",      "Stage 1: Dirt Patch — rocks, flowers, grass patches"},
    {"Stage_2_Campfire",       "Stage 2: Campfire — fire pit, logs, tent"},
    {"Stage_3_Hut",            "Stage 3: Hut — wooden hut, small farm, NPC villager"},
    {"Stage_4_Village",        "Stage 4: Village — multiple huts, well, fences, NPCs"},
    {"Stage_5_Town",           "Stage 5: Town — stone buildings, market, roads"},
    {"Stage_6_Castle",         "Stage 6: Castle — castle walls, towers, moat, knights"},
    {"Stage_7_Kingdom",        "Stage 7: Kingdom — sprawling city, cathedral, harbor"},
    {"Stage_8_Industrial",     "Stage 8: Industrial — factories, smokestacks, trains"},
    {"Stage_9_ModernCity",     "Stage 9: Modern City — skyscrapers, highways, airport"},
    {"Stage_10_Futuristic",    "Stage 10: Futuristic — neon towers, holograms, flying cars"},
    {"Stage_11_SpaceColony",   "Stage 11: Space Colony — launch pads, orbital ring"},
    {"Stage_12_GalacticEmpire","Stage 12: Galactic Empire — planet, fleet of ships"},
    {"Stage_13_Universe",      "Stage 13: Universe — cosmic web, nebulae"},
    {"Stage_14_Multiverse",    "Stage 14: Multiverse — fractal portals"},
    {"Stage_15_Singularity",   "Stage 15: THE SINGULARITY — pure white environment"},
    {"EventTemplates",         "Optional: MeteorTemplate, GiftBoxTemplate, VolcanoTemplate"},
    {"UpgradeBillboardTemplates", "Optional: template models for upgrade billboards"},
}

print("\n📁 Creating ServerStorage stage folders:")
for _, info in ipairs(stageFolders) do
    local folderName = info[1]
    local description = info[2]
    local existing = ServerStorage:FindFirstChild(folderName)
    if existing then
        print("  ⚠️  ServerStorage/" .. folderName .. " already exists — keeping it.")
    else
        local folder = Instance.new("Folder")
        folder.Name = folderName
        folder.Parent = ServerStorage
        print("  ✅ Created ServerStorage/" .. folderName)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- LIGHTING setup for stage atmosphere
-- ─────────────────────────────────────────────────────────────────────────────
Lighting.Ambient        = Color3.fromRGB(60, 60, 80)
Lighting.Brightness     = 2
Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
Lighting.TimeOfDay      = "14:00:00"

-- ─────────────────────────────────────────────────────────────────────────────
-- Print instructions for adding models
-- ─────────────────────────────────────────────────────────────────────────────
print("\n")
print("═══════════════════════════════════════════════════════════════")
print("✅ WORKSPACE SETUP COMPLETE!")
print("═══════════════════════════════════════════════════════════════")
print("")
print("NEXT STEPS:")
print("")
print("1. Add your 3D models to the stage folders in ServerStorage:")
for _, info in ipairs(stageFolders) do
    if info[1]:sub(1, 5) == "Stage" then
        print("   • ServerStorage/" .. info[1] .. " → " .. info[2])
    end
end
print("")
print("2. The WorldBuilder script will automatically clone models from")
print("   the appropriate folder when a player reaches each stage.")
print("")
print("3. For upgrade billboards:")
print("   • Create signpost/billboard models in Studio.")
print("   • Name each model after an upgrade (e.g. 'StrongerFinger').")
print("   • Parent them into Workspace/UpgradeBillboards.")
print("   • UIController will attach SurfaceGuis to them automatically.")
print("")
print("4. For event templates (optional — game works without them):")
print("   • Create model named 'MeteorTemplate' in ServerStorage/EventTemplates")
print("   • Create model named 'GiftBoxTemplate' in ServerStorage/EventTemplates")
print("   • Create model named 'VolcanoTemplate' in ServerStorage/EventTemplates")
print("")
print("TIP: You don't need to anchor models inside stage folders —")
print("     WorldBuilder handles positioning and tween animations!")
print("═══════════════════════════════════════════════════════════════")
