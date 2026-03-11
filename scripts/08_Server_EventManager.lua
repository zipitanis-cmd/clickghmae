-- ONE BUTTON EMPIRE: Server EventManager
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the EventManager Script in ServerScriptService

local scriptSource = [==[
-- EventManager: Manages random timed events that keep players engaged
-- Events fire every 120-300 seconds. Lucky Stars + Lucky gamepass affect frequency.
-- Runs as a server Script in ServerScriptService

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEvents then
    error("[EventManager] RemoteEvents not found in ReplicatedStorage!")
end
local eventActionEvent  = remoteEvents:WaitForChild("EventAction")
local updateUIEvent     = remoteEvents:WaitForChild("UpdateUI")
local playSound         = remoteEvents:WaitForChild("PlaySound")

-- Modules
local modules       = ReplicatedStorage:WaitForChild("Modules", 10)
local FormatNumber  = require(modules:WaitForChild("FormatNumber"))

-- Base timing range
local MIN_EVENT_INTERVAL = 120  -- seconds
local MAX_EVENT_INTERVAL = 300  -- seconds

-- ─────────────────────────────────────────────────────────────────────────────
-- Event definitions
-- Each event has:
--   id       — unique string identifier
--   name     — display name
--   duration — how long the event lasts in seconds (0 = instant)
--   handler  — function(player) called when the player interacts with the event
-- ─────────────────────────────────────────────────────────────────────────────
local EVENTS = {
    {
        id       = "MeteorShower",
        name     = "☄️ Meteor Shower",
        duration = 15,
        description = "Click falling meteors for 10x bonus clicks!",
        -- On interaction, give 10x the player's current click power
        handler = function(player, clicksPerClick)
            local dm = _G.DataManager
            if not dm then return end
            local data = dm.getData(player)
            if not data then return end
            local bonus = math.max(1, (clicksPerClick or 1)) * 10
            data.clicks             = data.clicks             + bonus
            data.totalClicksThisRun = data.totalClicksThisRun + bonus
            data.totalClicksAllTime = data.totalClicksAllTime + bonus
            updateUIEvent:FireClient(player, data)
        end,
    },
    {
        id       = "RoyalDecree",
        name     = "👑 Royal Decree",
        duration = 30,
        description = "All auto-clicks doubled for 30 seconds!",
        -- Buff is handled client-side visually; server applies 2x to next 30s of auto ticks
        handler = function(player)
            -- Signal client to show the Royal Decree visual
        end,
    },
    {
        id       = "RainbowSurge",
        name     = "🌈 Rainbow Surge",
        duration = 20,
        description = "Every click is a critical hit for 20 seconds!",
        handler = function(player)
            -- Signal client; click handler checks a flag
            local dm = _G.DataManager
            if not dm then return end
            local data = dm.getData(player)
            if data then
                data._rainbowSurgeUntil = tick() + 20
            end
        end,
    },
    {
        id       = "MysteryBox",
        name     = "🎁 Mystery Box",
        duration = 0,
        description = "Click to open! Random reward inside.",
        handler = function(player)
            local dm = _G.DataManager
            if not dm then return end
            local data = dm.getData(player)
            if not data then return end
            -- Random reward: 100 to 10,000 clicks
            local reward = math.random(100, 10000)
            data.clicks             = data.clicks             + reward
            data.totalClicksThisRun = data.totalClicksThisRun + reward
            data.totalClicksAllTime = data.totalClicksAllTime + reward
            updateUIEvent:FireClient(player, data)
            playSound:FireClient(player, "mystery_box_open")
        end,
    },
    {
        id       = "GhostClick",
        name     = "👻 Ghost Click",
        duration = 10,
        description = "A ghost rapidly clicks the button for you!",
        handler = function(player)
            -- Ghost clicking is handled server-side: fire rapid clicks for 10s
            local dm = _G.DataManager
            if not dm then return end
            task.spawn(function()
                for i = 1, 50 do  -- ~5 clicks/sec for 10 seconds
                    task.wait(0.2)
                    local data = dm.getData(player)
                    if not data then break end
                    local bonus = 5
                    data.clicks             = data.clicks             + bonus
                    data.totalClicksThisRun = data.totalClicksThisRun + bonus
                    data.totalClicksAllTime = data.totalClicksAllTime + bonus
                end
                local data = dm.getData(player)
                if data then
                    updateUIEvent:FireClient(player, data)
                end
            end)
        end,
    },
    {
        id       = "VolcanicEruption",
        name     = "🌋 Volcanic Eruption",
        duration = 15,
        description = "Click the volcano to stop it! Reward scales with speed.",
        handler = function(player, clicksUsed)
            local dm = _G.DataManager
            if not dm then return end
            local data = dm.getData(player)
            if not data then return end
            -- Reward inversely proportional to time taken (faster = more)
            local baseReward = 500
            local bonus = math.max(baseReward, baseReward * (15 - (clicksUsed or 15)))
            data.clicks             = data.clicks             + bonus
            data.totalClicksThisRun = data.totalClicksThisRun + bonus
            data.totalClicksAllTime = data.totalClicksAllTime + bonus
            updateUIEvent:FireClient(player, data)
        end,
    },
    {
        id       = "TimeRift",
        name     = "⏰ Time Rift",
        duration = 30,
        description = "Earn 5 minutes of offline income instantly!",
        handler = function(player)
            local dm = _G.DataManager
            if not dm then return end
            local data = dm.getData(player)
            if not data then return end
            -- Calculate 5 minutes of auto-click income
            local autoRate = (data.upgrades.autoClicker or 0)
            local robotBonus = (data.upgrades.robotArmy or 0) * 10
            local fiveMinIncome = (autoRate + robotBonus) * 300  -- 300 seconds
            fiveMinIncome = math.max(fiveMinIncome, 100)  -- minimum reward
            data.clicks             = data.clicks             + fiveMinIncome
            data.totalClicksThisRun = data.totalClicksThisRun + fiveMinIncome
            data.totalClicksAllTime = data.totalClicksAllTime + fiveMinIncome
            updateUIEvent:FireClient(player, data)
            playSound:FireClient(player, "time_rift")
        end,
    },
}

-- Track active events and which players have interacted
local activeEvent      = nil
local activeEventTimer = 0

-- ─────────────────────────────────────────────────────────────────────────────
-- Get a random event (weighted — all equal for now)
-- ─────────────────────────────────────────────────────────────────────────────
local function getRandomEvent()
    return EVENTS[math.random(1, #EVENTS)]
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Calculate the interval until the next event, considering Lucky upgrades
-- ─────────────────────────────────────────────────────────────────────────────
local function getNextEventInterval()
    -- Find average Lucky Stars level across all players
    local totalLucky = 0
    local playerCount = 0
    for _, player in ipairs(Players:GetPlayers()) do
        local dm = _G.DataManager
        if dm then
            local data = dm.getData(player)
            if data then
                totalLucky = totalLucky + (data.upgrades.luckyStars or 0)
                -- Lucky gamepass halves interval
                if data.gamepasses and data.gamepasses.lucky then
                    totalLucky = totalLucky + 10  -- equivalent boost
                end
                playerCount = playerCount + 1
            end
        end
    end

    local avgLucky = playerCount > 0 and (totalLucky / playerCount) or 0
    local reductionFactor = 1 - math.min(0.80, avgLucky * 0.05)  -- cap at 80% reduction

    local interval = math.random(MIN_EVENT_INTERVAL, MAX_EVENT_INTERVAL)
    return math.floor(interval * reductionFactor)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Fire an event for all current players
-- ─────────────────────────────────────────────────────────────────────────────
local function fireEvent(event)
    activeEvent = event
    activeEventTimer = event.duration

    for _, player in ipairs(Players:GetPlayers()) do
        -- Tell the client to show the event UI and spawn client-side visuals
        eventActionEvent:FireClient(player, "start", event.id, event.name, event.description, event.duration)
        playSound:FireClient(player, "event_start")
    end

    -- Auto-expire the event after its duration
    if event.duration > 0 then
        task.delay(event.duration, function()
            if activeEvent == event then
                activeEvent = nil
                for _, player in ipairs(Players:GetPlayers()) do
                    eventActionEvent:FireClient(player, "end", event.id)
                end
            end
        end)
    else
        -- Instant event — clear immediately
        activeEvent = nil
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Handle client interaction with an active event
-- ─────────────────────────────────────────────────────────────────────────────
eventActionEvent.OnServerEvent:Connect(function(player, action, eventId, extraData)
    if action ~= "interact" then return end
    if not activeEvent or activeEvent.id ~= eventId then return end

    -- Run the event's reward handler
    local ok, err = pcall(activeEvent.handler, player, extraData)
    if not ok then
        warn("[EventManager] Event handler error: " .. tostring(err))
    end

    -- Track achievement progress
    local dm = _G.DataManager
    if dm then
        local data = dm.getData(player)
        if data then
            data.stats.totalEventsCompleted = (data.stats.totalEventsCompleted or 0) + 1
            updateUIEvent:FireClient(player, data)
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Main event loop
-- ─────────────────────────────────────────────────────────────────────────────
task.spawn(function()
    -- Initial delay before first event
    task.wait(60)

    while true do
        local interval = getNextEventInterval()
        task.wait(interval)

        if #Players:GetPlayers() > 0 then
            local event = getRandomEvent()
            local ok, err = pcall(fireEvent, event)
            if not ok then
                warn("[EventManager] Error firing event: " .. tostring(err))
            end
        end
    end
end)

print("[EventManager] Ready. Events will fire every 2-5 minutes.")
]==]

local newScript = Instance.new("Script")
newScript.Name = "EventManager"
newScript.Source = scriptSource
newScript.Parent = game:GetService("ServerScriptService")
print("✅ EventManager Script created in ServerScriptService!")
