-- ONE BUTTON EMPIRE: Setup Button Model
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates a placeholder "TheButton" model in Workspace.
--
-- ════════════════════════════════════════════════════════════════════════════
-- REPLACE THIS WITH YOUR OWN MODEL:
--   This script creates a simple placeholder button so the game works
--   immediately. Once you have designed your own button model:
--
--   1. Build your custom button in Studio (any shape you like).
--   2. Name the root Model "TheButton".
--   3. The clickable part (the top of the button) should have a ClickDetector.
--   4. The clickable part should have a SurfaceGui named "ButtonGui" on the
--      face the player will see (typically the top face).
--   5. Delete this placeholder model from Workspace.
--   6. Put your new model into Workspace.
--
-- REQUIREMENTS for scripts to work:
--   - Model named exactly:  TheButton  (in Workspace)
--   - ClickDetector inside the model (in any descendant part)
--   - A SurfaceGui (any face is fine; UIController finds it automatically)
-- ════════════════════════════════════════════════════════════════════════════

-- Remove existing button if present
local existing = workspace:FindFirstChild("TheButton")
if existing then existing:Destroy() end

-- ─────────────────────────────────────────────────────────────────────────────
-- Build the placeholder button
-- Structure:
--   TheButton (Model)
--   ├── Pedestal     (cylinder, grey)
--   ├── ButtonTop    (cylinder, red — this is the clickable part)
--   │   ├── ClickDetector
--   │   └── SurfaceGui "ButtonGui"
-- ─────────────────────────────────────────────────────────────────────────────

local buttonModel = Instance.new("Model")
buttonModel.Name = "TheButton"

-- Pedestal
local pedestal = Instance.new("Part")
pedestal.Name = "Pedestal"
pedestal.Shape = Enum.PartType.Cylinder
pedestal.Size = Vector3.new(2, 4, 2)
pedestal.Material = Enum.Material.SmoothPlastic
pedestal.Color = Color3.fromRGB(60, 60, 60)
pedestal.Anchored = true
pedestal.CFrame = CFrame.new(0, 2, 0) * CFrame.Angles(0, 0, math.rad(90))
pedestal.Parent = buttonModel

-- Button top (the actual clickable part)
local buttonTop = Instance.new("Part")
buttonTop.Name = "ButtonTop"
buttonTop.Shape = Enum.PartType.Cylinder
buttonTop.Size = Vector3.new(0.8, 3.5, 3.5)
buttonTop.Material = Enum.Material.SmoothPlastic
buttonTop.Color = Color3.fromRGB(220, 30, 30)  -- bright red
buttonTop.Anchored = true
-- Position on top of the pedestal, rotated so the flat face points up
buttonTop.CFrame = CFrame.new(0, 4.4, 0) * CFrame.Angles(0, 0, math.rad(90))
buttonTop.Parent = buttonModel

-- ClickDetector on the button top
local clickDetector = Instance.new("ClickDetector")
clickDetector.MaxActivationDistance = 20
clickDetector.Parent = buttonTop

-- Neon ring (visual flair around the button edge)
local ring = Instance.new("Part")
ring.Name = "NeonRing"
ring.Shape = Enum.PartType.Cylinder
ring.Size = Vector3.new(0.3, 4.2, 4.2)
ring.Material = Enum.Material.Neon
ring.Color = Color3.fromRGB(255, 80, 80)
ring.Anchored = true
ring.CFrame = CFrame.new(0, 4.4, 0) * CFrame.Angles(0, 0, math.rad(90))
ring.CanCollide = false
ring.Parent = buttonModel

-- SurfaceGui on the top face of ButtonTop
-- UIController will populate this with click count, power, etc.
local surfaceGui = Instance.new("SurfaceGui")
surfaceGui.Name = "ButtonGui"
surfaceGui.Face = Enum.NormalId.Right  -- "Right" because the cylinder is rotated 90°
surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
surfaceGui.PixelsPerStud = 50
surfaceGui.Parent = buttonTop

-- Placeholder label inside the SurfaceGui
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.35, 0)
titleLabel.Position = UDim2.new(0, 0, 0.1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ ONE BUTTON EMPIRE"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = surfaceGui

local clickLabel = Instance.new("TextLabel")
clickLabel.Name = "ClickMeLabel"
clickLabel.Size = UDim2.new(1, 0, 0.3, 0)
clickLabel.Position = UDim2.new(0, 0, 0.45, 0)
clickLabel.BackgroundTransparency = 1
clickLabel.Text = "[ CLICK ME ]"
clickLabel.TextColor3 = Color3.new(1, 1, 1)
clickLabel.TextScaled = true
clickLabel.Font = Enum.Font.GothamBold
clickLabel.Parent = surfaceGui

local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Size = UDim2.new(1, 0, 0.2, 0)
statsLabel.Position = UDim2.new(0, 0, 0.75, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "+1 per click"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.TextScaled = true
statsLabel.Font = Enum.Font.Gotham
statsLabel.Parent = surfaceGui

-- Set the model's PrimaryPart for easy positioning
buttonModel.PrimaryPart = pedestal
buttonModel.Parent = workspace

print("✅ TheButton placeholder model created in Workspace!")
print("   → Replace it with your own model when ready.")
print("   → Keep the ClickDetector and SurfaceGui named 'ButtonGui'.")
