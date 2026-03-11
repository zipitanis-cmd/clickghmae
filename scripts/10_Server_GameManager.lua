-- ONE BUTTON EMPIRE: Server GameManager
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the GameManager master Script in ServerScriptService

local scriptSource = [==[
-- GameManager: Master server controller for One Button Empire
-- Handles player join/leave, offline income, achievements, and orchestrates other systems
-- Runs as a server Script in ServerScriptService

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEvents then
    error("[GameManager] RemoteEvents not found in ReplicatedStorage!")
end
local updateUIEvent          = remoteEvents:WaitForChild("UpdateUI")
local stageChangedEvent      = remoteEvents:WaitForChild("StageChanged")
local achievementUnlocked    = remoteEvents:WaitForChild("AchievementUnlocked")
local playSound              = remoteEvents:WaitForChild("PlaySound")

-- Modules
local modules       = ReplicatedStorage:WaitForChild("Modules", 10)
local StageConfig   = require(modules:WaitForChild("StageConfig"))

-- ─────────────────────────────────────────────────────────────────────────────
-- GAMEPASS IDs — must match ClickHandler (update both if you change them)
-- ─────────────────────────────────────────────────────────────────────────────
local GAMEPASS_IDS = {
    doubleClicks = 0,
    doubleAuto   = 0,
    vip          = 0,
    lucky        = 0,
}

local OFFLINE_INCOME_CAP = 8 * 3600  -- cap offline income at 8 hours

-- ─────────────────────────────────────────────────────────────────────────────
-- Check whether the player owns each gamepass and update data
-- ─────────────────────────────────────────────────────────────────────────────
local function checkGamepasses(player, data)
    for passName, passId in pairs(GAMEPASS_IDS) do
        if passId ~= 0 then
            local ok, owns = pcall(function()
                return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
            end)
            if ok then
                data.gamepasses[passName] = owns
            end
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Calculate and award offline income
-- Capped at 8 hours of auto-click production
-- ─────────────────────────────────────────────────────────────────────────────
local function applyOfflineIncome(player, data)
    local lastTime = data.lastOnlineTimestamp or 0
    if lastTime == 0 then return 0 end

    local now = os.time()
    local elapsed = math.min(now - lastTime, OFFLINE_INCOME_CAP)
    if elapsed <= 0 then return 0 end

    local autoRate = (data.upgrades.autoClicker or 0)
    local robotBonus = (data.upgrades.robotArmy or 0) * 10
    local dysonBonus = (data.upgrades.dysonSphere or 0) >= 1 and 1000000 or 0
    local overclockBonus = 1 + ((data.upgrades.overclock or 0) * 0.10)

    local autoPerSec = math.floor((autoRate + robotBonus + dysonBonus) * overclockBonus)
    local offlineClicks = math.floor(autoPerSec * elapsed)

    if offlineClicks > 0 then
        data.clicks             = data.clicks             + offlineClicks
        data.totalClicksThisRun = data.totalClicksThisRun + offlineClicks
        data.totalClicksAllTime = data.totalClicksAllTime + offlineClicks
    end

    return offlineClicks
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Achievement definitions and checker
-- ─────────────────────────────────────────────────────────────────────────────
local ACHIEVEMENTS = {
    {id = "firstClick",           check = function(d) return (d.totalClicksAllTime or 0) >= 1 end},
    {id = "centurion",            check = function(d) return (d.totalClicksAllTime or 0) >= 100 end},
    {id = "thousandStrong",       check = function(d) return (d.totalClicksAllTime or 0) >= 1000 end},
    {id = "villageFounder",       check = function(d) return (d.stats.highestStage or 0) >= 4 end},
    {id = "castleBuilder",        check = function(d) return (d.stats.highestStage or 0) >= 6 end},
    {id = "industrialRevolution", check = function(d) return (d.stats.highestStage or 0) >= 8 end},
    {id = "toTheStars",           check = function(d) return (d.stats.highestStage or 0) >= 11 end},
    {id = "universalBeing",       check = function(d) return (d.stats.highestStage or 0) >= 13 end},
    {id = "bigBanger",            check = function(d) return (d.stats.totalPrestiges or 0) >= 1 end},
    {id = "multiverseTraveler",   check = function(d) return (d.stats.totalPrestiges or 0) >= 10 end},
    {id = "speedDemon",           check = function(d) return (d.stats.highestCombo or 0) >= 20 end},
    {id = "afkMaster",            check = function(d) return (d.totalClicksAllTime or 0) >= 1000000 end},
    {id = "eventHunter",          check = function(d) return (d.stats.totalEventsCompleted or 0) >= 50 end},
}

local function checkAchievements(player, data)
    if not data.achievements then data.achievements = {} end
    local unlocked = {}
    for _, ach in ipairs(ACHIEVEMENTS) do
        -- Skip if already unlocked
        local alreadyHave = false
        for _, id in ipairs(data.achievements) do
            if id == ach.id then alreadyHave = true; break end
        end
        if not alreadyHave and ach.check(data) then
            table.insert(data.achievements, ach.id)
            table.insert(unlocked, ach.id)
        end
    end
    for _, id in ipairs(unlocked) do
        achievementUnlocked:FireClient(player, id)
        playSound:FireClient(player, "achievement")
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Player joined
-- ─────────────────────────────────────────────────────────────────────────────
local function onPlayerAdded(player)
    -- Wait for DataManager to load data (it runs PlayerAdded too, so retry)
    local data = nil
    for _ = 1, 20 do
        local dm = _G.DataManager
        if dm then
            data = dm.getData(player)
            if data then break end
        end
        task.wait(0.5)
    end

    if not data then
        warn("[GameManager] Could not retrieve data for " .. player.Name)
        return
    end

    -- Check gamepasses
    checkGamepasses(player, data)

    -- Apply offline income
    local offlineClicks = applyOfflineIncome(player, data)

    -- Correct stage for current click count
    local correctStage = StageConfig.getStageForClicks(data.totalClicksThisRun or 0)
    if correctStage ~= data.currentStage then
        data.currentStage = correctStage
    end

    -- Signal world to build for this player's stage
    local wb = _G.StageChangedBindable
    if wb then
        wb:Fire(data.currentStage, -1)
    end

    -- Send initial UI update
    updateUIEvent:FireClient(player, data)

    -- Check achievements
    checkAchievements(player, data)

    if offlineClicks > 0 then
        playSound:FireClient(player, "offline_income")
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle players already in server
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Player leaving
-- ─────────────────────────────────────────────────────────────────────────────
Players.PlayerRemoving:Connect(function(player)
    local dm = _G.DataManager
    if dm then
        dm.saveData(player)
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Auto-save loop (every 60 seconds)
-- ─────────────────────────────────────────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(60)
        local dm = _G.DataManager
        if dm then
            for _, player in ipairs(Players:GetPlayers()) do
                checkAchievements(player, dm.getData(player) or {})
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Bind to close: final save for all players
-- ─────────────────────────────────────────────────────────────────────────────
game:BindToClose(function()
    local dm = _G.DataManager
    if dm then
        for _, player in ipairs(Players:GetPlayers()) do
            dm.saveData(player)
        end
    end
end)

print("[GameManager] Ready.")
]==]

local newScript = Instance.new("Script")
newScript.Name = "GameManager"
newScript.Source = scriptSource
newScript.Parent = game:GetService("ServerScriptService")
print("✅ GameManager Script created in ServerScriptService!")
