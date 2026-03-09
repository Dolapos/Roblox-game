--[[
    PowerManager.lua
    Manages power equipping/unequipping and validates power usage.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PowerRegistry = require(ReplicatedStorage.Data.PowerRegistry)

local PowerManager = {}
PowerManager.__index = PowerManager

function PowerManager.new(dataService, zoneManager)
    local self = setmetatable({}, PowerManager)
    self._dataService = dataService
    self._zoneManager = zoneManager
    self._equippedPowers = {} -- Runtime cache {[Player] = powerId}
    return self
end

function PowerManager:init()
    -- Listen for equip requests
    local equipRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.EquipPower)
    if equipRemote then
        equipRemote.OnServerEvent:Connect(function(player, powerId)
            self:equipPower(player, powerId)
        end)
    end

    local unequipRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.UnequipPower)
    if unequipRemote then
        unequipRemote.OnServerEvent:Connect(function(player)
            self:unequipPower(player)
        end)
    end
end

function PowerManager:equipPower(player, powerId)
    -- Validate: player must be in Magic Hall
    if not self._zoneManager:canPlayerEquipPowers(player) then
        self:_notifyPlayer(player, "You can only equip powers in the Magic Hall!")
        return false
    end

    -- Validate: power must exist
    local powerData = PowerRegistry.getPower(powerId)
    if not powerData then
        self:_notifyPlayer(player, "Invalid power!")
        return false
    end

    -- Validate: player must have unlocked this power
    if not self._dataService:isPowerUnlocked(player, powerId) then
        self:_notifyPlayer(player, "You haven't unlocked " .. powerData.name .. " yet! Need " .. powerData.hitsRequired .. " hits.")
        return false
    end

    -- Equip the power
    self._equippedPowers[player] = powerId
    self._dataService:setEquippedPower(player, powerId)

    -- Confirm to client
    local powerEquippedRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.PowerEquipped)
    if powerEquippedRemote then
        powerEquippedRemote:FireClient(player, powerId, powerData)
    end

    self:_notifyPlayer(player, "Equipped: " .. powerData.name)
    return true
end

function PowerManager:unequipPower(player)
    self._equippedPowers[player] = "Fists"
    self._dataService:setEquippedPower(player, "Fists")

    local powerEquippedRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.PowerEquipped)
    if powerEquippedRemote then
        powerEquippedRemote:FireClient(player, "Fists", PowerRegistry.getPower("Fists"))
    end
end

function PowerManager:getEquippedPower(player)
    return self._equippedPowers[player] or self._dataService:getEquippedPower(player) or "Fists"
end

function PowerManager:getEquippedPowerData(player)
    local powerId = self:getEquippedPower(player)
    return PowerRegistry.getPower(powerId)
end

function PowerManager:getMoveForSlot(player, slot)
    local powerId = self:getEquippedPower(player)
    local powerData = PowerRegistry.getPower(powerId)
    if not powerData then return nil end

    -- Find the move in this power that matches the slot
    local moveDefinitions = self:_getMoveDefinitions(powerData.category)
    if not moveDefinitions then return nil end

    for _, moveId in ipairs(powerData.moves) do
        local moveDef = moveDefinitions[moveId]
        if moveDef and moveDef.slot == slot then
            return moveDef
        end
    end

    return nil
end

function PowerManager:_getMoveDefinitions(category)
    local success, definitions = pcall(function()
        return require(ReplicatedStorage.Data.MoveDefinitions[category])
    end)
    if success then
        return definitions
    end
    -- Try alternate name mapping
    local nameMap = {
        Fists = "Fists",
        Elemental = "Elemental",
        Anime = "Anime",
        Mythological = "Mythological",
        SciFi = "SciFi",
        Unique = "Unique",
        UltraRare = "UltraRare",
    }
    local moduleName = nameMap[category]
    if moduleName then
        local s2, d2 = pcall(function()
            return require(ReplicatedStorage.Data.MoveDefinitions[moduleName])
        end)
        if s2 then return d2 end
    end
    return nil
end

function PowerManager:getAllMovesForPower(powerId)
    local powerData = PowerRegistry.getPower(powerId)
    if not powerData then return {} end

    local moveDefinitions = self:_getMoveDefinitions(powerData.category)
    if not moveDefinitions then return {} end

    local moves = {}
    for _, moveId in ipairs(powerData.moves) do
        local moveDef = moveDefinitions[moveId]
        if moveDef then
            moves[moveDef.slot] = moveDef
        end
    end
    return moves
end

function PowerManager:_notifyPlayer(player, message)
    local notifyRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.NotifyPlayer)
    if notifyRemote then
        notifyRemote:FireClient(player, {type = "Info", message = message})
    end
end

function PowerManager:onPlayerRemoved(player)
    self._equippedPowers[player] = nil
end

return PowerManager
