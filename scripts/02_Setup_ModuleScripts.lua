-- ONE BUTTON EMPIRE: Setup ModuleScripts
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the Modules folder in ReplicatedStorage with three ModuleScripts:
--   UpgradeConfig, StageConfig, FormatNumber

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remove existing Modules folder so this script is idempotent
local existing = ReplicatedStorage:FindFirstChild("Modules")
if existing then existing:Destroy() end

local modulesFolder = Instance.new("Folder")
modulesFolder.Name = "Modules"
modulesFolder.Parent = ReplicatedStorage

-- ─────────────────────────────────────────────────────────────────────────────
-- MODULE 1: UpgradeConfig
-- Contains all upgrade definitions for every upgrade tree in the game.
-- ─────────────────────────────────────────────────────────────────────────────
local upgradeConfigSource = [==[
-- UpgradeConfig: All upgrade definitions for One Button Empire
-- category values: "clickPower", "automation", "worldBooster", "prestige"

local UpgradeConfig = {
    -- ──────────────────────────────────────────────────────────────
    -- CLICK POWER upgrades (shown on Red Billboards)
    -- ──────────────────────────────────────────────────────────────
    strongerFinger = {
        displayName   = "Stronger Finger",
        category      = "clickPower",
        maxLevel      = 25,
        baseCost      = 15,
        costScaling   = 1.5,
        effectPerLevel = 1,  -- +1 click power per level
        description   = "Your clicking finger grows mighty.",
    },
    doubleTap = {
        displayName   = "Double Tap",
        category      = "clickPower",
        maxLevel      = 10,
        baseCost      = 500,
        costScaling   = 2.0,
        effectPerLevel = 0.10,  -- +10% chance to double a click per level
        description   = "Sometimes one click just isn't enough.",
    },
    criticalMastery = {
        displayName   = "Critical Mastery",
        category      = "clickPower",
        maxLevel      = 10,
        baseCost      = 2000,
        costScaling   = 2.5,
        effectPerLevel = 0.02,  -- +2% crit chance per level (base 5%)
        description   = "Train your finger to strike true.",
    },
    criticalDamage = {
        displayName   = "Critical Damage",
        category      = "clickPower",
        maxLevel      = 10,
        baseCost      = 5000,
        costScaling   = 3.0,
        effectPerLevel = 4,   -- crits scale from 10x toward 50x (+4 multiplier per level)
        description   = "Crits hit harder and harder.",
    },
    comboMaster = {
        displayName   = "Combo Master",
        category      = "clickPower",
        maxLevel      = 5,
        baseCost      = 20000,
        costScaling   = 4.0,
        effectPerLevel = 0.5,  -- combo max +0.5x per level (base 2x max)
        description   = "Keep clicking and the multiplier grows.",
    },
    fingerOfGod = {
        displayName   = "Finger of God",
        category      = "clickPower",
        maxLevel      = 1,
        baseCost      = 10000000,
        costScaling   = 1,
        effectPerLevel = 100,  -- each click counts as 100 clicks
        description   = "Transcend mortal clicking limits.",
    },

    -- ──────────────────────────────────────────────────────────────
    -- AUTOMATION upgrades (shown on Blue Billboards)
    -- ──────────────────────────────────────────────────────────────
    autoClicker = {
        displayName   = "Auto Clicker",
        category      = "automation",
        maxLevel      = 25,
        baseCost      = 100,
        costScaling   = 1.8,
        effectPerLevel = 1,  -- +1 click/sec per level
        description   = "A mechanical finger helps you out.",
    },
    overclock = {
        displayName   = "Overclock",
        category      = "automation",
        maxLevel      = 10,
        baseCost      = 5000,
        costScaling   = 2.5,
        effectPerLevel = 0.10,  -- auto 10% faster per level
        description   = "Push the auto-clicker beyond its limits.",
    },
    workerNPCs = {
        displayName   = "Worker NPCs",
        category      = "automation",
        maxLevel      = 15,
        baseCost      = 2000,
        costScaling   = 2.0,
        effectPerLevel = 1,  -- each level spawns 1 NPC that clicks periodically
        description   = "Hire workers to click for you.",
    },
    robotArmy = {
        displayName   = "Robot Army",
        category      = "automation",
        maxLevel      = 10,
        baseCost      = 50000,
        costScaling   = 3.0,
        effectPerLevel = 10,  -- +10 clicks/sec per level
        description   = "Deploy mechanical clicking soldiers.",
    },
    quantumComputer = {
        displayName   = "Quantum Computer",
        category      = "automation",
        maxLevel      = 5,
        baseCost      = 500000,
        costScaling   = 5.0,
        effectPerLevel = 1,  -- auto clicks are squared instead of linear
        description   = "Harness quantum superposition.",
    },
    dysonSphere = {
        displayName   = "Dyson Sphere",
        category      = "automation",
        maxLevel      = 1,
        baseCost      = 50000000,
        costScaling   = 1,
        effectPerLevel = 1000000,  -- +1,000,000 clicks/sec
        description   = "Harness an entire star's energy.",
    },

    -- ──────────────────────────────────────────────────────────────
    -- WORLD BOOSTER upgrades (shown on Green Billboards)
    -- ──────────────────────────────────────────────────────────────
    fertileLand = {
        displayName   = "Fertile Land",
        category      = "worldBooster",
        maxLevel      = 10,
        baseCost      = 300,
        costScaling   = 2.0,
        effectPerLevel = 0.10,  -- stage transitions cost 10% fewer clicks per level
        description   = "The land blesses your empire.",
    },
    timeWarp = {
        displayName   = "Time Warp",
        category      = "worldBooster",
        maxLevel      = 5,
        baseCost      = 10000,
        costScaling   = 3.0,
        effectPerLevel = 1,  -- earn 1 min of auto-income on activation (5 min cooldown)
        description   = "Bend time to your will.",
    },
    luckyStars = {
        displayName   = "Lucky Stars",
        category      = "worldBooster",
        maxLevel      = 10,
        baseCost      = 8000,
        costScaling   = 2.5,
        effectPerLevel = 0.05,  -- events 5% more frequent per level
        description   = "Fortune smiles upon you.",
    },
    goldenAge = {
        displayName   = "Golden Age",
        category      = "worldBooster",
        maxLevel      = 5,
        baseCost      = 25000,
        costScaling   = 4.0,
        effectPerLevel = 1,  -- 2x income for 30s on activation (10 min cooldown)
        description   = "Declare a golden age.",
    },
    parallelUniverse = {
        displayName   = "Parallel Universe",
        category      = "worldBooster",
        maxLevel      = 1,
        baseCost      = 5000000,
        costScaling   = 1,
        effectPerLevel = 1,  -- unlock a second passive-income world
        description   = "Tap into alternate realities.",
    },

    -- ──────────────────────────────────────────────────────────────
    -- PRESTIGE upgrades (shown on Gold Billboards, visible after first prestige)
    -- Cost is in Prestige Stars (⭐), not regular clicks
    -- ──────────────────────────────────────────────────────────────
    startingBoost = {
        displayName   = "Starting Boost",
        category      = "prestige",
        maxLevel      = 10,
        baseCost      = 1,   -- 1 prestige star per level
        costScaling   = 1,
        effectPerLevel = 1,  -- start each universe with X banked clicks (per level * 1000)
        description   = "Hit the ground running each universe.",
    },
    cosmicMemory = {
        displayName   = "Cosmic Memory",
        category      = "prestige",
        maxLevel      = 10,
        baseCost      = 2,   -- 2 prestige stars per level
        costScaling   = 1,
        effectPerLevel = 0.05,  -- retain 5% of auto-click speed per level on prestige
        description   = "Your fingers remember the old ways.",
    },
    starPower = {
        displayName   = "Star Power",
        category      = "prestige",
        maxLevel      = 25,
        baseCost      = 1,   -- 1 prestige star per level
        costScaling   = 1,
        effectPerLevel = 0.05,  -- +5% ALL production per level
        description   = "Starlight fuels your empire.",
    },
    universalKnowledge = {
        displayName   = "Universal Knowledge",
        category      = "prestige",
        maxLevel      = 5,
        baseCost      = 3,   -- 3 prestige stars per level
        costScaling   = 1,
        effectPerLevel = 1,  -- unlock upgrade tiers 1 stage earlier per level
        description   = "Knowledge transcends universes.",
    },
    bigBangMastery = {
        displayName   = "Big Bang Mastery",
        category      = "prestige",
        maxLevel      = 10,
        baseCost      = 5,   -- 5 prestige stars per level
        costScaling   = 1,
        effectPerLevel = 0.10,  -- +10% prestige stars earned per level
        description   = "Master the art of universal rebirth.",
    },
    multiverseTheory = {
        displayName   = "Multiverse Theory",
        category      = "prestige",
        maxLevel      = 1,
        baseCost      = 50,  -- 50 prestige stars
        costScaling   = 1,
        effectPerLevel = 1,  -- run 2 universes simultaneously
        description   = "Theoretical physics made real.",
    },
}

-- Helper: calculate the cost of the next level for a given upgrade
-- Formula: baseCost * (costScaling ^ currentLevel)
function UpgradeConfig.getNextCost(upgradeId, currentLevel)
    local cfg = UpgradeConfig[upgradeId]
    if not cfg then return math.huge end
    return math.floor(cfg.baseCost * (cfg.costScaling ^ currentLevel))
end

return UpgradeConfig
]==]

-- ─────────────────────────────────────────────────────────────────────────────
-- MODULE 2: StageConfig
-- Contains all 16 world stage definitions.
-- ─────────────────────────────────────────────────────────────────────────────
local stageConfigSource = [==[
-- StageConfig: All 16 world stage definitions for One Button Empire
--
-- HOW MODELS WORK:
--   Each stage has a "modelFolder" field.
--   The WorldBuilder script looks in ServerStorage for a Folder with that name.
--   It then clones everything inside that folder into Workspace/WorldModels.
--
--   TO USE YOUR OWN MODELS:
--   1. Run 17_Setup_Workspace.lua to create all the empty folders in ServerStorage.
--   2. Build or import your models in Studio.
--   3. Move each model into the correct ServerStorage folder.
--   4. The WorldBuilder will find and spawn them automatically on stage transition.
--
--   TIP: You can put as many models as you want in each folder.
--        If a folder is empty, the world will simply be empty for that stage.

local StageConfig = {
    [0] = {
        name         = "Void",
        clicksNeeded = 0,
        modelFolder  = "Stage_0_Void",
        description  = "Empty dark baseplate, single glowing button.",
        soundTheme   = "void",
    },
    [1] = {
        name         = "Dirt Patch",
        clicksNeeded = 10,
        modelFolder  = "Stage_1_DirtPatch",
        description  = "Grass appears, dirt path. A rock, a flower.",
        soundTheme   = "nature",
    },
    [2] = {
        name         = "Campfire",
        clicksNeeded = 50,
        modelFolder  = "Stage_2_Campfire",
        description  = "Fire pit, logs, tent. Smoke particles, crickets.",
        soundTheme   = "nature",
    },
    [3] = {
        name         = "Hut",
        clicksNeeded = 200,
        modelFolder  = "Stage_3_Hut",
        description  = "Wooden hut, small farm. 1 NPC villager.",
        soundTheme   = "medieval",
    },
    [4] = {
        name         = "Village",
        clicksNeeded = 1000,
        modelFolder  = "Stage_4_Village",
        description  = "Multiple huts, well, fences. 5-10 NPCs, animals.",
        soundTheme   = "medieval",
    },
    [5] = {
        name         = "Town",
        clicksNeeded = 5000,
        modelFolder  = "Stage_5_Town",
        description  = "Stone buildings, market, roads. Carts, merchants.",
        soundTheme   = "medieval",
    },
    [6] = {
        name         = "Castle",
        clicksNeeded = 25000,
        modelFolder  = "Stage_6_Castle",
        description  = "Castle walls, towers, moat. Knights, flags.",
        soundTheme   = "medieval",
    },
    [7] = {
        name         = "Kingdom",
        clicksNeeded = 100000,
        modelFolder  = "Stage_7_Kingdom",
        description  = "Sprawling city, cathedral, harbor. Ships, armies.",
        soundTheme   = "medieval",
    },
    [8] = {
        name         = "Industrial",
        clicksNeeded = 500000,
        modelFolder  = "Stage_8_Industrial",
        description  = "Factories, smokestacks, trains. Steam, moving trains.",
        soundTheme   = "industrial",
    },
    [9] = {
        name         = "Modern City",
        clicksNeeded = 2000000,
        modelFolder  = "Stage_9_ModernCity",
        description  = "Skyscrapers, highways, airport. Cars, planes.",
        soundTheme   = "modern",
    },
    [10] = {
        name         = "Futuristic",
        clicksNeeded = 10000000,
        modelFolder  = "Stage_10_Futuristic",
        description  = "Neon towers, holograms, flying cars. Drones.",
        soundTheme   = "synthwave",
    },
    [11] = {
        name         = "Space Colony",
        clicksNeeded = 50000000,
        modelFolder  = "Stage_11_SpaceColony",
        description  = "Launch pads, orbital ring. Rockets launching.",
        soundTheme   = "space",
    },
    [12] = {
        name         = "Galactic Empire",
        clicksNeeded = 250000000,
        modelFolder  = "Stage_12_GalacticEmpire",
        description  = "Entire planet visible, fleet of ships. Starships.",
        soundTheme   = "cosmic",
    },
    [13] = {
        name         = "Universe",
        clicksNeeded = 1000000000,
        modelFolder  = "Stage_13_Universe",
        description  = "Cosmic web of galaxies. Stars being born, nebulae.",
        soundTheme   = "cosmic",
    },
    [14] = {
        name         = "Multiverse",
        clicksNeeded = 10000000000,
        modelFolder  = "Stage_14_Multiverse",
        description  = "Fractal infinite portals. Portals to other saves.",
        soundTheme   = "cosmic",
    },
    [15] = {
        name         = "THE SINGULARITY",
        clicksNeeded = 100000000000,
        modelFolder  = "Stage_15_Singularity",
        description  = "Pure white light, the button ascends. Prestige trigger.",
        soundTheme   = "singularity",
    },
}

-- Returns the stage index the player should be at for the given click count
function StageConfig.getStageForClicks(clicks)
    local stage = 0
    for i = 15, 0, -1 do
        local cfg = StageConfig[i]
        if cfg and clicks >= cfg.clicksNeeded then
            stage = i
            break
        end
    end
    return stage
end

return StageConfig
]==]

-- ─────────────────────────────────────────────────────────────────────────────
-- MODULE 3: FormatNumber
-- Formats large numbers into human-readable strings.
-- ─────────────────────────────────────────────────────────────────────────────
local formatNumberSource = [==[
-- FormatNumber: Converts large numbers to readable strings
-- Examples:
--   1523          → "1.5K"
--   2500000       → "2.5M"
--   13700000000   → "13.7B"
--   0             → "0"

local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}

local function FormatNumber(n)
    if type(n) ~= "number" or n ~= n then return "0" end  -- NaN guard
    n = math.max(0, n)
    if n < 1000 then
        return tostring(math.floor(n))
    end
    local tier = math.floor(math.log10(n) / 3)
    tier = math.min(tier, #suffixes - 1)
    local scaled = n / (10 ^ (tier * 3))
    return string.format("%.1f%s", scaled, suffixes[tier + 1])
end

return FormatNumber
]==]

-- ─────────────────────────────────────────────────────────────────────────────
-- Create all three ModuleScripts
-- ─────────────────────────────────────────────────────────────────────────────
local function createModule(name, source)
    local m = Instance.new("ModuleScript")
    m.Name = name
    m.Source = source
    m.Parent = modulesFolder
    print("  ✅ Created ModuleScript: " .. name)
end

createModule("UpgradeConfig", upgradeConfigSource)
createModule("StageConfig", stageConfigSource)
createModule("FormatNumber", formatNumberSource)

print("✅ Modules folder created in ReplicatedStorage with 3 ModuleScripts!")
