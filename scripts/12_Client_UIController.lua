-- ONE BUTTON EMPIRE: Client UIController
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the UIController LocalScript in StarterPlayerScripts

local scriptSource = [==[
-- UIController: Listens for UpdateUI events and refreshes all SurfaceGuis in the world.
-- Handles button SurfaceGui, upgrade billboard SurfaceGuis, prestige orb, and leaderboard.
-- Runs as a LocalScript in StarterPlayerScripts

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local updateUIEvent = remoteEvents:WaitForChild("UpdateUI")

-- Wait for modules
local modules       = ReplicatedStorage:WaitForChild("Modules", 10)
local UpgradeConfig = require(modules:WaitForChild("UpgradeConfig"))
local FormatNumber  = require(modules:WaitForChild("FormatNumber"))
local StageConfig   = require(modules:WaitForChild("StageConfig"))

-- ─────────────────────────────────────────────────────────────────────────────
-- Utility: find or create a SurfaceGui on a part
-- ─────────────────────────────────────────────────────────────────────────────
local function getOrCreateSurfaceGui(part, name)
    local gui = part:FindFirstChild(name)
    if gui and gui:IsA("SurfaceGui") then return gui end
    gui = Instance.new("SurfaceGui")
    gui.Name = name
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 50
    gui.Parent = part
    return gui
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Utility: find or create a TextLabel inside a SurfaceGui
-- ─────────────────────────────────────────────────────────────────────────────
local function getOrCreateLabel(parent, name, pos, size, fontSize)
    local lbl = parent:FindFirstChild(name)
    if not lbl then
        lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.BackgroundTransparency = 1
        lbl.Position = pos or UDim2.new(0, 0, 0, 0)
        lbl.Size = size or UDim2.new(1, 0, 0.2, 0)
        lbl.TextScaled = false
        lbl.TextSize = fontSize or 18
        lbl.Font = Enum.Font.GothamBold
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.Parent = parent
    end
    return lbl
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Update the button's SurfaceGui with current stats
-- The button model must be named "TheButton" in Workspace and contain
-- a SurfaceGui named "ButtonGui"
-- ─────────────────────────────────────────────────────────────────────────────
local function updateButtonGui(data)
    local button = workspace:FindFirstChild("TheButton")
    if not button then return end

    -- Look for a part that has the SurfaceGui, or use any BasePart
    local guiPart = button:FindFirstChildWhichIsA("BasePart", true)
    if not guiPart then return end

    local gui = getOrCreateSurfaceGui(guiPart, "ButtonGui")

    -- Auto rate calculation (for display)
    local autoRate = (data.upgrades.autoClicker or 0)
        + (data.upgrades.robotArmy or 0) * 10
        + ((data.upgrades.dysonSphere or 0) >= 1 and 1000000 or 0)
    local overclockBonus = 1 + ((data.upgrades.overclock or 0) * 0.10)
    autoRate = math.floor(autoRate * overclockBonus)

    -- Click power (simple display version)
    local clickPower = 1 + (data.upgrades.strongerFinger or 0)

    -- Stage name
    local stageCfg = StageConfig[data.currentStage or 0]
    local stageName = stageCfg and stageCfg.name or "Void"

    -- Layout
    local labels = {
        {"Stage",    "⚡ Stage: " .. stageName,                    UDim2.new(0,0,0.00,0), UDim2.new(1,0,0.18,0), 16},
        {"Clicks",   "🖱 Clicks: " .. FormatNumber(data.clicks),   UDim2.new(0,0,0.18,0), UDim2.new(1,0,0.20,0), 20},
        {"ClickBtn", "[ CLICK ME ]",                               UDim2.new(0,0,0.38,0), UDim2.new(1,0,0.24,0), 22},
        {"Power",    "+" .. FormatNumber(clickPower) .. " per click", UDim2.new(0,0,0.62,0), UDim2.new(1,0,0.18,0), 14},
        {"Auto",     "+" .. FormatNumber(autoRate) .. "/sec auto", UDim2.new(0,0,0.80,0), UDim2.new(1,0,0.18,0), 14},
    }
    for _, info in ipairs(labels) do
        local lbl = getOrCreateLabel(gui, info[1], info[3], info[4], info[5])
        lbl.Text = info[2]
        -- Color the CLICK ME button yellow
        if info[1] == "ClickBtn" then
            lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Update upgrade billboards
-- Expects models in Workspace/UpgradeBillboards folder
-- Each model should be a BasePart or Model named anything; UIController
-- attaches SurfaceGuis to the first BasePart it finds in each billboard.
--
-- HOW TO SET UP UPGRADE BILLBOARDS:
--   1. Run 17_Setup_Workspace.lua to create the UpgradeBillboards folder.
--   2. Create physical billboard/signpost models in Studio.
--   3. For each upgrade, create a Model named after the upgrade (e.g. "StrongerFinger").
--   4. Parent those models into Workspace/UpgradeBillboards.
--   5. This script will attach SurfaceGuis to them automatically.
-- ─────────────────────────────────────────────────────────────────────────────
local UPGRADE_ID_MAP = {
    -- Maps model name → upgrade ID in UpgradeConfig
    StrongerFinger   = "strongerFinger",
    DoubleTap        = "doubleTap",
    CriticalMastery  = "criticalMastery",
    CriticalDamage   = "criticalDamage",
    ComboMaster      = "comboMaster",
    FingerOfGod      = "fingerOfGod",
    AutoClicker      = "autoClicker",
    Overclock        = "overclock",
    WorkerNPCs       = "workerNPCs",
    RobotArmy        = "robotArmy",
    QuantumComputer  = "quantumComputer",
    DysonSphere      = "dysonSphere",
    FertileLand      = "fertileLand",
    TimeWarp         = "timeWarp",
    LuckyStars       = "luckyStars",
    GoldenAge        = "goldenAge",
    ParallelUniverse = "parallelUniverse",
    -- Prestige upgrades
    StartingBoost      = "startingBoost",
    CosmicMemory       = "cosmicMemory",
    StarPower          = "starPower",
    UniversalKnowledge = "universalKnowledge",
    BigBangMastery     = "bigBangMastery",
    MultiverseTheory   = "multiverseTheory",
}

-- Category billboard colors
local CATEGORY_COLORS = {
    clickPower   = Color3.fromRGB(255, 80, 80),
    automation   = Color3.fromRGB(80, 150, 255),
    worldBooster = Color3.fromRGB(80, 200, 100),
    prestige     = Color3.fromRGB(255, 215, 0),
}

local function updateUpgradeBillboards(data)
    local billboardsFolder = workspace:FindFirstChild("UpgradeBillboards")
    if not billboardsFolder then return end

    for _, model in ipairs(billboardsFolder:GetChildren()) do
        local upgradeId = UPGRADE_ID_MAP[model.Name]
        if not upgradeId then continue end

        local cfg = UpgradeConfig[upgradeId]
        if not cfg then continue end

        -- Find a part to put the GUI on (front face of first BasePart)
        local part = model:FindFirstChildWhichIsA("BasePart")
        if not model:IsA("BasePart") then
            -- model is a Model container
        else
            part = model
        end
        if not part then continue end

        local gui = getOrCreateSurfaceGui(part, "UpgradeGui")
        local catColor = CATEGORY_COLORS[cfg.category] or Color3.new(1,1,1)

        -- Determine current level
        local upgradeTable = cfg.category == "prestige" and data.prestigeUpgrades or data.upgrades
        local currentLevel = upgradeTable and upgradeTable[upgradeId] or 0
        local maxLevel     = cfg.maxLevel
        local isMaxed      = currentLevel >= maxLevel

        -- Calculate cost
        local cost = math.floor(cfg.baseCost * (cfg.costScaling ^ currentLevel))
        local costStr = cfg.category == "prestige"
            and FormatNumber(cost) .. " ⭐"
            or  FormatNumber(cost) .. " clicks"

        -- Progress bar (text-based)
        local barLen  = 12
        local filled  = math.floor((currentLevel / maxLevel) * barLen)
        local bar     = string.rep("█", filled) .. string.rep("░", barLen - filled)

        -- Display name with category color indicator
        local prefix = cfg.category == "prestige" and "💎 " or ""

        local labels = {
            {"Title",   prefix .. cfg.displayName,                              UDim2.new(0,0,0.00,0), UDim2.new(1,0,0.15,0), 14},
            {"Level",   "Level: " .. currentLevel .. " / " .. maxLevel,         UDim2.new(0,0,0.15,0), UDim2.new(1,0,0.12,0), 12},
            {"Bar",     bar,                                                    UDim2.new(0,0,0.27,0), UDim2.new(1,0,0.10,0), 11},
            {"Effect",  "Effect: " .. FormatNumber(cfg.effectPerLevel) .. "/lvl",UDim2.new(0,0,0.37,0), UDim2.new(1,0,0.13,0), 11},
            {"Cost",    isMaxed and "MAX LEVEL" or "Cost: " .. costStr,         UDim2.new(0,0,0.50,0), UDim2.new(1,0,0.15,0), 13},
            {"Btn",     isMaxed and "✅ MAXED" or "[ UPGRADE ]",               UDim2.new(0,0,0.65,0), UDim2.new(1,0,0.18,0), 14},
            {"Desc",    cfg.description,                                        UDim2.new(0,0,0.83,0), UDim2.new(1,0,0.17,0), 10},
        }
        for _, info in ipairs(labels) do
            local lbl = getOrCreateLabel(gui, info[1], info[3], info[4], info[5])
            lbl.Text = info[2]
            lbl.TextColor3 = (info[1] == "Title") and catColor
                or (info[1] == "Btn" and not isMaxed) and Color3.fromRGB(255, 215, 0)
                or Color3.new(1, 1, 1)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Update the prestige orb SurfaceGui
-- Looks for a part named "PrestigeOrb" in Workspace
-- ─────────────────────────────────────────────────────────────────────────────
local function updatePrestigeOrb(data)
    local orb = workspace:FindFirstChild("PrestigeOrb")
    if not orb then return end

    local part = orb:IsA("BasePart") and orb or orb:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local gui = getOrCreateSurfaceGui(part, "PrestigeGui")

    local starsWillEarn = math.floor(math.sqrt((data.totalClicksThisRun or 0) / 1000000))
    local currentBoost  = 1 + ((data.prestigeStars or 0) * 0.10)
    local eligible      = (data.currentStage or 0) >= 10

    local labels = {
        {"Title",  "💥 THE BIG BANG 💥",            UDim2.new(0,0,0.00,0), UDim2.new(1,0,0.18,0), 14},
        {"Earn",   "You will earn: " .. starsWillEarn .. " ⭐", UDim2.new(0,0,0.18,0), UDim2.new(1,0,0.15,0), 12},
        {"Owned",  "Stars: " .. (data.prestigeStars or 0) .. " ⭐", UDim2.new(0,0,0.33,0), UDim2.new(1,0,0.15,0), 12},
        {"Boost",  "Boost: ×" .. string.format("%.1f", currentBoost),       UDim2.new(0,0,0.48,0), UDim2.new(1,0,0.15,0), 13},
        {"Btn",    eligible and "[ 🔥 BIG BANG 🔥 ]" or "Need Stage 10+",   UDim2.new(0,0,0.63,0), UDim2.new(1,0,0.20,0), 13},
        {"Warn",   "⚠ Resets all except prestige",  UDim2.new(0,0,0.83,0), UDim2.new(1,0,0.17,0), 10},
    }
    for _, info in ipairs(labels) do
        local lbl = getOrCreateLabel(gui, info[1], info[3], info[4], info[5])
        lbl.Text = info[2]
        lbl.TextColor3 = (info[1] == "Btn" and eligible) and Color3.fromRGB(255, 100, 0)
            or (info[1] == "Title") and Color3.fromRGB(255, 215, 0)
            or Color3.new(1, 1, 1)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Main UpdateUI handler — called whenever server sends fresh data
-- ─────────────────────────────────────────────────────────────────────────────
updateUIEvent.OnClientEvent:Connect(function(data)
    if not data then return end

    local ok, err = pcall(function()
        updateButtonGui(data)
        updateUpgradeBillboards(data)
        updatePrestigeOrb(data)
    end)
    if not ok then
        warn("[UIController] Error updating UI: " .. tostring(err))
    end
end)

print("[UIController] Ready. Waiting for UpdateUI events.")
]==]

local newScript = Instance.new("LocalScript")
newScript.Name = "UIController"
newScript.Source = scriptSource
newScript.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
print("✅ UIController LocalScript created in StarterPlayerScripts!")
