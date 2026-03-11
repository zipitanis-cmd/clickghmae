-- ONE BUTTON EMPIRE: Setup RemoteEvents
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the RemoteEvents folder in ReplicatedStorage

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remove existing folder if present so this script is idempotent
local existing = ReplicatedStorage:FindFirstChild("RemoteEvents")
if existing then
    existing:Destroy()
end

local folder = Instance.new("Folder")
folder.Name = "RemoteEvents"
folder.Parent = ReplicatedStorage

-- List of all RemoteEvents used by One Button Empire
local remoteEventNames = {
    "Click",              -- Client → Server: player clicked the button
    "BuyUpgrade",         -- Client → Server: player wants to buy an upgrade (passes upgradeId)
    "TriggerPrestige",    -- Client → Server: player triggered Big Bang
    "UpdateUI",           -- Server → Client: send full player data table for UI refresh
    "EventAction",        -- Client ↔ Server: player interacted with a random event object
    "StageChanged",       -- Server → Client: new stage index (number)
    "AchievementUnlocked",-- Server → Client: achievement ID string
    "PlaySound",          -- Server → Client: sound name string
    "TriggerCinematic",   -- Server → Client: trigger the 3-second camera flyover
}

for _, name in ipairs(remoteEventNames) do
    local re = Instance.new("RemoteEvent")
    re.Name = name
    re.Parent = folder
end

print("✅ RemoteEvents folder created in ReplicatedStorage with " .. #remoteEventNames .. " events!")
