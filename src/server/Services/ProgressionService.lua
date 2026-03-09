--[[
    ProgressionService.lua
    Manages hit counting, power unlocks, and progression notifications.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ProgressionThresholds = require(ReplicatedStorage.Data.ProgressionThresholds)

local ProgressionService = {}
ProgressionService.__index = ProgressionService

function ProgressionService.new(dataService)
    local self = setmetatable({}, ProgressionService)
    self._dataService = dataService
    self._progressionRemote = nil
    self._notifyRemote = nil
    return self
end

function ProgressionService:init()
    self._progressionRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.ProgressionUpdate)
    self._notifyRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.NotifyPlayer)
end

function ProgressionService:registerHit(player)
    local oldHits = self._dataService:getTotalHits(player)
    local newHits = self._dataService:addHits(player, 1)

    -- Check for new unlocks
    local newUnlocks = self:_checkUnlocks(player, oldHits, newHits)

    -- Send progression update to client
    if self._progressionRemote then
        self._progressionRemote:FireClient(player, {
            totalHits = newHits,
            newUnlocks = newUnlocks,
            nextMilestone = ProgressionThresholds.getNextMilestone(newHits),
        })
    end

    return newHits, newUnlocks
end

function ProgressionService:_checkUnlocks(player, oldHits, newHits)
    local newUnlocks = {}

    for _, threshold in ipairs(ProgressionThresholds) do
        -- If we just crossed this threshold
        if oldHits < threshold.hits and newHits >= threshold.hits then
            for _, powerId in ipairs(threshold.unlocks) do
                local wasNew = self._dataService:unlockPower(player, powerId)
                if wasNew then
                    table.insert(newUnlocks, powerId)
                end
            end

            -- Notify player of new milestone
            if self._notifyRemote and #newUnlocks > 0 then
                self._notifyRemote:FireClient(player, {
                    type = "Milestone",
                    message = threshold.message,
                    unlocks = threshold.unlocks,
                })
            end
        end
    end

    return newUnlocks
end

function ProgressionService:getPlayerProgression(player)
    local totalHits = self._dataService:getTotalHits(player)
    return {
        totalHits = totalHits,
        unlockedPowers = self._dataService:getUnlockedPowers(player),
        equippedPower = self._dataService:getEquippedPower(player),
        nextMilestone = ProgressionThresholds.getNextMilestone(totalHits),
    }
end

return ProgressionService
