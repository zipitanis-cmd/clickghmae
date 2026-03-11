-- ONE BUTTON EMPIRE: Server LeaderboardManager
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the LeaderboardManager Script in ServerScriptService

local scriptSource = [==[
-- LeaderboardManager: Maintains OrderedDataStore leaderboards and Roblox Leaderboards
-- Runs as a server Script in ServerScriptService

local DataStoreService  = game:GetService("DataStoreService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- OrderedDataStores for each leaderboard category
local lbAllTime   = DataStoreService:GetOrderedDataStore("LB_TotalClicksAllTime")
local lbPrestiges = DataStoreService:GetOrderedDataStore("LB_TotalPrestiges")
local lbStage     = DataStoreService:GetOrderedDataStore("LB_HighestStage")

local UPDATE_INTERVAL = 60  -- seconds between leaderboard updates

-- ─────────────────────────────────────────────────────────────────────────────
-- Update a player's score in all leaderboards
-- ─────────────────────────────────────────────────────────────────────────────
local function updatePlayerLeaderboards(player)
    local dm = _G.DataManager
    if not dm then return end
    local data = dm.getData(player)
    if not data then return end

    local userId = player.UserId

    -- Update total clicks all time
    pcall(function()
        lbAllTime:SetAsync(tostring(userId), math.floor(data.totalClicksAllTime or 0))
    end)

    -- Update total prestiges
    pcall(function()
        lbPrestiges:SetAsync(tostring(userId), math.floor(data.stats.totalPrestiges or 0))
    end)

    -- Update highest stage
    pcall(function()
        lbStage:SetAsync(tostring(userId), math.floor(data.stats.highestStage or 0))
    end)

    -- Update the in-game leaderstats (shows in player list)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local clicksStat = leaderstats:FindFirstChild("Clicks")
        local starsStat  = leaderstats:FindFirstChild("Stars")
        if clicksStat then
            clicksStat.Value = math.floor(data.totalClicksAllTime or 0)
        end
        if starsStat then
            starsStat.Value = math.floor(data.prestigeStars or 0)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Get top N players from a given OrderedDataStore
-- Returns: array of { userId, score }
-- ─────────────────────────────────────────────────────────────────────────────
local function getTopPlayers(store, count)
    count = count or 10
    local results = {}
    local ok, pages = pcall(function()
        return store:GetSortedAsync(false, count)
    end)
    if not ok then return results end

    local pageOk, data = pcall(function()
        return pages:GetCurrentPage()
    end)
    if not pageOk then return results end

    for _, entry in ipairs(data) do
        table.insert(results, {userId = entry.key, score = entry.value})
    end
    return results
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Create Roblox leaderstats (shows in the player list tab)
-- ─────────────────────────────────────────────────────────────────────────────
local function createLeaderstats(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local clicksStat = Instance.new("IntValue")
    clicksStat.Name = "Clicks"
    clicksStat.Value = 0
    clicksStat.Parent = leaderstats

    local starsStat = Instance.new("IntValue")
    starsStat.Name = "Stars"
    starsStat.Value = 0
    starsStat.Parent = leaderstats
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Player join: create leaderstats
-- ─────────────────────────────────────────────────────────────────────────────
Players.PlayerAdded:Connect(function(player)
    createLeaderstats(player)
    -- Update leaderboards after data loads (wait a few seconds)
    task.delay(5, function()
        updatePlayerLeaderboards(player)
    end)
end)

-- Create leaderstats for players already in game
for _, player in ipairs(Players:GetPlayers()) do
    if not player:FindFirstChild("leaderstats") then
        createLeaderstats(player)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Periodic leaderboard update
-- ─────────────────────────────────────────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(UPDATE_INTERVAL)
        for _, player in ipairs(Players:GetPlayers()) do
            updatePlayerLeaderboards(player)
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Expose leaderboard query API for other scripts
-- ─────────────────────────────────────────────────────────────────────────────
_G.LeaderboardManager = {
    getTopAllTime   = function(n) return getTopPlayers(lbAllTime, n) end,
    getTopPrestiges = function(n) return getTopPlayers(lbPrestiges, n) end,
    getTopStage     = function(n) return getTopPlayers(lbStage, n) end,
    update          = updatePlayerLeaderboards,
}

print("[LeaderboardManager] Ready.")
]==]

local newScript = Instance.new("Script")
newScript.Name = "LeaderboardManager"
newScript.Source = scriptSource
newScript.Parent = game:GetService("ServerScriptService")
print("✅ LeaderboardManager Script created in ServerScriptService!")
