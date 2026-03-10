--[[
    VFXController.lua
    Enhanced visual effects for combat moves.
    Per-move-type VFX with particles, trails, beams, rings, and screen effects.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Enums = require(ReplicatedStorage.Shared.Enums)

local VFXController = {}
VFXController.__index = VFXController

-- Color maps for different damage types (primary, secondary)
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
    [Enums.DamageType.Magma] = {Color3.fromRGB(255, 80, 0), Color3.fromRGB(200, 30, 0)},
    [Enums.DamageType.Storm] = {Color3.fromRGB(100, 100, 200), Color3.fromRGB(200, 200, 255)},
    [Enums.DamageType.Crystal] = {Color3.fromRGB(200, 150, 255), Color3.fromRGB(255, 200, 255)},
    [Enums.DamageType.Sand] = {Color3.fromRGB(220, 200, 130), Color3.fromRGB(180, 160, 100)},
}

function VFXController.new()
    local self = setmetatable({}, VFXController)
    self._vfxFolder = nil
    return self
end

function VFXController:init()
    self._vfxFolder = Instance.new("Folder")
    self._vfxFolder.Name = "VFX"
    self._vfxFolder.Parent = Workspace
end

----------------------------------------------
-- FIST VFX (enhanced with trails and impacts)
----------------------------------------------
function VFXController:playFistVFX(character, comboIndex, origin, direction)
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Punch swing trail
    local trailPart = Instance.new("Part")
    trailPart.Size = Vector3.new(1.5, 0.5, 3)
    trailPart.CFrame = rootPart.CFrame * CFrame.new(comboIndex == 1 and 1.5 or -1.5, 0, -2)
    trailPart.Anchored = true
    trailPart.CanCollide = false
    trailPart.Transparency = 0.4
    trailPart.Color = Color3.fromRGB(255, 255, 255)
    trailPart.Material = Enum.Material.Neon
    trailPart.Parent = self._vfxFolder

    -- Swing arc motion
    local arcEnd = rootPart.CFrame * CFrame.new(comboIndex == 1 and -1 or 1, 0, -4)
    local tween = TweenService:Create(trailPart, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = arcEnd,
        Transparency = 1,
        Size = Vector3.new(2, 1, 4),
    })
    tween:Play()
    Debris:AddItem(trailPart, 0.2)

    -- Impact burst particles at punch point
    local burstPos = rootPart.Position + rootPart.CFrame.LookVector * 3
    self:_createBurst(burstPos, Color3.fromRGB(255, 255, 255), 8, 0.15)

    -- Uppercut gets extra flair: upward ring + wind lines
    if comboIndex == 3 then
        self:_createImpactRing(burstPos, Color3.fromRGB(255, 255, 200), 10)
        self:_createWindLines(rootPart.Position, Vector3.new(0, 1, 0), Color3.fromRGB(255, 255, 200), 5)

        -- Ground crack effect
        self:_createGroundCrack(rootPart.Position, Color3.fromRGB(200, 200, 200), 6)
    end
end

----------------------------------------------
-- CAST START VFX (charging aura)
----------------------------------------------
function VFXController:playCastStartVFX(character, moveId, origin, direction)
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Aura ring expanding from character
    local aura = Instance.new("Part")
    aura.Size = Vector3.new(3, 0.3, 3)
    aura.Position = rootPart.Position
    aura.Shape = Enum.PartType.Cylinder
    aura.Orientation = Vector3.new(0, 0, 90)
    aura.Anchored = true
    aura.CanCollide = false
    aura.Transparency = 0.2
    aura.Color = Color3.fromRGB(200, 180, 255)
    aura.Material = Enum.Material.Neon
    aura.Parent = self._vfxFolder

    TweenService:Create(aura, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(8, 0.3, 8),
        Transparency = 1,
    }):Play()
    Debris:AddItem(aura, 0.5)

    -- Gathering particles (converge toward hands)
    local gatherEmitter = Instance.new("ParticleEmitter")
    gatherEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 180, 255))
    gatherEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    gatherEmitter.Lifetime = NumberRange.new(0.2, 0.4)
    gatherEmitter.Rate = 80
    gatherEmitter.Speed = NumberRange.new(8, 15)
    gatherEmitter.SpreadAngle = Vector2.new(180, 180)
    gatherEmitter.LightEmission = 1
    gatherEmitter.Parent = rootPart

    task.delay(0.4, function()
        if gatherEmitter.Parent then gatherEmitter:Destroy() end
    end)

    -- Body glow flash
    local glow = Instance.new("Part")
    glow.Size = Vector3.new(4, 6, 4)
    glow.CFrame = rootPart.CFrame
    glow.Shape = Enum.PartType.Ball
    glow.Anchored = true
    glow.CanCollide = false
    glow.Transparency = 0.4
    glow.Color = Color3.fromRGB(200, 180, 255)
    glow.Material = Enum.Material.Neon
    glow.Parent = self._vfxFolder

    TweenService:Create(glow, TweenInfo.new(0.5), {
        Transparency = 1,
        Size = Vector3.new(7, 9, 7),
    }):Play()
    Debris:AddItem(glow, 0.6)
end

----------------------------------------------
-- MOVE EXECUTION VFX (per-type effects)
----------------------------------------------
function VFXController:playMoveVFX(moveId, origin, direction, character)
    local colors = DAMAGE_TYPE_COLORS[Enums.DamageType.Physical] or {Color3.new(1,1,1), Color3.new(0.8,0.8,0.8)}

    -- Try to infer damage type from moveId for color
    for dtype, cols in pairs(DAMAGE_TYPE_COLORS) do
        if moveId and string.lower(moveId):find(string.lower(dtype)) then
            colors = cols
            break
        end
    end

    -- Main projectile/blast effect
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(4, 4, 4)
    effect.CFrame = CFrame.new(origin, origin + direction)
    effect.Shape = Enum.PartType.Ball
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.2
    effect.Color = colors[1]
    effect.Material = Enum.Material.Neon
    effect.Parent = self._vfxFolder

    -- Glow light on projectile
    local projLight = Instance.new("PointLight")
    projLight.Color = colors[1]
    projLight.Brightness = 3
    projLight.Range = 20
    projLight.Parent = effect

    -- Trail particles
    local trailParticles = Instance.new("ParticleEmitter")
    trailParticles.Color = ColorSequence.new(colors[1], colors[2])
    trailParticles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    trailParticles.Lifetime = NumberRange.new(0.3, 0.6)
    trailParticles.Rate = 80
    trailParticles.Speed = NumberRange.new(3, 8)
    trailParticles.SpreadAngle = Vector2.new(20, 20)
    trailParticles.LightEmission = 1
    trailParticles.Parent = effect

    -- Animate outward
    local endPos = origin + direction * 25
    TweenService:Create(effect, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = CFrame.new(endPos, endPos + direction),
        Transparency = 1,
        Size = Vector3.new(2, 2, 2),
    }):Play()
    Debris:AddItem(effect, 0.5)

    -- Muzzle flash at origin
    self:_createBurst(origin, colors[1], 12, 0.2)

    -- Ground disturbance ring at origin
    self:_createGroundCrack(origin, colors[2], 4)
end

----------------------------------------------
-- HIT VFX (enhanced with directional splash)
----------------------------------------------
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

    -- Impact light
    local impactLight = Instance.new("PointLight")
    impactLight.Color = colors[1]
    impactLight.Brightness = 4
    impactLight.Range = 15
    impactLight.Parent = flash

    -- Burst particles (more for heavier hits)
    local particleCount = math.clamp(damage, 8, 30)
    local hitParticles = Instance.new("ParticleEmitter")
    hitParticles.Color = ColorSequence.new(colors[1], colors[2])
    hitParticles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    hitParticles.Lifetime = NumberRange.new(0.2, 0.5)
    hitParticles.Rate = 0
    hitParticles.Speed = NumberRange.new(12, 25)
    hitParticles.SpreadAngle = Vector2.new(180, 180)
    hitParticles.LightEmission = 1
    hitParticles.Parent = flash
    hitParticles:Emit(particleCount)

    -- Scale with damage
    local maxSize = math.clamp(damage / 4, 2, 10)
    TweenService:Create(flash, TweenInfo.new(0.25), {
        Size = Vector3.new(maxSize, maxSize, maxSize),
        Transparency = 1,
    }):Play()
    Debris:AddItem(flash, 0.4)

    -- Impact ring (horizontal)
    self:_createImpactRing(position, colors[1], maxSize * 2)

    -- Vertical ring for heavy hits
    if damage >= 15 then
        self:_createVerticalRing(position, colors[2], maxSize * 1.5)
    end

    -- Ground crack for very heavy hits
    if damage >= 20 then
        self:_createGroundCrack(position, colors[2], maxSize)
    end
end

----------------------------------------------
-- EFFECT HELPERS
----------------------------------------------
function VFXController:_createImpactRing(position, color, maxSize)
    local ring = Instance.new("Part")
    ring.Size = Vector3.new(1, 0.1, 1)
    ring.Position = position
    ring.Shape = Enum.PartType.Cylinder
    ring.Orientation = Vector3.new(0, 0, 90)
    ring.Anchored = true
    ring.CanCollide = false
    ring.Transparency = 0.2
    ring.Color = color
    ring.Material = Enum.Material.Neon
    ring.Parent = self._vfxFolder

    TweenService:Create(ring, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(maxSize, 0.1, maxSize),
        Transparency = 1,
    }):Play()
    Debris:AddItem(ring, 0.4)
end

function VFXController:_createVerticalRing(position, color, maxSize)
    local ring = Instance.new("Part")
    ring.Size = Vector3.new(1, 1, 0.1)
    ring.Position = position
    ring.Anchored = true
    ring.CanCollide = false
    ring.Transparency = 0.3
    ring.Color = color
    ring.Material = Enum.Material.Neon
    ring.Parent = self._vfxFolder

    TweenService:Create(ring, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(maxSize, maxSize, 0.1),
        Transparency = 1,
    }):Play()
    Debris:AddItem(ring, 0.4)
end

function VFXController:_createBurst(position, color, count, lifetime)
    local burstPart = Instance.new("Part")
    burstPart.Size = Vector3.new(0.5, 0.5, 0.5)
    burstPart.Position = position
    burstPart.Anchored = true
    burstPart.CanCollide = false
    burstPart.Transparency = 1
    burstPart.Parent = self._vfxFolder

    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new(color)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Lifetime = NumberRange.new(lifetime or 0.2, (lifetime or 0.2) + 0.1)
    emitter.Rate = 0
    emitter.Speed = NumberRange.new(10, 20)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.LightEmission = 1
    emitter.Parent = burstPart
    emitter:Emit(count or 8)

    Debris:AddItem(burstPart, (lifetime or 0.2) + 0.2)
end

function VFXController:_createWindLines(position, direction, color, count)
    for i = 1, count do
        local offset = Vector3.new(math.random(-3, 3), math.random(-1, 1), math.random(-3, 3))
        local line = Instance.new("Part")
        line.Size = Vector3.new(0.2, 0.2, 3)
        line.CFrame = CFrame.new(position + offset, position + offset + direction)
        line.Anchored = true
        line.CanCollide = false
        line.Transparency = 0.3
        line.Color = color
        line.Material = Enum.Material.Neon
        line.Parent = self._vfxFolder

        TweenService:Create(line, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CFrame = CFrame.new(position + offset + direction * 6, position + offset + direction * 7),
            Transparency = 1,
            Size = Vector3.new(0.1, 0.1, 5),
        }):Play()
        Debris:AddItem(line, 0.3)
    end
end

function VFXController:_createGroundCrack(position, color, radius)
    -- Flat ring expanding on ground
    local crack = Instance.new("Part")
    crack.Size = Vector3.new(1, 0.05, 1)
    crack.Position = Vector3.new(position.X, 0.1, position.Z)
    crack.Shape = Enum.PartType.Cylinder
    crack.Orientation = Vector3.new(0, 0, 90)
    crack.Anchored = true
    crack.CanCollide = false
    crack.Transparency = 0.3
    crack.Color = color
    crack.Material = Enum.Material.Neon
    crack.Parent = self._vfxFolder

    local maxSize = radius * 2
    TweenService:Create(crack, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(maxSize, 0.05, maxSize),
        Transparency = 1,
    }):Play()
    Debris:AddItem(crack, 0.5)
end

return VFXController
