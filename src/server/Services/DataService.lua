--[[
    DataService.lua
    Handles player data persistence using DataStoreService.
    Saves: total hits, unlocked powers, equipped power, settings.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)

local DataService = {}
DataService.__index = DataService

local DEFAULT_DATA = {
    totalHits = 0,
    unlockedPowers = {"Fists", "Quickstep"},
    equippedPower = "Fists",
    settings = {
        cameraShake = true,
        controllerVibrations = true,
        detailedFoliage = true,
        dynamicLights = true,
        globalShadows = true,
        lowMapParticles = false,
        mapTextures = true,
        muteAmbience = false,
        muteSounds = false,
        muteMusic = false,
    },
}

function DataService.new()
    local self = setmetatable({}, DataService)
    self._dataStore = nil
    self._playerData = {} -- {[Player] = data}
    self._saveQueue = {} -- players that need saving
    return self
end

function DataService:init()
    -- Try to get DataStore (may fail in Studio without API access)
    local success, store = pcall(function()
        return DataStoreService:GetDataStore(Constants.DATA_STORE_NAME)
    end)

    if success then
        self._dataStore = store
    else
        warn("[DataService] Could not access DataStore. Using session-only data.")
    end

    -- Handle player join/leave
    Players.PlayerAdded:Connect(function(player)
        self:_loadPlayerData(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:_savePlayerData(player)
        self._playerData[player] = nil
    end)

    -- Load data for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:_loadPlayerData(player)
    end

    -- Auto-save loop
    task.spawn(function()
        while true do
            task.wait(Constants.DATA_SAVE_INTERVAL)
            self:_saveAllPlayers()
        end
    end)

    -- Save on server shutdown
    game:BindToClose(function()
        self:_saveAllPlayers()
    end)
end

function DataService:_loadPlayerData(player)
    local data = nil

    if self._dataStore then
        local success, result = pcall(function()
            return self._dataStore:GetAsync("Player_" .. player.UserId)
        end)

        if success and result then
            data = result
        end
    end

    -- Use default data if nothing loaded, merge with defaults for missing fields
    if not data then
        data = self:_deepCopy(DEFAULT_DATA)
    else
        -- Fill in any missing fields from defaults
        for key, defaultValue in pairs(DEFAULT_DATA) do
            if data[key] == nil then
                if type(defaultValue) == "table" then
                    data[key] = self:_deepCopy(defaultValue)
                else
                    data[key] = defaultValue
                end
            end
        end
    end

    self._playerData[player] = data
end

function DataService:_savePlayerData(player)
    local data = self._playerData[player]
    if not data or not self._dataStore then return end

    local success, err = pcall(function()
        self._dataStore:SetAsync("Player_" .. player.UserId, data)
    end)

    if not success then
        warn("[DataService] Failed to save data for " .. player.Name .. ": " .. tostring(err))
    end
end

function DataService:_saveAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        self:_savePlayerData(player)
    end
end

function DataService:getData(player)
    return self._playerData[player]
end

function DataService:getTotalHits(player)
    local data = self._playerData[player]
    return data and data.totalHits or 0
end

function DataService:addHits(player, amount)
    local data = self._playerData[player]
    if data then
        data.totalHits = data.totalHits + amount
        return data.totalHits
    end
    return 0
end

function DataService:getEquippedPower(player)
    local data = self._playerData[player]
    return data and data.equippedPower or "Fists"
end

function DataService:setEquippedPower(player, powerId)
    local data = self._playerData[player]
    if data then
        data.equippedPower = powerId
    end
end

function DataService:getUnlockedPowers(player)
    local data = self._playerData[player]
    return data and data.unlockedPowers or {"Fists", "Quickstep"}
end

function DataService:unlockPower(player, powerId)
    local data = self._playerData[player]
    if data then
        for _, id in ipairs(data.unlockedPowers) do
            if id == powerId then return false end -- Already unlocked
        end
        table.insert(data.unlockedPowers, powerId)
        return true
    end
    return false
end

function DataService:isPowerUnlocked(player, powerId)
    local data = self._playerData[player]
    if data then
        for _, id in ipairs(data.unlockedPowers) do
            if id == powerId then return true end
        end
    end
    return false
end

function DataService:_deepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = self:_deepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

return DataService
