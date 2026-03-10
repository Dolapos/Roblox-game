--[[
    CombatRenderer.lua
    Listens to server combat events and renders animations/effects on the client.
    Enhanced with per-move R6 animations and fluid combat feel.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local AnimationUtil = require(ReplicatedStorage.Shared.Util.AnimationUtil)

local CombatRenderer = {}
CombatRenderer.__index = CombatRenderer

-- R6 animation IDs for combat (commonly available R6-compatible animations)
local ANIM_IDS = {
    -- Fist combo (R6 combat-like motions)
    FistJab = "rbxassetid://148840373",        -- Quick slash/swing
    FistCross = "rbxassetid://218504594",       -- Hit animation
    FistUppercut = "rbxassetid://169714156",    -- Upward strike

    -- Power cast (per-slot animations)
    CastQ = "rbxassetid://148840373",           -- Quick cast
    CastE = "rbxassetid://218504594",           -- Medium cast
    CastR = "rbxassetid://169714156",           -- Heavy cast

    -- Hit reactions
    HitStagger = "rbxassetid://33796059",       -- Flinch/stagger
}

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

    -- Select animation based on combo index
    local animId
    if data.comboIndex == 1 then
        animId = ANIM_IDS.FistJab
    elseif data.comboIndex == 2 then
        animId = ANIM_IDS.FistCross
    else
        animId = ANIM_IDS.FistUppercut
    end

    -- Play with increased speed for snappy feel
    AnimationUtil.playAnimation(humanoid, animId, {
        priority = Enum.AnimationPriority.Action,
        speed = 1.4,
        fadeTime = 0.05,
    })

    -- VFX
    if self._vfxController then
        self._vfxController:playFistVFX(caster.Character, data.comboIndex, data.origin, data.direction)
    end
end

function CombatRenderer:_renderMoveStart(data)
    local caster = data.caster
    if not caster or not caster.Character then return end

    local humanoid = caster.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Cast animation based on slot
    local animId
    if data.slot == "Q" then
        animId = ANIM_IDS.CastQ
    elseif data.slot == "E" then
        animId = ANIM_IDS.CastE
    else
        animId = ANIM_IDS.CastR
    end

    AnimationUtil.playAnimation(humanoid, animId, {
        priority = Enum.AnimationPriority.Action,
        speed = 1.2,
        fadeTime = 0.08,
    })

    -- Casting VFX (aura gather)
    if self._vfxController then
        self._vfxController:playCastStartVFX(caster.Character, data.moveId, data.origin, data.direction)
    end
end

function CombatRenderer:_renderMoveExecuted(data)
    local caster = data.caster
    if not caster or not caster.Character then return end

    -- Move execution VFX
    if self._vfxController then
        self._vfxController:playMoveVFX(data.moveId, data.origin, data.direction, caster.Character)
    end
end

function CombatRenderer:_renderHit(data)
    local target = data.target
    if not target or not target.Character then return end

    local targetHumanoid = target.Character:FindFirstChildOfClass("Humanoid")

    -- Play hit reaction animation on target
    if targetHumanoid then
        AnimationUtil.playAnimation(targetHumanoid, ANIM_IDS.HitStagger, {
            priority = Enum.AnimationPriority.Action2,
            speed = 1.5,
            fadeTime = 0.05,
        })
    end

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

    -- Camera shake when local player is hit
    if data.target == localPlayer then
        if self._uiController then
            self._uiController:cameraShake(data.damage / 25)
        end
    end
end

return CombatRenderer
