-- ONE BUTTON EMPIRE: Server WorldBuilder
-- Paste this into Roblox Studio Command Bar (View > Command Bar)
-- This creates the WorldBuilder Script in ServerScriptService
--
-- HOW MODELS WORK:
--   This script listens for the StageChanged RemoteEvent. When the stage changes,
--   it clears all models from Workspace/WorldModels and spawns in new ones
--   from a folder in ServerStorage named after the stage (e.g., "Stage_4_Village").
--
--   TO ADD YOUR OWN MODELS:
--   1. Run 17_Setup_Workspace.lua first to create the folder structure.
--   2. In ServerStorage, you'll find folders named Stage_0_Void through Stage_15_Singularity.
--   3. Build or import your 3D models in Studio.
--   4. Parent each model into the appropriate stage folder in ServerStorage.
--   5. When a player reaches that stage, WorldBuilder will clone and animate them in.
--
--   TIPS FOR MODELS:
--   - Models do NOT need to be anchored; the script will position them automatically.
--   - Parts will tween from scale 0 to full size for a "build" animation.
--   - You can use any Roblox models (free from the Toolbox works great).
--   - The button (TheButton) is NOT affected — it persists across all stages.

local scriptSource = [==[
-- WorldBuilder: Spawns and despawns world stage models
-- Runs as a server Script in ServerScriptService

local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")
local Players           = game:GetService("Players")

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEvents then
    error("[WorldBuilder] RemoteEvents not found in ReplicatedStorage!")
end
local stageChangedEvent     = remoteEvents:WaitForChild("StageChanged")
local triggerCinematicEvent = remoteEvents:WaitForChild("TriggerCinematic")

-- Load StageConfig module
local modules     = ReplicatedStorage:WaitForChild("Modules", 10)
local StageConfig = require(modules:WaitForChild("StageConfig"))

-- The folder in Workspace where we place world models
-- Run 17_Setup_Workspace.lua to create this folder
local worldModelsFolder = workspace:FindFirstChild("WorldModels")
if not worldModelsFolder then
    worldModelsFolder = Instance.new("Folder")
    worldModelsFolder.Name = "WorldModels"
    worldModelsFolder.Parent = workspace
    warn("[WorldBuilder] Created WorldModels folder. Run 17_Setup_Workspace.lua for full setup.")
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Clear all current world models with a shrink-out tween
-- ─────────────────────────────────────────────────────────────────────────────
local function clearWorldModels()
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    local tweens = {}

    for _, model in ipairs(worldModelsFolder:GetChildren()) do
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                -- Store original size then tween to zero
                local originalSize = part.Size
                part:SetAttribute("OriginalSize", originalSize)
                local tween = TweenService:Create(part, tweenInfo, {Size = Vector3.new(0.01, 0.01, 0.01)})
                table.insert(tweens, tween)
                tween:Play()
            end
        end
    end

    -- Wait for all tweens then destroy
    if #tweens > 0 then
        tweens[1].Completed:Wait()
    end
    task.wait(0.1)
    worldModelsFolder:ClearAllChildren()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Tween a part from zero size to its original size (build-in animation)
-- ─────────────────────────────────────────────────────────────────────────────
local function tweenPartIn(part, delay)
    local originalSize = part:GetAttribute("OriginalSize")
    if not originalSize then
        originalSize = part.Size
    end

    part.Size = Vector3.new(0.01, 0.01, 0.01)
    part.Anchored = true  -- anchor while animating

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.delay(delay, function()
        local tween = TweenService:Create(part, tweenInfo, {Size = originalSize})
        tween:Play()
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Load models for a given stage index
-- Looks in ServerStorage for a folder named after the stage's modelFolder
-- ─────────────────────────────────────────────────────────────────────────────
local function loadStageModels(stageIndex)
    local stageCfg = StageConfig[stageIndex]
    if not stageCfg then
        warn("[WorldBuilder] No config for stage " .. tostring(stageIndex))
        return
    end

    -- Look up the stage folder in ServerStorage
    -- ──────────────────────────────────────────────────────────────────────────
    -- 👇 THIS IS WHERE YOUR MODELS GO:
    --    Create a Folder in ServerStorage named: stageCfg.modelFolder
    --    (e.g., "Stage_4_Village") and put your 3D models inside it.
    --    Run 17_Setup_Workspace.lua to create all empty folders automatically.
    -- ──────────────────────────────────────────────────────────────────────────
    local stageFolder = ServerStorage:FindFirstChild(stageCfg.modelFolder)

    if not stageFolder then
        warn("[WorldBuilder] Stage folder not found in ServerStorage: '" .. stageCfg.modelFolder .. "'")
        warn("  → Create a Folder in ServerStorage named: " .. stageCfg.modelFolder)
        warn("  → Put your stage models inside that folder.")
        warn("  → Or run 17_Setup_Workspace.lua to create empty folders for all stages.")
        return
    end

    local children = stageFolder:GetChildren()
    if #children == 0 then
        -- Empty stage folder is OK — just means no world objects for this stage
        return
    end

    -- Clone each model and tween it into place
    local delay = 0
    for _, modelTemplate in ipairs(children) do
        local clone = modelTemplate:Clone()
        clone.Parent = worldModelsFolder

        -- Tween all BaseParts in the model into existence
        for _, part in ipairs(clone:GetDescendants()) do
            if part:IsA("BasePart") then
                part:SetAttribute("OriginalSize", part.Size)
                tweenPartIn(part, delay)
                delay = delay + 0.02  -- stagger each part slightly
            end
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Main stage-change handler
-- ─────────────────────────────────────────────────────────────────────────────
-- Note: OnServerEvent only fires when a client calls FireServer().
-- ClickHandler and PrestigeHandler call FireAllClients (server→client), which
-- does NOT trigger OnServerEvent. So we use a BindableEvent bridge below instead.
stageChangedEvent.OnServerEvent:Connect(function(player, newStage, oldStage)
    -- Reserved for any future client-initiated stage changes
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- BindableEvent bridge: other server scripts (ClickHandler, PrestigeHandler,
-- GameManager) fire _G.StageChangedBindable:Fire(newStage, oldStage) to trigger
-- WorldBuilder without going through a RemoteEvent.
-- ─────────────────────────────────────────────────────────────────────────────

local stageChangedBindable = Instance.new("BindableEvent")
stageChangedBindable.Name = "StageChangedServer"
stageChangedBindable.Parent = game.ServerScriptService

stageChangedBindable.Event:Connect(function(newStage, oldStage)
    -- Clear old world (with shrink animation)
    clearWorldModels()
    -- Load new stage models
    loadStageModels(newStage)
    -- Tell all clients to play the cinematic flyover
    triggerCinematicEvent:FireAllClients(newStage)
end)

-- Expose the BindableEvent for other scripts to fire
_G.StageChangedBindable = stageChangedBindable

-- ─────────────────────────────────────────────────────────────────────────────
-- Build initial world for all current players
-- ─────────────────────────────────────────────────────────────────────────────
local function buildInitialWorld()
    -- Find the most common current stage among players (use stage 0 for fresh game)
    local stage = 0
    for _, player in ipairs(Players:GetPlayers()) do
        local dm = _G.DataManager
        if dm then
            local data = dm.getData(player)
            if data and (data.currentStage or 0) > stage then
                stage = data.currentStage
            end
        end
    end
    loadStageModels(stage)
end

-- Wait a moment for DataManager to load, then build initial world
task.delay(3, buildInitialWorld)

print("[WorldBuilder] Ready. Watching for stage changes.")
print("[WorldBuilder] To add stage models: put them in ServerStorage/Stage_X_Name folders.")
]==]

local newScript = Instance.new("Script")
newScript.Name = "WorldBuilder"
newScript.Source = scriptSource
newScript.Parent = game:GetService("ServerScriptService")
print("✅ WorldBuilder Script created in ServerScriptService!")
