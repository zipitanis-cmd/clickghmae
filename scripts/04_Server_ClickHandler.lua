-- ONE BUTTON EMPIRE: Server ClickHandler
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the ClickHandler Script in ServerScriptService (anti-cheat)

local scriptSource = [==[
-- ClickHandler: Validates and processes all click events from clients
-- Includes anti-cheat, combo system, critical hits, and stage detection
-- Runs as a server Script in ServerScriptService

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- ─────────────────────────────────────────────────────────────────────────────
-- GAMEPASS IDs — Replace 0 with your actual Roblox gamepass asset IDs
-- Create gamepasses at: https://create.roblox.com > your game > Monetization
-- ─────────────────────────────────────────────────────────────────────────────
local GAMEPASS_IDS = {
    doubleClicks = 0,  -- "2x Clicks" gamepass ID
    doubleAuto   = 0,  -- "2x Auto" gamepass ID
    vip          = 0,  -- "VIP" gamepass ID
    lucky        = 0,  -- "Lucky" gamepass ID
}

-- Anti-cheat threshold — humans cannot physically click faster than this
local MAX_CLICKS_PER_SECOND = 25

-- Per-player state
local clickTimestamps = {}  -- anti-cheat: recent click times per player
local comboData       = {}  -- combo multiplier state per player

-- Config constants
local BASE_CRIT_CHANCE  = 0.05   -- 5% base critical chance
local BASE_CRIT_MULT    = 10     -- base 10x critical multiplier
local COMBO_WINDOW      = 0.3    -- seconds between clicks to build combo
local COMBO_DECAY_TIME  = 1.0    -- seconds of no clicks before combo resets
local COMBO_STEP        = 0.1    -- how much combo multiplier grows per fast click
local COMBO_MAX_BASE    = 2.0    -- default max combo multiplier

-- Wait for DataManager to be ready
local function getDataManager()
    return _G.DataManager
end

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEvents then
    error("[ClickHandler] RemoteEvents folder not found in ReplicatedStorage!")
end
local clickEvent    = remoteEvents:WaitForChild("Click")
local updateUIEvent = remoteEvents:WaitForChild("UpdateUI")
local stageChanged  = remoteEvents:WaitForChild("StageChanged")

-- Load config modules
local modules = ReplicatedStorage:WaitForChild("Modules", 10)
local UpgradeConfig = require(modules:WaitForChild("UpgradeConfig"))
local StageConfig   = require(modules:WaitForChild("StageConfig"))
local FormatNumber  = require(modules:WaitForChild("FormatNumber"))

-- ─────────────────────────────────────────────────────────────────────────────
-- Check if player owns a gamepass (with pcall for safety)
-- ─────────────────────────────────────────────────────────────────────────────
local function hasGamepass(player, passId)
    if passId == 0 then return false end
    local ok, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
    end)
    return ok and result
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Calculate the player's effective click power from upgrades + prestige
-- ─────────────────────────────────────────────────────────────────────────────
local function getClickPower(data)
    local base = 1

    -- Stronger Finger: +1 per level
    base = base + (data.upgrades.strongerFinger or 0)

    -- Finger of God: each click counts as 100 (if purchased)
    if (data.upgrades.fingerOfGod or 0) >= 1 then
        base = base * 100
    end

    -- Prestige Star Power: +5% per level
    local starPowerLvl = data.prestigeUpgrades and data.prestigeUpgrades.starPower or 0
    local starBoost = 1 + (starPowerLvl * 0.05)

    -- Prestige stars: each star gives +10% production
    local starCount = data.prestigeStars or 0
    local prestigeBoost = 1 + (starCount * 0.10)

    -- 2x Clicks gamepass
    local passBoost = data.gamepasses and data.gamepasses.doubleClicks and 2 or 1

    return math.floor(base * starBoost * prestigeBoost * passBoost)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Process a validated click for a player
-- Returns: clicksEarned, isCritical, comboMultiplier
-- ─────────────────────────────────────────────────────────────────────────────
local function processClick(player)
    local dm = getDataManager()
    if not dm then return end
    local data = dm.getData(player)
    if not data then return end

    local now = tick()

    -- ── Combo system ──────────────────────────────────────────────────────────
    local combo = comboData[player.UserId] or {mult = 1.0, lastClick = 0}
    local timeSinceLast = now - combo.lastClick

    local maxCombo = COMBO_MAX_BASE + ((data.upgrades.comboMaster or 0) * 0.5)

    if timeSinceLast <= COMBO_WINDOW then
        combo.mult = math.min(combo.mult + COMBO_STEP, maxCombo)
    elseif timeSinceLast >= COMBO_DECAY_TIME then
        combo.mult = 1.0
    end
    combo.lastClick = now
    comboData[player.UserId] = combo

    -- Update highest combo stat
    if combo.mult > (data.stats.highestCombo or 0) then
        data.stats.highestCombo = combo.mult
    end

    -- ── Base click value ──────────────────────────────────────────────────────
    local power = getClickPower(data)

    -- ── Double Tap chance ─────────────────────────────────────────────────────
    local doubleTapChance = (data.upgrades.doubleTap or 0) * 0.10
    if math.random() < doubleTapChance then
        power = power * 2
    end

    -- ── Critical hit ──────────────────────────────────────────────────────────
    local critChance = BASE_CRIT_CHANCE + ((data.upgrades.criticalMastery or 0) * 0.02)
    local critMult   = BASE_CRIT_MULT   + ((data.upgrades.criticalDamage  or 0) * 4)
    local isCrit = (math.random() < critChance)
    if isCrit then
        power = power * critMult
    end

    -- ── Apply combo ───────────────────────────────────────────────────────────
    local finalClicks = math.floor(power * combo.mult)

    -- ── Update data ───────────────────────────────────────────────────────────
    data.clicks             = data.clicks             + finalClicks
    data.totalClicksThisRun = data.totalClicksThisRun + finalClicks
    data.totalClicksAllTime = data.totalClicksAllTime + finalClicks

    -- ── Check for stage advancement ───────────────────────────────────────────
    local newStage = StageConfig.getStageForClicks(data.totalClicksThisRun)
    if newStage > data.currentStage then
        local oldStage = data.currentStage
        data.currentStage = newStage
        if newStage > (data.stats.highestStage or 0) then
            data.stats.highestStage = newStage
        end
        -- Notify WorldBuilder and client
        stageChanged:FireAllClients(newStage, oldStage)
    end

    -- ── Broadcast updated UI data ──────────────────────────────────────────────
    updateUIEvent:FireClient(player, data)

    return finalClicks, isCrit, combo.mult
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Remote event handler — validate then process
-- ─────────────────────────────────────────────────────────────────────────────
clickEvent.OnServerEvent:Connect(function(player)
    local now = tick()
    local userId = player.UserId

    -- Anti-cheat: rate limiting
    local timestamps = clickTimestamps[userId] or {}
    local recent = {}
    for _, t in ipairs(timestamps) do
        if now - t < 1 then
            table.insert(recent, t)
        end
    end

    if #recent >= MAX_CLICKS_PER_SECOND then
        warn("[ClickHandler] Anti-cheat: " .. player.Name .. " is clicking too fast (" .. #recent .. "/s). Rejecting.")
        return
    end

    table.insert(recent, now)
    clickTimestamps[userId] = recent

    -- Process the click
    local ok, err = pcall(processClick, player)
    if not ok then
        warn("[ClickHandler] Error processing click for " .. player.Name .. ": " .. tostring(err))
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Auto-clicker tick: run on server heartbeat, apply automation upgrades
-- ─────────────────────────────────────────────────────────────────────────────
local lastAutoTick = {}

game:GetService("RunService").Heartbeat:Connect(function(dt)
    for _, player in ipairs(Players:GetPlayers()) do
        local dm = getDataManager()
        if not dm then continue end
        local data = dm.getData(player)
        if not data then continue end

        local userId = player.UserId
        lastAutoTick[userId] = (lastAutoTick[userId] or 0) + dt

        -- Auto-clicker ticks once per second
        if lastAutoTick[userId] >= 1 then
            lastAutoTick[userId] = lastAutoTick[userId] - 1

            local autoRate = data.upgrades.autoClicker or 0
            if autoRate <= 0 then continue end

            -- Overclock: each level increases auto speed by 10%
            local overclockBonus = 1 + ((data.upgrades.overclock or 0) * 0.10)

            -- Robot Army: +10 clicks/sec per level
            local robotBonus = (data.upgrades.robotArmy or 0) * 10

            -- Quantum Computer: square the auto rate if purchased
            local quantumLvl = data.upgrades.quantumComputer or 0
            local effectiveAuto = autoRate
            if quantumLvl > 0 then
                effectiveAuto = effectiveAuto ^ (1 + quantumLvl * 0.5)
            end

            local totalAuto = math.floor((effectiveAuto + robotBonus) * overclockBonus)

            -- Dyson Sphere: +1,000,000 clicks/sec
            if (data.upgrades.dysonSphere or 0) >= 1 then
                totalAuto = totalAuto + 1000000
            end

            -- 2x Auto gamepass
            if data.gamepasses and data.gamepasses.doubleAuto then
                totalAuto = totalAuto * 2
            end

            -- Star Power and prestige boosts
            local starPowerLvl = data.prestigeUpgrades and data.prestigeUpgrades.starPower or 0
            local starBoost = 1 + (starPowerLvl * 0.05)
            local prestigeBoost = 1 + ((data.prestigeStars or 0) * 0.10)
            totalAuto = math.floor(totalAuto * starBoost * prestigeBoost)

            if totalAuto > 0 then
                data.clicks             = data.clicks             + totalAuto
                data.totalClicksThisRun = data.totalClicksThisRun + totalAuto
                data.totalClicksAllTime = data.totalClicksAllTime + totalAuto

                local newStage = StageConfig.getStageForClicks(data.totalClicksThisRun)
                if newStage > data.currentStage then
                    local oldStage = data.currentStage
                    data.currentStage = newStage
                    if newStage > (data.stats.highestStage or 0) then
                        data.stats.highestStage = newStage
                    end
                    stageChanged:FireAllClients(newStage, oldStage)
                end

                updateUIEvent:FireClient(player, data)
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Clean up per-player state on leave
-- ─────────────────────────────────────────────────────────────────────────────
Players.PlayerRemoving:Connect(function(player)
    clickTimestamps[player.UserId] = nil
    comboData[player.UserId] = nil
    lastAutoTick[player.UserId] = nil
end)

print("[ClickHandler] Ready.")
]==]

local newScript = Instance.new("Script")
newScript.Name = "ClickHandler"
newScript.Source = scriptSource
newScript.Parent = game:GetService("ServerScriptService")
print("✅ ClickHandler Script created in ServerScriptService!")
