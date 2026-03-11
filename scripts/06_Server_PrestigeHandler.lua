-- ONE BUTTON EMPIRE: Server PrestigeHandler
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the PrestigeHandler Script in ServerScriptService

local scriptSource = [==[
-- PrestigeHandler: Handles the "Big Bang" prestige system
-- Runs as a server Script in ServerScriptService

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEvents then
    error("[PrestigeHandler] RemoteEvents not found in ReplicatedStorage!")
end
local triggerPrestigeEvent = remoteEvents:WaitForChild("TriggerPrestige")
local updateUIEvent        = remoteEvents:WaitForChild("UpdateUI")
local stageChangedEvent    = remoteEvents:WaitForChild("StageChanged")

-- ─────────────────────────────────────────────────────────────────────────────
-- Prestige star formula:
--   Stars Earned = floor( sqrt(totalClicksThisRun / 1,000,000) )
-- Big Bang Mastery adds +10% per level
-- VIP gamepass doubles stars earned
-- ─────────────────────────────────────────────────────────────────────────────
local function calculateStarsEarned(data)
    local base = math.floor(math.sqrt((data.totalClicksThisRun or 0) / 1000000))

    -- Big Bang Mastery: +10% per level
    local masteryLvl = data.prestigeUpgrades and data.prestigeUpgrades.bigBangMastery or 0
    local masteryBonus = 1 + (masteryLvl * 0.10)

    -- VIP gamepass: 2x prestige stars
    local vipBonus = (data.gamepasses and data.gamepasses.vip) and 2 or 1

    return math.floor(base * masteryBonus * vipBonus)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Calculate how many clicks the Starting Boost prestige upgrade banks
-- ─────────────────────────────────────────────────────────────────────────────
local function getStartingBoostClicks(data)
    local lvl = data.prestigeUpgrades and data.prestigeUpgrades.startingBoost or 0
    return lvl * 1000  -- 1000 banked clicks per level
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Perform the prestige reset
-- ─────────────────────────────────────────────────────────────────────────────
local function doPrestige(player)
    local dm = _G.DataManager
    if not dm then
        warn("[PrestigeHandler] DataManager not ready.")
        return false
    end

    local data = dm.getData(player)
    if not data then return false end

    -- Must be at least stage 10 to prestige
    if (data.currentStage or 0) < 10 then
        warn("[PrestigeHandler] " .. player.Name .. " tried to prestige from stage " .. tostring(data.currentStage))
        return false
    end

    -- Calculate stars to award
    local starsEarned = calculateStarsEarned(data)

    -- Cosmic Memory: retain a fraction of auto-click upgrade levels
    local cosmicMemoryLvl = data.prestigeUpgrades and data.prestigeUpgrades.cosmicMemory or 0
    local retainFraction  = cosmicMemoryLvl * 0.05  -- 5% per level
    local retainedAutoClicker = math.floor((data.upgrades.autoClicker or 0) * retainFraction)

    -- Starting Boost: bank some clicks for the new run
    local startingClicks = getStartingBoostClicks(data)

    -- ── Reset run-specific data ────────────────────────────────────────────────
    -- Keep: prestigeStars, prestigeUpgrades, achievements, cosmetics, stats, gamepasses
    -- Reset: clicks, totalClicksThisRun, currentStage, all normal upgrades

    data.prestigeStars = (data.prestigeStars or 0) + starsEarned
    data.stats.totalPrestiges = (data.stats.totalPrestiges or 0) + 1
    data.universeNumber = (data.universeNumber or 1) + 1

    -- Reset all normal upgrades
    data.upgrades = {
        strongerFinger   = 0,
        doubleTap        = 0,
        criticalMastery  = 0,
        criticalDamage   = 0,
        comboMaster      = 0,
        fingerOfGod      = 0,
        autoClicker      = retainedAutoClicker,  -- Cosmic Memory retention
        overclock        = 0,
        workerNPCs       = 0,
        robotArmy        = 0,
        quantumComputer  = 0,
        dysonSphere      = 0,
        fertileLand      = 0,
        timeWarp         = 0,
        luckyStars       = 0,
        goldenAge        = 0,
        parallelUniverse = 0,
    }

    data.clicks             = startingClicks
    data.totalClicksThisRun = startingClicks
    data.currentStage       = 0

    -- Notify clients: world resets to void, then update UI
    stageChangedEvent:FireAllClients(0, data.currentStage)
    updateUIEvent:FireClient(player, data)

    return true, starsEarned
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Listen for prestige requests from clients
-- ─────────────────────────────────────────────────────────────────────────────
triggerPrestigeEvent.OnServerEvent:Connect(function(player)
    local ok, starsEarned = pcall(doPrestige, player)
    if not ok then
        warn("[PrestigeHandler] Error during prestige for " .. player.Name .. ": " .. tostring(starsEarned))
    end
end)

print("[PrestigeHandler] Ready.")
]==]

local newScript = Instance.new("Script")
newScript.Name = "PrestigeHandler"
newScript.Source = scriptSource
newScript.Parent = game:GetService("ServerScriptService")
print("✅ PrestigeHandler Script created in ServerScriptService!")
