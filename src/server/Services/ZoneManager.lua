--[[
    ZoneManager.lua
    Tracks which zone each player is in and enforces zone rules.
    Checks player position periodically against zone bounding boxes.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZoneConfig = require(ReplicatedStorage.Shared.ZoneConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local ZoneManager = {}
ZoneManager.__index = ZoneManager

function ZoneManager.new()
    local self = setmetatable({}, ZoneManager)
    self._playerZones = {} -- {[Player] = zoneName}
    self._zoneChangedRemote = nil
    return self
end

function ZoneManager:init()
    -- Get or create remote
    self._zoneChangedRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.ZoneChanged)

    -- Track new players
    Players.PlayerAdded:Connect(function(player)
        self._playerZones[player] = "MagicHall" -- Start in Magic Hall
    end)

    Players.PlayerRemoving:Connect(function(player)
        self._playerZones[player] = nil
    end)

    -- Set initial zones for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self._playerZones[player] = "MagicHall"
    end

    -- Periodically update player zones based on position
    RunService.Heartbeat:Connect(function()
        self:_updatePlayerZones()
    end)
end

function ZoneManager:_updatePlayerZones()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local newZone = ZoneConfig.getZoneAtPosition(humanoidRootPart.Position)
                local oldZone = self._playerZones[player]

                if newZone ~= oldZone then
                    self._playerZones[player] = newZone
                    self:_onZoneChanged(player, oldZone, newZone)
                end
            end
        end
    end
end

function ZoneManager:_onZoneChanged(player, oldZone, newZone)
    -- Fire remote to client
    if self._zoneChangedRemote then
        self._zoneChangedRemote:FireClient(player, newZone, oldZone)
    end

    -- Enforce zone rules
    local zoneData = ZoneConfig.Zones[newZone]
    if zoneData then
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Reset health when entering Magic Hall (safe zone)
                if newZone == "MagicHall" and humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end
    end
end

function ZoneManager:getPlayerZone(player)
    return self._playerZones[player] or "Unknown"
end

function ZoneManager:canPlayerUsePowers(player)
    local zone = self:getPlayerZone(player)
    local zoneData = ZoneConfig.Zones[zone]
    return zoneData and zoneData.canUsePowers or false
end

function ZoneManager:canPlayerTakeDamage(player)
    local zone = self:getPlayerZone(player)
    local zoneData = ZoneConfig.Zones[zone]
    return zoneData and zoneData.canTakeDamage or false
end

function ZoneManager:canPlayerEquipPowers(player)
    local zone = self:getPlayerZone(player)
    local zoneData = ZoneConfig.Zones[zone]
    return zoneData and zoneData.canEquipPowers or false
end

function ZoneManager:isPlayerInArena(player)
    return self:getPlayerZone(player) == "Arena"
end

function ZoneManager:isPlayerInMagicHall(player)
    return self:getPlayerZone(player) == "MagicHall"
end

return ZoneManager
