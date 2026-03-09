--[[
    TeleportService.lua
    Handles portal teleportation between Magic Hall and Arena.
    Detects when players touch the portal and teleports them.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZoneConfig = require(ReplicatedStorage.Shared.ZoneConfig)

local TeleportService = {}
TeleportService.__index = TeleportService

function TeleportService.new()
    local self = setmetatable({}, TeleportService)
    self._portalCooldowns = {} -- Prevent spam {[Player] = lastUseTime}
    self._portalCooldownTime = 2 -- seconds between teleports
    return self
end

function TeleportService:init()
    -- Setup portal touch detection
    task.spawn(function()
        self:_setupPortals()
    end)
end

function TeleportService:_setupPortals()
    -- Wait for Workspace to be ready
    local workspace = game:GetService("Workspace")

    -- Create portal from Magic Hall to Arena
    local portalFolder = workspace:FindFirstChild("Portal")
    if not portalFolder then
        portalFolder = Instance.new("Folder")
        portalFolder.Name = "Portal"
        portalFolder.Parent = workspace
    end

    -- Portal to Arena (in Magic Hall)
    local toArenaPortal = self:_createPortalPart("ToArenaPortal", CFrame.new(0, 8, -85))
    toArenaPortal.Parent = portalFolder

    toArenaPortal.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            self:teleportToArena(player)
        end
    end)

    -- Portal back to Magic Hall (in Arena)
    local toHallPortal = self:_createPortalPart("ToHallPortal", CFrame.new(0, 8, 410))
    toHallPortal.Parent = portalFolder

    toHallPortal.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            self:teleportToMagicHall(player)
        end
    end)
end

function TeleportService:_createPortalPart(name, cframe)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(12, 16, 4)
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.3
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(180, 120, 255)
    part.Shape = Enum.PartType.Block

    -- Add a particle effect
    local particle = Instance.new("ParticleEmitter")
    particle.Color = ColorSequence.new(Color3.fromRGB(200, 150, 255), Color3.fromRGB(100, 50, 200))
    particle.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    particle.Lifetime = NumberRange.new(0.5, 1.5)
    particle.Rate = 50
    particle.Speed = NumberRange.new(2, 5)
    particle.SpreadAngle = Vector2.new(180, 180)
    particle.LightEmission = 1
    particle.Parent = part

    -- Point light for glow
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(180, 120, 255)
    light.Brightness = 2
    light.Range = 20
    light.Parent = part

    -- Billboard label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 10, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true
    label.Font = Enum.Font.Fantasy
    label.Parent = billboard

    if name == "ToArenaPortal" then
        label.Text = "Enter Arena"
    else
        label.Text = "Return to Magic Hall"
    end

    return part
end

function TeleportService:teleportToArena(player)
    if not self:_canTeleport(player) then return end

    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local arenaZone = ZoneConfig.Zones.Arena
    rootPart.CFrame = arenaZone.spawnPoint

    self._portalCooldowns[player] = tick()
end

function TeleportService:teleportToMagicHall(player)
    if not self:_canTeleport(player) then return end

    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local hallZone = ZoneConfig.Zones.MagicHall
    rootPart.CFrame = hallZone.spawnPoint

    self._portalCooldowns[player] = tick()

    -- Heal player when returning to hall
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = humanoid.MaxHealth
    end
end

function TeleportService:_canTeleport(player)
    local lastUse = self._portalCooldowns[player]
    if lastUse and (tick() - lastUse) < self._portalCooldownTime then
        return false
    end
    return true
end

return TeleportService
