-- ONE BUTTON EMPIRE: Server DataManager
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the DataManager Script in ServerScriptService

local scriptSource = [==[
-- DataManager: Handles all DataStore save/load operations for One Button Empire
-- Runs as a server Script in ServerScriptService

local DataStoreService = game:GetService("DataStoreService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

local DATA_STORE_NAME = "OneButtonEmpire_v1"
local AUTO_SAVE_INTERVAL = 60  -- seconds between auto-saves
local MAX_RETRIES = 3

local playerDataStore = DataStoreService:GetDataStore(DATA_STORE_NAME)

-- In-memory cache of loaded player data
local playerCache = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Default data template — all fields a new player starts with
-- ─────────────────────────────────────────────────────────────────────────────
local function getDefaultData()
    return {
        clicks               = 0,
        totalClicksThisRun   = 0,
        totalClicksAllTime   = 0,

        currentStage         = 0,
        universeNumber       = 1,
        prestigeStars        = 0,

        upgrades = {
            strongerFinger   = 0,
            doubleTap        = 0,
            criticalMastery  = 0,
            criticalDamage   = 0,
            comboMaster      = 0,
            fingerOfGod      = 0,
            autoClicker      = 0,
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
        },

        prestigeUpgrades = {
            startingBoost      = 0,
            cosmicMemory       = 0,
            starPower          = 0,
            universalKnowledge = 0,
            bigBangMastery     = 0,
            multiverseTheory   = 0,
        },

        achievements = {},
        cosmetics    = {},
        equippedSkin = "default",

        stats = {
            totalPrestiges       = 0,
            highestStage         = 0,
            fastestSingularity   = math.huge,
            totalEventsCompleted = 0,
            highestCombo         = 0,
        },

        gamepasses = {
            doubleClicks = false,
            doubleAuto   = false,
            vip          = false,
            lucky        = false,
        },

        lastOnlineTimestamp = 0,
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Deep-merge: applies defaults for any missing keys (handles DataStore version gaps)
-- ─────────────────────────────────────────────────────────────────────────────
local function mergeMissing(target, defaults)
    for k, v in pairs(defaults) do
        if target[k] == nil then
            if type(v) == "table" then
                target[k] = {}
                mergeMissing(target[k], v)
            else
                target[k] = v
            end
        elseif type(v) == "table" and type(target[k]) == "table" then
            mergeMissing(target[k], v)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- loadData: fetches from DataStore with retry logic
-- ─────────────────────────────────────────────────────────────────────────────
local function loadData(player)
    local key = "player_" .. player.UserId
    local data = nil
    local success = false

    for attempt = 1, MAX_RETRIES do
        local ok, result = pcall(function()
            return playerDataStore:GetAsync(key)
        end)
        if ok then
            data = result
            success = true
            break
        else
            warn("[DataManager] Load attempt " .. attempt .. " failed for " .. player.Name .. ": " .. tostring(result))
            task.wait(1)
        end
    end

    if not success then
        warn("[DataManager] All load attempts failed for " .. player.Name .. ". Using default data.")
        data = nil
    end

    local playerData = data or getDefaultData()
    mergeMissing(playerData, getDefaultData())  -- fill in any missing fields
    playerData.lastOnlineTimestamp = playerData.lastOnlineTimestamp or 0
    playerCache[player.UserId] = playerData
    return playerData
end

-- ─────────────────────────────────────────────────────────────────────────────
-- saveData: writes to DataStore with retry logic
-- ─────────────────────────────────────────────────────────────────────────────
local function saveData(player)
    local data = playerCache[player.UserId]
    if not data then return end

    data.lastOnlineTimestamp = os.time()
    local key = "player_" .. player.UserId

    for attempt = 1, MAX_RETRIES do
        local ok, err = pcall(function()
            playerDataStore:SetAsync(key, data)
        end)
        if ok then
            return true
        else
            warn("[DataManager] Save attempt " .. attempt .. " failed for " .. player.Name .. ": " .. tostring(err))
            task.wait(1)
        end
    end
    warn("[DataManager] All save attempts failed for " .. player.Name)
    return false
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Public API (accessed by other server scripts via shared module pattern)
-- ─────────────────────────────────────────────────────────────────────────────
local DataManager = {}

function DataManager.loadData(player)
    return loadData(player)
end

function DataManager.saveData(player)
    return saveData(player)
end

function DataManager.getData(player)
    return playerCache[player.UserId]
end

function DataManager.updateData(player, updateFn)
    local data = playerCache[player.UserId]
    if data then
        updateFn(data)
    end
end

-- Expose as a BindableFunction so other scripts can call it
local bindable = Instance.new("BindableFunction")
bindable.Name = "DataManagerAPI"
bindable.Parent = game.ServerScriptService

bindable.OnInvoke = function(action, player, ...)
    if action == "getData" then
        return DataManager.getData(player)
    elseif action == "saveData" then
        return DataManager.saveData(player)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Player join/leave hooks
-- ─────────────────────────────────────────────────────────────────────────────
Players.PlayerAdded:Connect(function(player)
    loadData(player)
end)

Players.PlayerRemoving:Connect(function(player)
    saveData(player)
    playerCache[player.UserId] = nil
end)

-- Load data for players already in game (in case script loaded late)
for _, player in ipairs(Players:GetPlayers()) do
    if not playerCache[player.UserId] then
        loadData(player)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Auto-save loop
-- ─────────────────────────────────────────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(AUTO_SAVE_INTERVAL)
        for _, player in ipairs(Players:GetPlayers()) do
            saveData(player)
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Bind to close: save all data before server shuts down
-- ─────────────────────────────────────────────────────────────────────────────
game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        saveData(player)
    end
end)

-- Store reference globally so other scripts can access it
_G.DataManager = DataManager

print("[DataManager] Ready.")
]==]

local newScript = Instance.new("Script")
newScript.Name = "DataManager"
newScript.Source = scriptSource
newScript.Parent = game:GetService("ServerScriptService")
print("✅ DataManager Script created in ServerScriptService!")
