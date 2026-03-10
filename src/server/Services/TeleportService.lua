--[[
    TeleportService.lua
    Handles portal teleportation between Magic Hall and Arena.
    Detects when players walk through the portal archway or step on return portal.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ZoneConfig = require(ReplicatedStorage.Shared.ZoneConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local TeleportService = {}
TeleportService.__index = TeleportService

function TeleportService.new()
    local self = setmetatable({}, TeleportService)
    self._portalCooldowns = {}
    self._portalCooldownTime = 2
    return self
end

function TeleportService:init()
    task.spawn(function()
        self:_setupPortals()
    end)
end

function TeleportService:_setupPortals()
    local portalFolder = Workspace:FindFirstChild("Portal")
    if not portalFolder then
        portalFolder = Instance.new("Folder")
        portalFolder.Name = "Portal"
        portalFolder.Parent = Workspace
    end

    -- Portal trigger zone inside the Magic Hall archway
    -- The vortex visual is built by MapBuilder at (0, 12, 97)
    -- We place an invisible trigger just behind it
    local toArenaPortal = self:_createTriggerZone("ToArenaPortal",
        CFrame.new(0, 10, 100), Vector3.new(24, 20, 6))
    toArenaPortal.Parent = portalFolder

    toArenaPortal.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            self:teleportToArena(player)
        end
    end)

    -- Return portal in Arena (on the glowing pad at arena center Z-100)
    local toHallPortal = self:_createTriggerZone("ToHallPortal",
        CFrame.new(0, 3, 400), Vector3.new(14, 6, 14))
    toHallPortal.Parent = portalFolder

    toHallPortal.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            self:teleportToMagicHall(player)
        end
    end)

    -- Add label to return portal
    local returnBillboard = Instance.new("BillboardGui")
    returnBillboard.Size = UDim2.new(0, 220, 0, 50)
    returnBillboard.StudsOffset = Vector3.new(0, 6, 0)
    returnBillboard.AlwaysOnTop = true
    returnBillboard.Parent = toHallPortal

    local returnLabel = Instance.new("TextLabel")
    returnLabel.Size = UDim2.new(1, 0, 1, 0)
    returnLabel.BackgroundTransparency = 1
    returnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    returnLabel.TextStrokeColor3 = Color3.fromRGB(100, 50, 200)
    returnLabel.TextStrokeTransparency = 0.2
    returnLabel.TextScaled = true
    returnLabel.Font = Enum.Font.Fantasy
    returnLabel.Text = "Return to Magic Hall"
    returnLabel.Parent = returnBillboard
end

function TeleportService:_createTriggerZone(name, cframe, size)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
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

    -- Notify client of zone transition
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if remotesFolder then
        local notifyRemote = remotesFolder:FindFirstChild(Remotes.NotifyPlayer)
        if notifyRemote then
            notifyRemote:FireClient(player, {
                type = "Teleport",
                message = "You have entered the Arena!",
            })
        end
    end
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

    -- Heal when returning to hall
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
