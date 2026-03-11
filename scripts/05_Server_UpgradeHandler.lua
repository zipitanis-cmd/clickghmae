-- ONE BUTTON EMPIRE: Server UpgradeHandler
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the UpgradeHandler Script in ServerScriptService

local scriptSource = [==[
-- UpgradeHandler: Validates and applies upgrade purchases
-- Runs as a server Script in ServerScriptService

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEvents then
    error("[UpgradeHandler] RemoteEvents not found in ReplicatedStorage!")
end
local buyUpgradeEvent = remoteEvents:WaitForChild("BuyUpgrade")
local updateUIEvent   = remoteEvents:WaitForChild("UpdateUI")

-- Wait for modules
local modules       = ReplicatedStorage:WaitForChild("Modules", 10)
local UpgradeConfig = require(modules:WaitForChild("UpgradeConfig"))

-- ─────────────────────────────────────────────────────────────────────────────
-- Calculate the cost of the next level for a given upgrade
-- Formula: baseCost * (costScaling ^ currentLevel)
-- ─────────────────────────────────────────────────────────────────────────────
local function getNextCost(upgradeId, currentLevel)
    local cfg = UpgradeConfig[upgradeId]
    if not cfg then return math.huge end
    return math.floor(cfg.baseCost * (cfg.costScaling ^ currentLevel))
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Validate and process an upgrade purchase
-- ─────────────────────────────────────────────────────────────────────────────
local function handleUpgradePurchase(player, upgradeId)
    local dm = _G.DataManager
    if not dm then
        warn("[UpgradeHandler] DataManager not ready.")
        return false, "Server not ready"
    end

    local data = dm.getData(player)
    if not data then
        return false, "No player data"
    end

    local cfg = UpgradeConfig[upgradeId]
    if not cfg then
        warn("[UpgradeHandler] Unknown upgradeId: " .. tostring(upgradeId) .. " from " .. player.Name)
        return false, "Unknown upgrade"
    end

    -- Determine which upgrade table to use (prestige vs normal)
    local upgradeTable = cfg.category == "prestige" and data.prestigeUpgrades or data.upgrades
    if not upgradeTable then
        return false, "Invalid upgrade category"
    end

    local currentLevel = upgradeTable[upgradeId] or 0

    -- Check max level
    if currentLevel >= cfg.maxLevel then
        return false, "Already at max level"
    end

    -- Calculate cost
    local cost = getNextCost(upgradeId, currentLevel)

    -- Check currency
    if cfg.category == "prestige" then
        -- Prestige upgrades cost prestige stars
        if (data.prestigeStars or 0) < cost then
            return false, "Not enough prestige stars"
        end
        data.prestigeStars = data.prestigeStars - cost
    else
        -- Normal upgrades cost clicks
        if (data.clicks or 0) < cost then
            return false, "Not enough clicks"
        end
        data.clicks = data.clicks - cost
    end

    -- Apply the upgrade
    upgradeTable[upgradeId] = currentLevel + 1

    -- Notify client to refresh UI
    updateUIEvent:FireClient(player, data)

    return true, "Success"
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Listen for purchase requests from clients
-- ─────────────────────────────────────────────────────────────────────────────
buyUpgradeEvent.OnServerEvent:Connect(function(player, upgradeId)
    -- Basic sanity check
    if type(upgradeId) ~= "string" then
        warn("[UpgradeHandler] Invalid upgradeId type from " .. player.Name)
        return
    end

    local ok, reason = handleUpgradePurchase(player, upgradeId)
    if not ok then
        -- Send failure feedback (client can show a message)
        -- We fire UpdateUI anyway so the UI stays in sync
        local dm = _G.DataManager
        if dm then
            local data = dm.getData(player)
            if data then
                updateUIEvent:FireClient(player, data)
            end
        end
    end
end)

print("[UpgradeHandler] Ready.")
]==]

local newScript = Instance.new("Script")
newScript.Name = "UpgradeHandler"
newScript.Source = scriptSource
newScript.Parent = game:GetService("ServerScriptService")
print("✅ UpgradeHandler Script created in ServerScriptService!")
