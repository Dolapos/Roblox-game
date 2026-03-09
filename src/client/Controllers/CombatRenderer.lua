--[[
    CombatRenderer.lua
    Listens to server combat events and renders animations/effects on the client.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local AnimationUtil = require(ReplicatedStorage.Shared.Util.AnimationUtil)

local CombatRenderer = {}
CombatRenderer.__index = CombatRenderer

function CombatRenderer.new(vfxController, uiController)
    local self = setmetatable({}, CombatRenderer)
    self._vfxController = vfxController
    self._uiController = uiController
    return self
end

function CombatRenderer:init()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    local combatRemote = remotesFolder:WaitForChild(Remotes.CombatEvent)

    combatRemote.OnClientEvent:Connect(function(eventData)
        self:_handleCombatEvent(eventData)
    end)
end

function CombatRenderer:_handleCombatEvent(eventData)
    local eventType = eventData.type

    if eventType == "FistAttack" then
        self:_renderFistAttack(eventData)
    elseif eventType == "MoveStart" then
        self:_renderMoveStart(eventData)
    elseif eventType == "MoveExecuted" then
        self:_renderMoveExecuted(eventData)
    elseif eventType == "Hit" then
        self:_renderHit(eventData)
    end
end

function CombatRenderer:_renderFistAttack(data)
    local caster = data.caster
    if not caster or not caster.Character then return end

    local humanoid = caster.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Play fist attack animation based on combo index
    local animIds = {
        "rbxassetid://0", -- Jab placeholder
        "rbxassetid://0", -- Cross placeholder
        "rbxassetid://0", -- Uppercut placeholder
    }

    local animId = animIds[data.comboIndex] or animIds[1]
    AnimationUtil.playAnimation(humanoid, animId, {
        priority = Enum.AnimationPriority.Action,
        speed = 1.2,
    })

    -- VFX for fist attack
    if self._vfxController then
        self._vfxController:playFistVFX(caster.Character, data.comboIndex, data.origin, data.direction)
    end
end

function CombatRenderer:_renderMoveStart(data)
    local caster = data.caster
    if not caster or not caster.Character then return end

    -- VFX for move cast start (charging effect)
    if self._vfxController then
        self._vfxController:playCastStartVFX(caster.Character, data.moveId, data.origin, data.direction)
    end
end

function CombatRenderer:_renderMoveExecuted(data)
    local caster = data.caster
    if not caster or not caster.Character then return end

    -- VFX for the move execution
    if self._vfxController then
        self._vfxController:playMoveVFX(data.moveId, data.origin, data.direction, caster.Character)
    end
end

function CombatRenderer:_renderHit(data)
    local target = data.target
    if not target or not target.Character then return end

    -- Hit VFX
    if self._vfxController then
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            self._vfxController:playHitVFX(targetRoot.Position, data.damage, data.damageType)
        end
    end

    -- Update UI for local player
    local localPlayer = Players.LocalPlayer
    if data.caster == localPlayer then
        if self._uiController then
            self._uiController:updateComboCounter(data.comboCount)
            self._uiController:showDamageNumber(data.damage, data.target)
        end
    end

    -- Camera shake for local player when hit
    if data.target == localPlayer then
        if self._uiController then
            self._uiController:cameraShake(data.damage / 30)
        end
    end
end

return CombatRenderer
