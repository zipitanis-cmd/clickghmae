-- ONE BUTTON EMPIRE: Client CameraController
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the CameraController LocalScript in StarterPlayerScripts

local scriptSource = [==[
-- CameraController: Handles the 3-second cinematic camera flyover on stage transitions.
-- Also handles screen flash and camera shake effects.
-- Runs as a LocalScript in StarterPlayerScripts

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Wait for RemoteEvents
local remoteEvents         = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local triggerCinematic     = remoteEvents:WaitForChild("TriggerCinematic")

-- Modules
local modules     = ReplicatedStorage:WaitForChild("Modules", 10)
local StageConfig = require(modules:WaitForChild("StageConfig"))

-- ─────────────────────────────────────────────────────────────────────────────
-- Screen flash effect using a ScreenGui
-- ─────────────────────────────────────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CameraEffects"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local flashFrame = Instance.new("Frame")
flashFrame.Size = UDim2.fromScale(1, 1)
flashFrame.BackgroundColor3 = Color3.new(1, 1, 1)
flashFrame.BackgroundTransparency = 1
flashFrame.BorderSizePixel = 0
flashFrame.Parent = screenGui

local stageLabel = Instance.new("TextLabel")
stageLabel.Size = UDim2.new(1, 0, 0.15, 0)
stageLabel.Position = UDim2.new(0, 0, 0.42, 0)
stageLabel.BackgroundTransparency = 1
stageLabel.Text = ""
stageLabel.TextColor3 = Color3.new(1, 1, 1)
stageLabel.TextTransparency = 1
stageLabel.TextScaled = true
stageLabel.Font = Enum.Font.GothamBold
stageLabel.Parent = screenGui

-- ─────────────────────────────────────────────────────────────────────────────
-- Flash the screen white (used on stage transitions and prestige)
-- ─────────────────────────────────────────────────────────────────────────────
local function flashScreen(duration, color)
    duration = duration or 0.5
    color    = color    or Color3.new(1, 1, 1)
    flashFrame.BackgroundColor3   = color
    flashFrame.BackgroundTransparency = 0
    TweenService:Create(flashFrame, TweenInfo.new(duration), {BackgroundTransparency = 1}):Play()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Show a centered stage announcement text
-- ─────────────────────────────────────────────────────────────────────────────
local function showStageAnnouncement(text)
    stageLabel.Text = text
    stageLabel.TextTransparency = 0
    task.delay(2.5, function()
        TweenService:Create(stageLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Camera shake (simulates impact on large transitions)
-- ─────────────────────────────────────────────────────────────────────────────
local shaking = false
local function cameraShake(intensity, duration)
    if shaking then return end
    shaking = true
    local startTime = tick()
    local originalCFrame = camera.CFrame

    local conn
    conn = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        if elapsed >= duration then
            camera.CFrame = originalCFrame
            shaking = false
            conn:Disconnect()
            return
        end
        local t = elapsed / duration
        local decay = 1 - t
        local offset = Vector3.new(
            (math.random() - 0.5) * 2 * intensity * decay,
            (math.random() - 0.5) * 2 * intensity * decay,
            0
        )
        camera.CFrame = originalCFrame * CFrame.new(offset)
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Cinematic flyover: 3-second camera sweep over the new world
-- Uses a simple arc from the current camera position to a birds-eye view
-- then back to the player character
-- ─────────────────────────────────────────────────────────────────────────────
local cinematicActive = false

local function playCinematic(stageIndex)
    if cinematicActive then return end
    cinematicActive = true

    -- Save original camera settings
    local originalType  = camera.CameraType
    local originalCFrame = camera.CFrame

    -- Set to scriptable for the duration
    camera.CameraType = Enum.CameraType.Scriptable

    -- Starting CFrame (where we are now)
    local startCF = camera.CFrame

    -- Determine world center (button location or 0,0,0)
    local button = workspace:FindFirstChild("TheButton")
    local worldCenter = Vector3.new(0, 5, 0)
    if button then
        local primaryPart = button:IsA("Model") and button.PrimaryPart or button:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            worldCenter = primaryPart.Position
        end
    end

    -- Three waypoints for the cinematic sweep
    local stageCfg  = StageConfig[stageIndex]
    local stageName = stageCfg and stageCfg.name or ("Stage " .. stageIndex)

    local mid1  = CFrame.new(worldCenter + Vector3.new(-30, 40, -30)) * CFrame.Angles(math.rad(45), math.rad(-45), 0)
    local mid2  = CFrame.new(worldCenter + Vector3.new( 30, 60,  30)) * CFrame.Angles(math.rad(55), math.rad(135), 0)

    local SEGMENT_TIME = 1.0
    local tweenInfo    = TweenInfo.new(SEGMENT_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    local t1 = TweenService:Create(camera, tweenInfo, {CFrame = mid1})
    t1:Play()
    t1.Completed:Wait()

    showStageAnnouncement("🌍 " .. stageName)

    local t2 = TweenService:Create(camera, tweenInfo, {CFrame = mid2})
    t2:Play()
    t2.Completed:Wait()

    -- Fly back to player's perspective
    local character = player.Character or player.CharacterAdded:Wait()
    local head = character:FindFirstChild("Head") or character:FindFirstChildWhichIsA("BasePart")
    local endCF = startCF
    if head then
        endCF = head.CFrame * CFrame.new(0, 1.5, -8) * CFrame.Angles(math.rad(-10), math.rad(180), 0)
    end

    local t3 = TweenService:Create(camera, tweenInfo, {CFrame = endCF})
    t3:Play()
    t3.Completed:Wait()

    -- Restore camera
    camera.CameraType = originalType
    cinematicActive = false
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Listen for TriggerCinematic from server
-- ─────────────────────────────────────────────────────────────────────────────
triggerCinematic.OnClientEvent:Connect(function(stageIndex)
    flashScreen(0.4, Color3.new(1, 1, 1))
    cameraShake(0.3, 0.5)
    task.delay(0.3, function()
        local ok, err = pcall(playCinematic, stageIndex)
        if not ok then
            warn("[CameraController] Cinematic error: " .. tostring(err))
            camera.CameraType = Enum.CameraType.Custom
            cinematicActive = false
        end
    end)
end)

print("[CameraController] Ready.")
]==]

local newScript = Instance.new("LocalScript")
newScript.Name = "CameraController"
newScript.Source = scriptSource
newScript.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
print("✅ CameraController LocalScript created in StarterPlayerScripts!")
