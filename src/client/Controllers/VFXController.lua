--[[
    VFXController.lua
    Manages visual effects for combat moves.
    Creates particle effects, beams, explosions etc based on move type.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Enums = require(ReplicatedStorage.Shared.Enums)

local VFXController = {}
VFXController.__index = VFXController

-- Color maps for different damage types
local DAMAGE_TYPE_COLORS = {
    [Enums.DamageType.Physical] = {Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200)},
    [Enums.DamageType.Fire] = {Color3.fromRGB(255, 150, 30), Color3.fromRGB(255, 50, 0)},
    [Enums.DamageType.Ice] = {Color3.fromRGB(150, 220, 255), Color3.fromRGB(100, 180, 255)},
    [Enums.DamageType.Lightning] = {Color3.fromRGB(255, 255, 100), Color3.fromRGB(200, 200, 255)},
    [Enums.DamageType.Earth] = {Color3.fromRGB(180, 140, 80), Color3.fromRGB(120, 90, 50)},
    [Enums.DamageType.Wind] = {Color3.fromRGB(200, 255, 200), Color3.fromRGB(150, 255, 150)},
    [Enums.DamageType.Dark] = {Color3.fromRGB(80, 0, 120), Color3.fromRGB(40, 0, 60)},
    [Enums.DamageType.Light] = {Color3.fromRGB(255, 255, 200), Color3.fromRGB(255, 230, 150)},
    [Enums.DamageType.Psychic] = {Color3.fromRGB(200, 100, 255), Color3.fromRGB(150, 50, 200)},
    [Enums.DamageType.Time] = {Color3.fromRGB(255, 215, 0), Color3.fromRGB(200, 170, 0)},
    [Enums.DamageType.Tech] = {Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 150, 200)},
    [Enums.DamageType.Chaos] = {Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 100)},
    [Enums.DamageType.Celestial] = {Color3.fromRGB(255, 255, 200), Color3.fromRGB(200, 180, 255)},
    [Enums.DamageType.Dragon] = {Color3.fromRGB(255, 100, 0), Color3.fromRGB(200, 50, 0)},
    [Enums.DamageType.Spirit] = {Color3.fromRGB(100, 255, 150), Color3.fromRGB(50, 200, 100)},
    [Enums.DamageType.Poison] = {Color3.fromRGB(100, 200, 50), Color3.fromRGB(50, 150, 25)},
}

function VFXController.new()
    local self = setmetatable({}, VFXController)
    self._vfxFolder = nil
    return self
end

function VFXController:init()
    -- Create a folder for VFX parts
    self._vfxFolder = Instance.new("Folder")
    self._vfxFolder.Name = "VFX"
    self._vfxFolder.Parent = Workspace
end

function VFXController:playFistVFX(character, comboIndex, origin, direction)
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Create a quick punch trail effect
    local punchEffect = Instance.new("Part")
    punchEffect.Size = Vector3.new(1, 1, 2)
    punchEffect.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
    punchEffect.Anchored = true
    punchEffect.CanCollide = false
    punchEffect.Transparency = 0.5
    punchEffect.Color = Color3.fromRGB(255, 255, 255)
    punchEffect.Material = Enum.Material.Neon
    punchEffect.Parent = self._vfxFolder

    -- Quick fade out
    local tween = TweenService:Create(punchEffect, TweenInfo.new(0.2), {
        Transparency = 1,
        Size = Vector3.new(2, 2, 4),
    })
    tween:Play()

    Debris:AddItem(punchEffect, 0.3)

    -- Uppercut gets extra flair
    if comboIndex == 3 then
        self:_createImpactRing(rootPart.Position + Vector3.new(0, 0, -3), Color3.fromRGB(255, 255, 200), 8)
    end
end

function VFXController:playCastStartVFX(character, moveId, origin, direction)
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Generic casting glow on hands
    local glow = Instance.new("Part")
    glow.Size = Vector3.new(2, 2, 2)
    glow.CFrame = rootPart.CFrame
    glow.Shape = Enum.PartType.Ball
    glow.Anchored = true
    glow.CanCollide = false
    glow.Transparency = 0.3
    glow.Color = Color3.fromRGB(200, 180, 255)
    glow.Material = Enum.Material.Neon
    glow.Parent = self._vfxFolder

    local tween = TweenService:Create(glow, TweenInfo.new(0.5), {
        Transparency = 1,
        Size = Vector3.new(5, 5, 5),
    })
    tween:Play()

    Debris:AddItem(glow, 0.6)
end

function VFXController:playMoveVFX(moveId, origin, direction, character)
    -- Generic move execution VFX
    -- In a full implementation, each move would have its own VFX function

    local colors = DAMAGE_TYPE_COLORS[Enums.DamageType.Physical] or {Color3.new(1,1,1), Color3.new(0.8,0.8,0.8)}

    -- Create projectile/burst effect at origin
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(4, 4, 4)
    effect.CFrame = CFrame.new(origin, origin + direction)
    effect.Shape = Enum.PartType.Ball
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.3
    effect.Color = colors[1]
    effect.Material = Enum.Material.Neon
    effect.Parent = self._vfxFolder

    -- Particles
    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(colors[1], colors[2])
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    particles.Lifetime = NumberRange.new(0.3, 0.6)
    particles.Rate = 100
    particles.Speed = NumberRange.new(5, 10)
    particles.SpreadAngle = Vector2.new(30, 30)
    particles.LightEmission = 1
    particles.Parent = effect

    -- Animate outward along direction
    local endPos = origin + direction * 20
    local tween = TweenService:Create(effect, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = CFrame.new(endPos, endPos + direction),
        Transparency = 1,
    })
    tween:Play()

    Debris:AddItem(effect, 0.5)
end

function VFXController:playHitVFX(position, damage, damageType)
    local colors = DAMAGE_TYPE_COLORS[damageType] or DAMAGE_TYPE_COLORS[Enums.DamageType.Physical]

    -- Impact flash
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(2, 2, 2)
    flash.Position = position
    flash.Shape = Enum.PartType.Ball
    flash.Anchored = true
    flash.CanCollide = false
    flash.Transparency = 0
    flash.Color = colors[1]
    flash.Material = Enum.Material.Neon
    flash.Parent = self._vfxFolder

    -- Impact particles
    local hitParticles = Instance.new("ParticleEmitter")
    hitParticles.Color = ColorSequence.new(colors[1], colors[2])
    hitParticles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0),
    })
    hitParticles.Lifetime = NumberRange.new(0.2, 0.4)
    hitParticles.Rate = 0  -- Burst only
    hitParticles.Speed = NumberRange.new(10, 20)
    hitParticles.SpreadAngle = Vector2.new(180, 180)
    hitParticles.LightEmission = 1
    hitParticles.Parent = flash
    hitParticles:Emit(15)

    -- Scale effect with damage
    local maxSize = math.clamp(damage / 5, 2, 8)
    local tween = TweenService:Create(flash, TweenInfo.new(0.2), {
        Size = Vector3.new(maxSize, maxSize, maxSize),
        Transparency = 1,
    })
    tween:Play()

    Debris:AddItem(flash, 0.4)

    -- Impact ring
    self:_createImpactRing(position, colors[1], maxSize * 2)
end

function VFXController:_createImpactRing(position, color, maxSize)
    local ring = Instance.new("Part")
    ring.Size = Vector3.new(1, 0.1, 1)
    ring.Position = position
    ring.Shape = Enum.PartType.Cylinder
    ring.Orientation = Vector3.new(0, 0, 90)
    ring.Anchored = true
    ring.CanCollide = false
    ring.Transparency = 0.3
    ring.Color = color
    ring.Material = Enum.Material.Neon
    ring.Parent = self._vfxFolder

    local tween = TweenService:Create(ring, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(maxSize, 0.1, maxSize),
        Transparency = 1,
    })
    tween:Play()

    Debris:AddItem(ring, 0.4)
end

return VFXController
