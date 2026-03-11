-- ONE BUTTON EMPIRE: Client ClickController
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the ClickController LocalScript in StarterPlayerScripts

local scriptSource = [==[
-- ClickController: Detects button clicks, sends them to the server,
-- and plays local animations/effects.
-- Runs as a LocalScript in StarterPlayerScripts

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local player = Players.LocalPlayer

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local clickEvent = remoteEvents:WaitForChild("Click")

-- ─────────────────────────────────────────────────────────────────────────────
-- Find the button model
-- The button MUST be named "TheButton" in Workspace
-- It must have a ClickDetector somewhere inside it
--
-- HOW TO SET UP YOUR BUTTON MODEL:
--   1. Run 16_Setup_ButtonModel.lua to create a placeholder button.
--   2. Or create your own model and name it "TheButton" in Workspace.
--   3. Add a ClickDetector to the part you want players to click.
--   4. Add a SurfaceGui named "ButtonGui" to the top surface of the button.
-- ─────────────────────────────────────────────────────────────────────────────
local button = workspace:WaitForChild("TheButton", 15)
if not button then
    warn("[ClickController] 'TheButton' not found in Workspace! Run 16_Setup_ButtonModel.lua first.")
    return
end

-- Find the ClickDetector (can be anywhere inside the model)
local clickDetector = button:FindFirstChildWhichIsA("ClickDetector", true)
if not clickDetector then
    warn("[ClickController] No ClickDetector found inside TheButton!")
    return
end

-- Find the clickable part (the part containing the ClickDetector)
local buttonPart = clickDetector.Parent
local buttonOriginalCFrame = buttonPart.CFrame
local buttonOriginalPosition = buttonPart.Position

-- Track click count for milestone effects
local totalClicksLocal = 0
local lastClickTime    = 0
local comboCount       = 0

-- ─────────────────────────────────────────────────────────────────────────────
-- Button depression animation: push down then spring back
-- ─────────────────────────────────────────────────────────────────────────────
local function animateButtonPress()
    if not buttonPart or not buttonPart.Parent then return end

    local pressInfo  = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local returnInfo = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local downCFrame = buttonPart.CFrame * CFrame.new(0, -0.2, 0)
    TweenService:Create(buttonPart, pressInfo,  {CFrame = downCFrame}):Play()
    task.delay(0.06, function()
        TweenService:Create(buttonPart, returnInfo, {CFrame = buttonOriginalCFrame}):Play()
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Spawn a particle burst at the button's position
-- Uses a BillboardGui with colored squares (no ParticleEmitter needed)
-- ─────────────────────────────────────────────────────────────────────────────
local function spawnParticleBurst(position, count, color)
    count = count or 8
    color = color or Color3.fromRGB(255, 200, 0)

    for i = 1, count do
        task.spawn(function()
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.3, 0.3, 0.3)
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.Color = color
            part.CFrame = CFrame.new(position)
            part.Parent = workspace

            -- Random outward direction
            local angle = (i / count) * math.pi * 2
            local speed = math.random(5, 12)
            local vel   = Vector3.new(math.cos(angle) * speed, math.random(3, 8), math.sin(angle) * speed)

            local info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(part, info, {
                CFrame  = CFrame.new(position + vel),
                Size    = Vector3.new(0.01, 0.01, 0.01),
            }):Play()

            task.delay(0.55, function()
                if part and part.Parent then part:Destroy() end
            end)
        end)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Show a floating text label above the button
-- ─────────────────────────────────────────────────────────────────────────────
local function showFloatingText(position, text, color)
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
    part.Parent = workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    -- Float upward and fade out
    local info = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(part, info, {CFrame = CFrame.new(position + Vector3.new(0, 6, 0))}):Play()
    TweenService:Create(label, info, {TextTransparency = 1}):Play()

    task.delay(1.3, function()
        if part and part.Parent then part:Destroy() end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Main click handler
-- ─────────────────────────────────────────────────────────────────────────────
clickDetector.MouseClick:Connect(function(clickPlayer)
    if clickPlayer ~= player then return end

    -- Send click to server
    clickEvent:FireServer()

    totalClicksLocal = totalClicksLocal + 1
    local now = tick()
    local timeSinceLast = now - lastClickTime
    lastClickTime = now

    -- Combo counter
    if timeSinceLast <= 0.3 then
        comboCount = comboCount + 1
    else
        comboCount = 0
    end

    local buttonPos = buttonPart.Position

    -- Animate button press
    animateButtonPress()

    -- Every 100th click: bigger burst + screen shake simulation
    if totalClicksLocal % 100 == 0 then
        spawnParticleBurst(buttonPos, 20, Color3.fromRGB(255, 100, 0))
        showFloatingText(buttonPos, "× 100!", Color3.fromRGB(255, 165, 0))
    else
        spawnParticleBurst(buttonPos, 8, Color3.fromRGB(255, 200, 50))
    end

    -- Combo display
    if comboCount >= 5 then
        showFloatingText(buttonPos + Vector3.new(1, 0, 0), "COMBO ×" .. comboCount, Color3.fromRGB(100, 200, 255))
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Listen for server-fired critical hit visual (triggered via UpdateUI)
-- The server sends the full data table; we check a flag for critical
-- ─────────────────────────────────────────────────────────────────────────────
-- Note: critical visual is also triggered via a special UpdateUI payload.
-- For now we use a simple golden flash on a random % locally.
-- A full implementation would have the server fire a dedicated RemoteEvent.
local critChanceLocal = 0.05
RunService.Heartbeat:Connect(function()
    -- Keep critChanceLocal in sync — it's updated by UIController from server data
    -- (see UIController.lua)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Milestone: every 100 clicks locally, flash the button gold
-- ─────────────────────────────────────────────────────────────────────────────
local originalButtonColor = buttonPart.Color

local function flashButtonGold()
    local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    TweenService:Create(buttonPart, info, {Color = Color3.fromRGB(255, 215, 0)}):Play()
    task.delay(0.3, function()
        TweenService:Create(buttonPart, info, {Color = originalButtonColor}):Play()
    end)
end

-- Every 100 clicks: gold flash
local lastMilestone = 0
clickDetector.MouseClick:Connect(function(p)
    if p ~= player then return end
    if totalClicksLocal > 0 and totalClicksLocal % 100 == 0 and totalClicksLocal ~= lastMilestone then
        lastMilestone = totalClicksLocal
        flashButtonGold()
    end
end)

print("[ClickController] Ready. Click TheButton to start!")
]==]

local newScript = Instance.new("LocalScript")
newScript.Name = "ClickController"
newScript.Source = scriptSource
newScript.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
print("✅ ClickController LocalScript created in StarterPlayerScripts!")
