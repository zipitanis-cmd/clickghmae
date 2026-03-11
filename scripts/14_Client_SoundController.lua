-- ONE BUTTON EMPIRE: Client SoundController
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the SoundController LocalScript in StarterPlayerScripts

local scriptSource = [==[
-- SoundController: Handles all ambient sounds, click SFX, and stage transitions.
-- Uses free Roblox audio asset IDs. Replace with your own if desired.
-- Runs as a LocalScript in StarterPlayerScripts

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService      = game:GetService("SoundService")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local stageChanged = remoteEvents:WaitForChild("StageChanged")
local playSound    = remoteEvents:WaitForChild("PlaySound")

-- ─────────────────────────────────────────────────────────────────────────────
-- SOUND IDs
-- Replace these with your own Roblox audio asset IDs.
-- Find free sounds at: https://create.roblox.com > Toolbox > Audio
-- Format: rbxassetid://XXXXXXXXXX
--
-- The values below are placeholders (0 = silent).
-- ─────────────────────────────────────────────────────────────────────────────
local SOUND_IDS = {
    -- Click sounds
    click          = 0,  -- Replace: a short click/pop sound
    click_critical = 0,  -- Replace: a whoosh/explosion for critical hits
    click_milestone= 0,  -- Replace: a fanfare for every 100th click

    -- UI sounds
    upgrade        = 0,  -- Replace: a positive chime
    prestige       = 0,  -- Replace: a big bang / explosion
    achievement    = 0,  -- Replace: achievement jingle

    -- Event sounds
    event_start    = 0,  -- Replace: a dramatic sting
    mystery_box_open = 0,-- Replace: a sparkle/reveal sound
    time_rift      = 0,  -- Replace: a whoosh/portal sound
    offline_income = 0,  -- Replace: coins sound

    -- Ambient loops per sound theme
    -- theme names match StageConfig's soundTheme field
    ambient_void       = 0,  -- Replace: eerie silence / low drone
    ambient_nature     = 0,  -- Replace: birds, crickets, wind
    ambient_medieval   = 0,  -- Replace: lute music, crowd chatter
    ambient_industrial = 0,  -- Replace: machinery, steam
    ambient_modern     = 0,  -- Replace: city traffic, light jazz
    ambient_synthwave  = 0,  -- Replace: synthwave music
    ambient_space      = 0,  -- Replace: deep space ambient
    ambient_cosmic     = 0,  -- Replace: ethereal cosmic drone
    ambient_singularity= 0,  -- Replace: pure tone / transcendence
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Create Sound instances in SoundService
-- ─────────────────────────────────────────────────────────────────────────────
local sounds = {}

local function getOrCreateSound(name, id, looped)
    if sounds[name] then return sounds[name] end
    local s = Instance.new("Sound")
    s.Name = "OBE_" .. name
    s.SoundId = (id and id ~= 0) and ("rbxassetid://" .. tostring(id)) or ""
    s.Looped = looped or false
    s.Volume = looped and 0.4 or 0.8
    s.Parent = SoundService
    sounds[name] = s
    return s
end

-- Pre-create all sounds
for name, id in pairs(SOUND_IDS) do
    local isAmbient = name:sub(1, 7) == "ambient"
    getOrCreateSound(name, id, isAmbient)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Play a one-shot sound by name
-- ─────────────────────────────────────────────────────────────────────────────
local function playOneShot(name)
    local s = sounds[name]
    if not s or s.SoundId == "" then return end
    s:Play()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Ambient music management: cross-fade between themes
-- ─────────────────────────────────────────────────────────────────────────────
local currentAmbient = nil

local function setAmbientTheme(themeName)
    local newKey = "ambient_" .. themeName
    local newSound = sounds[newKey]
    if not newSound or newSound.SoundId == "" then return end
    if currentAmbient == newSound then return end

    -- Fade out current ambient
    if currentAmbient then
        TweenService:Create(currentAmbient, TweenInfo.new(2), {Volume = 0}):Play()
        local old = currentAmbient
        task.delay(2.1, function()
            old:Stop()
            old.Volume = 0.4
        end)
    end

    -- Fade in new ambient
    newSound.Volume = 0
    newSound:Play()
    TweenService:Create(newSound, TweenInfo.new(2), {Volume = 0.4}):Play()
    currentAmbient = newSound
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Map stage index to sound theme
-- ─────────────────────────────────────────────────────────────────────────────
local STAGE_THEMES = {
    [0]  = "void",
    [1]  = "nature",
    [2]  = "nature",
    [3]  = "medieval",
    [4]  = "medieval",
    [5]  = "medieval",
    [6]  = "medieval",
    [7]  = "medieval",
    [8]  = "industrial",
    [9]  = "modern",
    [10] = "synthwave",
    [11] = "space",
    [12] = "cosmic",
    [13] = "cosmic",
    [14] = "cosmic",
    [15] = "singularity",
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Listen for stage changes
-- ─────────────────────────────────────────────────────────────────────────────
stageChanged.OnClientEvent:Connect(function(newStage, oldStage)
    local theme = STAGE_THEMES[newStage] or "nature"
    setAmbientTheme(theme)
    -- Play a stage transition fanfare
    playOneShot("click_milestone")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Listen for server-fired sound requests
-- ─────────────────────────────────────────────────────────────────────────────
playSound.OnClientEvent:Connect(function(soundName)
    playOneShot(soundName)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Start with void ambient
-- ─────────────────────────────────────────────────────────────────────────────
task.wait(1)
setAmbientTheme("void")

print("[SoundController] Ready. Replace SOUND_IDS with your own audio asset IDs!")
]==]

local newScript = Instance.new("LocalScript")
newScript.Name = "SoundController"
newScript.Source = scriptSource
newScript.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
print("✅ SoundController LocalScript created in StarterPlayerScripts!")
