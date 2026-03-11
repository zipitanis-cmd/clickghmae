-- ONE BUTTON EMPIRE: Client EventController
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the EventController LocalScript in StarterPlayerScripts

local scriptSource = [==[
-- EventController: Handles client-side random event visuals and player interaction.
-- Spawns visual objects, shows event UI overlay, and sends interaction back to server.
-- Runs as a LocalScript in StarterPlayerScripts

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     -- not accessible from client; event templates are cloned server-side

local player = Players.LocalPlayer

-- Wait for RemoteEvents
local remoteEvents  = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local eventAction   = remoteEvents:WaitForChild("EventAction")
local playSound     = remoteEvents:WaitForChild("PlaySound")

-- ─────────────────────────────────────────────────────────────────────────────
-- Event overlay UI (top of screen banner)
-- ─────────────────────────────────────────────────────────────────────────────
local playerGui = player.PlayerGui

local eventScreenGui = Instance.new("ScreenGui")
eventScreenGui.Name = "EventOverlay"
eventScreenGui.ResetOnSpawn = false
eventScreenGui.Parent = playerGui

local eventBanner = Instance.new("Frame")
eventBanner.Name = "EventBanner"
eventBanner.Size = UDim2.new(0.6, 0, 0.12, 0)
eventBanner.Position = UDim2.new(0.2, 0, -0.15, 0)  -- starts off-screen (above)
eventBanner.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
eventBanner.BackgroundTransparency = 0.1
eventBanner.BorderSizePixel = 0
eventBanner.Parent = eventScreenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = eventBanner

local eventTitle = Instance.new("TextLabel")
eventTitle.Size = UDim2.new(1, 0, 0.5, 0)
eventTitle.Position = UDim2.new(0, 0, 0, 0)
eventTitle.BackgroundTransparency = 1
eventTitle.Text = "EVENT"
eventTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
eventTitle.TextScaled = true
eventTitle.Font = Enum.Font.GothamBold
eventTitle.Parent = eventBanner

local eventDesc = Instance.new("TextLabel")
eventDesc.Size = UDim2.new(1, 0, 0.5, 0)
eventDesc.Position = UDim2.new(0, 0, 0.5, 0)
eventDesc.BackgroundTransparency = 1
eventDesc.Text = ""
eventDesc.TextColor3 = Color3.new(1, 1, 1)
eventDesc.TextScaled = true
eventDesc.Font = Enum.Font.Gotham
eventDesc.Parent = eventBanner

-- Timer bar
local timerBg = Instance.new("Frame")
timerBg.Size = UDim2.new(0.9, 0, 0.06, 0)
timerBg.Position = UDim2.new(0.05, 0, 0.88, 0)
timerBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
timerBg.BorderSizePixel = 0
timerBg.Parent = eventBanner

local timerBar = Instance.new("Frame")
timerBar.Size = UDim2.new(1, 0, 1, 0)
timerBar.Position = UDim2.new(0, 0, 0, 0)
timerBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
timerBar.BorderSizePixel = 0
timerBar.Parent = timerBg

-- ─────────────────────────────────────────────────────────────────────────────
-- Slide banner in / out
-- ─────────────────────────────────────────────────────────────────────────────
local function showEventBanner(title, description)
    eventTitle.Text = title
    eventDesc.Text  = description
    timerBar.Size   = UDim2.new(1, 0, 1, 0)

    -- Slide in from top
    TweenService:Create(eventBanner, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.2, 0, 0.02, 0)
    }):Play()
end

local function hideEventBanner()
    TweenService:Create(eventBanner, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.2, 0, -0.15, 0)
    }):Play()
end

-- Animate timer bar shrinking over an event's duration
local timerTween = nil
local function startTimer(duration)
    if timerTween then timerTween:Cancel() end
    timerBar.Size = UDim2.new(1, 0, 1, 0)
    timerTween = TweenService:Create(timerBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    })
    timerTween:Play()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Spawn a client-side visual for the event (floating object near button)
-- The object has a ClickDetector so the player can interact with it
-- ─────────────────────────────────────────────────────────────────────────────
local activeEventObjects = {}

local function spawnEventObject(eventId, position)
    -- Clean up any previous event objects
    for _, obj in ipairs(activeEventObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    activeEventObjects = {}

    -- Choose appearance based on event type
    local colors = {
        MeteorShower     = Color3.fromRGB(150, 75, 0),
        RoyalDecree      = Color3.fromRGB(255, 215, 0),
        RainbowSurge     = Color3.fromRGB(100, 200, 255),
        MysteryBox       = Color3.fromRGB(200, 100, 255),
        GhostClick       = Color3.fromRGB(200, 200, 255),
        VolcanicEruption = Color3.fromRGB(255, 80, 0),
        TimeRift         = Color3.fromRGB(0, 200, 200),
    }

    local shapes = {
        MeteorShower     = "Ball",
        RoyalDecree      = "Block",
        RainbowSurge     = "Cylinder",
        MysteryBox       = "Block",
        GhostClick       = "Ball",
        VolcanicEruption = "Ball",
        TimeRift         = "Cylinder",
    }

    local color = colors[eventId] or Color3.fromRGB(255, 255, 100)
    local shape = shapes[eventId] or "Ball"

    -- Create a glowing orb/box that the player can click
    local part = Instance.new("Part")
    part.Name = "EventObject_" .. eventId
    part.Size = Vector3.new(3, 3, 3)
    part.Shape = Enum.PartType[shape] or Enum.PartType.Ball
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Anchored = true
    part.CanCollide = false
    part.CFrame = CFrame.new(position or Vector3.new(0, 15, -10))
    part.Parent = workspace

    table.insert(activeEventObjects, part)

    -- Add a ClickDetector
    local cd = Instance.new("ClickDetector")
    cd.MaxActivationDistance = 50
    cd.Parent = part

    -- Add floating label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "👆 CLICK!"
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    -- Bobbing animation
    local startY = part.CFrame.Y
    local bobConn
    bobConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not part or not part.Parent then
            bobConn:Disconnect()
            return
        end
        local y = startY + math.sin(tick() * 2) * 1.0
        part.CFrame = CFrame.new(part.CFrame.X, y, part.CFrame.Z)
    end)
    table.insert(activeEventObjects, {
        Destroy = function()
            bobConn:Disconnect()
        end
    })

    -- Interaction handler — notify server
    cd.MouseClick:Connect(function(p)
        if p ~= player then return end
        eventAction:FireServer("interact", eventId)
        -- Destroy the object after interaction
        for _, obj in ipairs(activeEventObjects) do
            if type(obj) == "table" then
                obj:Destroy()
            elseif obj and obj.Parent then
                obj:Destroy()
            end
        end
        activeEventObjects = {}
    end)

    return part
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Handle event start / end signals from server
-- ─────────────────────────────────────────────────────────────────────────────
eventAction.OnClientEvent:Connect(function(action, eventId, eventName, description, duration)
    if action == "start" then
        -- Show the banner
        showEventBanner(eventName or eventId, description or "A random event has started!")

        -- Start the countdown timer bar
        if (duration or 0) > 0 then
            startTimer(duration)
        end

        -- Spawn the event object near the button
        local button = workspace:FindFirstChild("TheButton")
        local spawnPos = Vector3.new(8, 8, 0)
        if button then
            local bp = button:IsA("Model") and button.PrimaryPart or button:FindFirstChildWhichIsA("BasePart")
            if bp then
                spawnPos = bp.Position + Vector3.new(8, 6, 0)
            end
        end
        spawnEventObject(eventId, spawnPos)

    elseif action == "end" then
        -- Hide the banner and clean up
        hideEventBanner()
        for _, obj in ipairs(activeEventObjects) do
            if type(obj) == "table" then
                pcall(obj.Destroy, obj)
            elseif obj and obj.Parent then
                obj:Destroy()
            end
        end
        activeEventObjects = {}
    end
end)

print("[EventController] Ready. Listening for random events.")
]==]

local newScript = Instance.new("LocalScript")
newScript.Name = "EventController"
newScript.Source = scriptSource
newScript.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
print("✅ EventController LocalScript created in StarterPlayerScripts!")
