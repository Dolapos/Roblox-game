--[[
    PowerVisualsService.lua
    Manages visual accessories on R6 characters based on their selected power.
    When a player equips a power, their character visually reflects it with
    particle emitters, color tints, glow effects, and cosmetic parts.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PowerRegistry = require(ReplicatedStorage.Data.PowerRegistry)

local PowerVisualsService = {}
PowerVisualsService.__index = PowerVisualsService

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local VISUALS_FOLDER_NAME = "PowerVisuals"

-- Default novice robe colors (neutral gray)
local DEFAULT_SHIRT_COLOR = Color3.fromRGB(120, 120, 120)
local DEFAULT_PANTS_COLOR = Color3.fromRGB(100, 100, 100)

-- Sash dimensions
local SASH_SIZE = Vector3.new(0.3, 1.8, 0.3)
local SASH_OFFSET = CFrame.new(0.8, 0, 0)

-- Neon trim dimensions (for tier 5+)
local TRIM_SIZE = Vector3.new(0.15, 1.6, 1.1)
local TRIM_OFFSET = CFrame.new(0, -0.3, 0)

-- Power-to-visual-group mapping
local VISUAL_GROUPS = {
    FireHands       = { "Fire", "Ember", "Magma", "Hellfire" },
    IceHands        = { "Ice", "Crystal" },
    LightningHands  = { "Lightning", "Storm", "ThunderGod" },
    WindFeet        = { "Wind", "Quickstep" },
    EarthFeet       = { "Earth", "Sand" },
    PoisonHands     = { "PoisonGas" },
    ExplosionFists  = { "Explosion" },
    HardeningTorso  = { "Hardening" },
    OverdriveAura   = { "Overdrive" },
    ShadowParticles = { "ShadowStand", "SoulDrain" },
    TimeParticles   = { "TimePunch", "TimeStop" },
    GlitchParticles = { "Copy", "GlitchAbility" },
    BerserkerEyes   = { "Berserker" },
    EnergyHands     = { "EnergyAura", "LaserBeam", "EnergyShield" },
    DragonGlow      = { "DragonForm", "DragonGod" },
    PhoenixWings    = { "PhoenixRebirth" },
    MinotaurDust    = { "MinotaurStrength" },
    PsychicHead     = { "Telekinesis", "MindControl", "GravityField" },
    NanobotSwarm    = { "NanobotSwarm" },
    PortalHands     = { "TrapMaster", "PortalMaker" },
    BanHammerGlow   = { "BanHammer" },
    RubberTint      = { "RubberBody" },
    VoidParticles   = { "RealityWarp", "BlackHole" },
    CelestialGlow   = { "CelestialJudgment" },
}

-- Build a reverse lookup: powerId -> visual group name
local POWER_TO_GROUP = {}
for groupName, powerIds in pairs(VISUAL_GROUPS) do
    for _, powerId in ipairs(powerIds) do
        POWER_TO_GROUP[powerId] = groupName
    end
end

--------------------------------------------------------------------------------
-- Helper: Create a basic ParticleEmitter
--------------------------------------------------------------------------------

local function createParticleEmitter(props)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = props.Color or ColorSequence.new(Color3.new(1, 1, 1))
    emitter.Size = props.Size or NumberSequence.new(0.3)
    emitter.Transparency = props.Transparency or NumberSequence.new(0, 1)
    emitter.Lifetime = props.Lifetime or NumberRange.new(0.5, 1)
    emitter.Rate = props.Rate or 20
    emitter.Speed = props.Speed or NumberRange.new(1, 3)
    emitter.SpreadAngle = props.SpreadAngle or Vector2.new(30, 30)
    emitter.LightEmission = props.LightEmission or 0.5
    emitter.LightInfluence = props.LightInfluence or 0
    emitter.Name = props.Name or "PowerParticle"
    emitter.LockedToPart = props.LockedToPart or false
    if props.Rotation then
        emitter.Rotation = props.Rotation
    end
    if props.RotSpeed then
        emitter.RotSpeed = props.RotSpeed
    end
    if props.Acceleration then
        emitter.Acceleration = props.Acceleration
    end
    return emitter
end

--------------------------------------------------------------------------------
-- Helper: Create a PointLight
--------------------------------------------------------------------------------

local function createPointLight(color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness or 1
    light.Range = range or 6
    light.Name = "PowerLight"
    return light
end

--------------------------------------------------------------------------------
-- Helper: Create an attachment on a part (for particles)
--------------------------------------------------------------------------------

local function getOrCreateAttachment(part, name)
    local existing = part:FindFirstChild(name)
    if existing and existing:IsA("Attachment") then
        return existing
    end
    local att = Instance.new("Attachment")
    att.Name = name
    att.Parent = part
    return att
end

--------------------------------------------------------------------------------
-- Helper: Create a cosmetic part welded to a character part
--------------------------------------------------------------------------------

local function createWeldedPart(parent, host, size, offset, color, props)
    local part = Instance.new("Part")
    part.Name = props and props.Name or "VisualPart"
    part.Size = size
    part.Color = color
    part.Anchored = false
    part.CanCollide = false
    part.Massless = true
    part.Material = (props and props.Material) or Enum.Material.SmoothPlastic
    if props and props.Transparency then
        part.Transparency = props.Transparency
    end
    if props and props.Reflectance then
        part.Reflectance = props.Reflectance
    end

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = host
    weld.Part1 = part
    weld.Name = "VisualWeld"
    weld.Parent = part

    part.CFrame = host.CFrame * offset
    part.Parent = parent
    return part
end

--------------------------------------------------------------------------------
-- Visual Group Applicators
-- Each function receives (visualsFolder, character, powerData)
--------------------------------------------------------------------------------

local Applicators = {}

function Applicators.FireHands(folder, character, _powerData)
    for _, handName in ipairs({"Left Arm", "Right Arm"}) do
        local hand = character:FindFirstChild(handName)
        if hand then
            local emitter = createParticleEmitter({
                Name = "FireParticle",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 80, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 0)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.4),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Lifetime = NumberRange.new(0.3, 0.7),
                Rate = 30,
                Speed = NumberRange.new(1, 4),
                LightEmission = 1,
                Acceleration = Vector3.new(0, 3, 0),
            })
            emitter.Parent = hand

            local glow = createPointLight(Color3.fromRGB(255, 120, 30), 0.8, 5)
            glow.Parent = hand
        end
    end
end

function Applicators.IceHands(folder, character, _powerData)
    for _, handName in ipairs({"Left Arm", "Right Arm"}) do
        local hand = character:FindFirstChild(handName)
        if hand then
            local emitter = createParticleEmitter({
                Name = "FrostParticle",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 230, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 200, 255)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.2),
                    NumberSequenceKeypoint.new(0.5, 0.35),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Lifetime = NumberRange.new(0.5, 1.2),
                Rate = 25,
                Speed = NumberRange.new(0.5, 2),
                LightEmission = 0.8,
                SpreadAngle = Vector2.new(60, 60),
            })
            emitter.Parent = hand
        end
    end

    -- Slight blue tint on torso
    local torso = character:FindFirstChild("Torso")
    if torso then
        local light = createPointLight(Color3.fromRGB(150, 200, 255), 0.4, 4)
        light.Name = "IceTorsoGlow"
        light.Parent = torso
    end
end

function Applicators.LightningHands(folder, character, _powerData)
    for _, handName in ipairs({"Left Arm", "Right Arm"}) do
        local hand = character:FindFirstChild(handName)
        if hand then
            local emitter = createParticleEmitter({
                Name = "SparkParticle",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 100)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 200)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.15),
                    NumberSequenceKeypoint.new(0.3, 0.3),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Lifetime = NumberRange.new(0.1, 0.3),
                Rate = 40,
                Speed = NumberRange.new(3, 8),
                LightEmission = 1,
                SpreadAngle = Vector2.new(180, 180),
            })
            emitter.Parent = hand

            local glow = createPointLight(Color3.fromRGB(255, 255, 100), 0.6, 4)
            glow.Parent = hand
        end
    end
end

function Applicators.WindFeet(folder, character, _powerData)
    for _, legName in ipairs({"Left Leg", "Right Leg"}) do
        local leg = character:FindFirstChild(legName)
        if leg then
            local emitter = createParticleEmitter({
                Name = "WindParticle",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 255, 220)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 0.3),
                    NumberSequenceKeypoint.new(1, 0.1),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.5),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Lifetime = NumberRange.new(0.4, 0.8),
                Rate = 25,
                Speed = NumberRange.new(2, 5),
                LightEmission = 0.3,
                SpreadAngle = Vector2.new(180, 180),
                Rotation = NumberRange.new(0, 360),
                RotSpeed = NumberRange.new(100, 300),
            })
            emitter.Parent = leg
        end
    end
end

function Applicators.EarthFeet(folder, character, _powerData)
    for _, legName in ipairs({"Left Leg", "Right Leg"}) do
        local leg = character:FindFirstChild(legName)
        if leg then
            local emitter = createParticleEmitter({
                Name = "DustParticle",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 120, 70)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 90, 50)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.2),
                    NumberSequenceKeypoint.new(1, 0.5),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.3),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Lifetime = NumberRange.new(0.5, 1.0),
                Rate = 20,
                Speed = NumberRange.new(1, 3),
                LightEmission = 0,
                SpreadAngle = Vector2.new(90, 90),
                Acceleration = Vector3.new(0, -2, 0),
            })
            emitter.Parent = leg
        end
    end
end

function Applicators.PoisonHands(folder, character, _powerData)
    for _, handName in ipairs({"Left Arm", "Right Arm"}) do
        local hand = character:FindFirstChild(handName)
        if hand then
            local emitter = createParticleEmitter({
                Name = "PoisonParticle",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 200, 50)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 30)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.3),
                    NumberSequenceKeypoint.new(1, 0.6),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.4),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Lifetime = NumberRange.new(0.6, 1.2),
                Rate = 18,
                Speed = NumberRange.new(0.5, 2),
                LightEmission = 0.4,
                SpreadAngle = Vector2.new(60, 60),
            })
            emitter.Parent = hand
        end
    end
end

function Applicators.ExplosionFists(folder, character, _powerData)
    for _, handName in ipairs({"Left Arm", "Right Arm"}) do
        local hand = character:FindFirstChild(handName)
        if hand then
            local emitter = createParticleEmitter({
                Name = "SparkBurst",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 0)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.15),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Lifetime = NumberRange.new(0.1, 0.3),
                Rate = 15,
                Speed = NumberRange.new(4, 8),
                LightEmission = 1,
                SpreadAngle = Vector2.new(180, 180),
            })
            emitter.Parent = hand
        end
    end
end

function Applicators.HardeningTorso(folder, character, _powerData)
    local torso = character:FindFirstChild("Torso")
    if torso then
        -- Store original reflectance so we know this is a visual effect
        torso.Reflectance = 0.4
        torso.Material = Enum.Material.Metal

        -- Also apply to arms
        for _, partName in ipairs({"Left Arm", "Right Arm"}) do
            local part = character:FindFirstChild(partName)
            if part then
                part.Reflectance = 0.3
                part.Material = Enum.Material.Metal
            end
        end

        -- Metallic sheen light
        local light = createPointLight(Color3.fromRGB(200, 200, 210), 0.3, 4)
        light.Name = "MetalSheen"
        light.Parent = torso
    end
end

function Applicators.OverdriveAura(folder, character, _powerData)
    local torso = character:FindFirstChild("Torso")
    if torso then
        local emitter = createParticleEmitter({
            Name = "OverdriveAura",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 0)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.5),
                NumberSequenceKeypoint.new(0.5, 1.0),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Lifetime = NumberRange.new(0.5, 1.0),
            Rate = 35,
            Speed = NumberRange.new(1, 3),
            LightEmission = 0.8,
            SpreadAngle = Vector2.new(180, 180),
            Acceleration = Vector3.new(0, 2, 0),
        })
        emitter.Parent = torso

        local glow = createPointLight(Color3.fromRGB(255, 30, 30), 0.6, 8)
        glow.Parent = torso
    end

    -- Also add to limbs for "whole body" effect
    for _, partName in ipairs({"Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
        local part = character:FindFirstChild(partName)
        if part then
            local emitter = createParticleEmitter({
                Name = "OverdriveAuraLimb",
                Color = ColorSequence.new(Color3.fromRGB(255, 50, 50)),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.2),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.5),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Lifetime = NumberRange.new(0.3, 0.6),
                Rate = 12,
                Speed = NumberRange.new(1, 2),
                LightEmission = 0.7,
                SpreadAngle = Vector2.new(180, 180),
            })
            emitter.Parent = part
        end
    end
end

function Applicators.ShadowParticles(folder, character, _powerData)
    local torso = character:FindFirstChild("Torso")
    if torso then
        local emitter = createParticleEmitter({
            Name = "ShadowParticle",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 0, 40)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.4),
                NumberSequenceKeypoint.new(1, 0.8),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.4),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Lifetime = NumberRange.new(0.6, 1.5),
            Rate = 20,
            Speed = NumberRange.new(0.5, 2),
            LightEmission = 0,
            LightInfluence = 1,
            SpreadAngle = Vector2.new(180, 180),
        })
        emitter.Parent = torso
    end

    for _, handName in ipairs({"Left Arm", "Right Arm"}) do
        local hand = character:FindFirstChild(handName)
        if hand then
            local emitter = createParticleEmitter({
                Name = "ShadowHandParticle",
                Color = ColorSequence.new(Color3.fromRGB(40, 0, 70)),
                Size = NumberSequence.new(0.2),
                Lifetime = NumberRange.new(0.3, 0.6),
                Rate = 10,
                Speed = NumberRange.new(0.5, 1.5),
                LightEmission = 0,
                LightInfluence = 1,
            })
            emitter.Parent = hand
        end
    end
end

function Applicators.TimeParticles(folder, character, _powerData)
    local head = character:FindFirstChild("Head")
    if head then
        -- Golden clock-like particles near eyes
        local emitter = createParticleEmitter({
            Name = "TimeParticle",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 50)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(0.5, 0.2),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Lifetime = NumberRange.new(0.5, 1.0),
            Rate = 12,
            Speed = NumberRange.new(0.3, 1),
            LightEmission = 1,
            SpreadAngle = Vector2.new(30, 30),
            Rotation = NumberRange.new(0, 360),
            RotSpeed = NumberRange.new(50, 150),
        })
        emitter.Parent = head

        local glow = createPointLight(Color3.fromRGB(255, 215, 0), 0.5, 4)
        glow.Parent = head

        -- Small golden ring near head
        local ring = createWeldedPart(
            folder, head,
            Vector3.new(0.1, 0.1, 0.1),
            CFrame.new(0, 1.2, 0),
            Color3.fromRGB(255, 215, 0),
            {
                Name = "TimeRing",
                Material = Enum.Material.Neon,
                Transparency = 0.3,
            }
        )
        -- Make it look ring-like with a mesh
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Sphere
        mesh.Scale = Vector3.new(15, 2, 15)
        mesh.Parent = ring
    end
end

function Applicators.GlitchParticles(folder, character, _powerData)
    local torso = character:FindFirstChild("Torso")
    if torso then
        local emitter = createParticleEmitter({
            Name = "GlitchParticle",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(0.2, 0),
                NumberSequenceKeypoint.new(0.4, 0.2),
                NumberSequenceKeypoint.new(0.6, 0),
                NumberSequenceKeypoint.new(1, 0.1),
            }),
            Lifetime = NumberRange.new(0.1, 0.4),
            Rate = 25,
            Speed = NumberRange.new(2, 6),
            LightEmission = 1,
            SpreadAngle = Vector2.new(180, 180),
        })
        emitter.Parent = torso
    end
end

function Applicators.BerserkerEyes(folder, character, _powerData)
    local head = character:FindFirstChild("Head")
    if head then
        local glow = createPointLight(Color3.fromRGB(255, 0, 0), 1.2, 8)
        glow.Name = "BerserkerEyeGlow"
        glow.Parent = head
    end
end

function Applicators.EnergyHands(folder, character, _powerData)
    for _, handName in ipairs({"Left Arm", "Right Arm"}) do
        local hand = character:FindFirstChild(handName)
        if hand then
            local emitter = createParticleEmitter({
                Name = "EnergyParticle",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.2),
                    NumberSequenceKeypoint.new(0.5, 0.35),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Lifetime = NumberRange.new(0.3, 0.7),
                Rate = 25,
                Speed = NumberRange.new(1, 3),
                LightEmission = 1,
                SpreadAngle = Vector2.new(45, 45),
            })
            emitter.Parent = hand

            local glow = createPointLight(Color3.fromRGB(0, 200, 255), 0.6, 5)
            glow.Parent = hand
        end
    end
end

function Applicators.DragonGlow(folder, character, _powerData)
    local head = character:FindFirstChild("Head")
    if head then
        local glow = createPointLight(Color3.fromRGB(255, 150, 0), 1.0, 8)
        glow.Name = "DragonHeadGlow"
        glow.Parent = head
    end

    -- Fire trail particles on torso
    local torso = character:FindFirstChild("Torso")
    if torso then
        local emitter = createParticleEmitter({
            Name = "DragonTrail",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 30)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 80, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 0.6),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Lifetime = NumberRange.new(0.4, 0.8),
            Rate = 25,
            Speed = NumberRange.new(1, 3),
            LightEmission = 1,
            SpreadAngle = Vector2.new(40, 40),
            Acceleration = Vector3.new(0, 2, 0),
        })
        emitter.Parent = torso
    end
end

function Applicators.PhoenixWings(folder, character, _powerData)
    local torso = character:FindFirstChild("Torso")
    if torso then
        -- Orange/gold wing-like particles on back
        local emitter = createParticleEmitter({
            Name = "PhoenixWingParticle",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 130, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 0)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(0.3, 0.8),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Lifetime = NumberRange.new(0.5, 1.2),
            Rate = 35,
            Speed = NumberRange.new(2, 5),
            LightEmission = 1,
            SpreadAngle = Vector2.new(60, 20),
            Acceleration = Vector3.new(0, 3, 0),
        })

        -- Attach to back of torso via attachment
        local att = getOrCreateAttachment(torso, "PhoenixBackAttachment")
        att.Position = Vector3.new(0, 0, 0.6)
        emitter.Parent = att

        local glow = createPointLight(Color3.fromRGB(255, 160, 30), 0.8, 8)
        glow.Name = "PhoenixGlow"
        glow.Parent = torso
    end
end

function Applicators.MinotaurDust(folder, character, _powerData)
    -- Brown aura on torso
    local torso = character:FindFirstChild("Torso")
    if torso then
        local emitter = createParticleEmitter({
            Name = "MinotaurAura",
            Color = ColorSequence.new(Color3.fromRGB(120, 80, 40)),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 0.6),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.5),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Lifetime = NumberRange.new(0.5, 1.0),
            Rate = 15,
            Speed = NumberRange.new(0.5, 2),
            LightEmission = 0,
        })
        emitter.Parent = torso
    end

    -- Thick dust near feet
    for _, legName in ipairs({"Left Leg", "Right Leg"}) do
        local leg = character:FindFirstChild(legName)
        if leg then
            local emitter = createParticleEmitter({
                Name = "MinotaurDust",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 50)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 70, 30)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.3),
                    NumberSequenceKeypoint.new(1, 0.8),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.3),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Lifetime = NumberRange.new(0.6, 1.2),
                Rate = 20,
                Speed = NumberRange.new(1, 3),
                SpreadAngle = Vector2.new(90, 90),
                Acceleration = Vector3.new(0, -3, 0),
            })
            emitter.Parent = leg
        end
    end
end

function Applicators.PsychicHead(folder, character, _powerData)
    local head = character:FindFirstChild("Head")
    if head then
        local emitter = createParticleEmitter({
            Name = "PsychicParticle",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 100, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 50, 200)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.15),
                NumberSequenceKeypoint.new(0.5, 0.25),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Lifetime = NumberRange.new(0.4, 0.8),
            Rate = 20,
            Speed = NumberRange.new(0.5, 2),
            LightEmission = 0.8,
            SpreadAngle = Vector2.new(180, 180),
            Rotation = NumberRange.new(0, 360),
            RotSpeed = NumberRange.new(30, 100),
        })
        emitter.Parent = head

        local glow = createPointLight(Color3.fromRGB(180, 100, 255), 0.5, 5)
        glow.Parent = head
    end
end

function Applicators.NanobotSwarm(folder, character, _powerData)
    local torso = character:FindFirstChild("Torso")
    if torso then
        local emitter = createParticleEmitter({
            Name = "NanobotParticle",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 210)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 220)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 190)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.05),
                NumberSequenceKeypoint.new(0.5, 0.1),
                NumberSequenceKeypoint.new(1, 0.05),
            }),
            Lifetime = NumberRange.new(0.3, 0.8),
            Rate = 60,
            Speed = NumberRange.new(2, 5),
            LightEmission = 0.6,
            SpreadAngle = Vector2.new(180, 180),
            LockedToPart = true,
        })
        emitter.Parent = torso
    end
end

function Applicators.PortalHands(folder, character, _powerData)
    for _, handName in ipairs({"Left Arm", "Right Arm"}) do
        local hand = character:FindFirstChild(handName)
        if hand then
            local emitter = createParticleEmitter({
                Name = "PortalParticle",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 50, 200)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 20, 150)),
                }),
                Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 0.2),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.4),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Lifetime = NumberRange.new(0.4, 0.8),
                Rate = 15,
                Speed = NumberRange.new(0.5, 2),
                LightEmission = 0.6,
                SpreadAngle = Vector2.new(60, 60),
                Rotation = NumberRange.new(0, 360),
                RotSpeed = NumberRange.new(60, 180),
            })
            emitter.Parent = hand
        end
    end
end

function Applicators.BanHammerGlow(folder, character, _powerData)
    local rightArm = character:FindFirstChild("Right Arm")
    if rightArm then
        local glow = createPointLight(Color3.fromRGB(255, 0, 0), 1.0, 6)
        glow.Name = "BanHammerGlow"
        glow.Parent = rightArm

        local emitter = createParticleEmitter({
            Name = "BanHammerParticle",
            Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.15),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Lifetime = NumberRange.new(0.2, 0.5),
            Rate = 12,
            Speed = NumberRange.new(0.5, 1.5),
            LightEmission = 1,
        })
        emitter.Parent = rightArm
    end
end

function Applicators.RubberTint(folder, character, _powerData)
    -- Slight pink tint and stretchy transparency
    for _, partName in ipairs({"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
        local part = character:FindFirstChild(partName)
        if part then
            part.Color = Color3.fromRGB(
                math.min(255, part.Color.R * 255 * 0.8 + 255 * 0.2),
                math.min(255, part.Color.G * 255 * 0.7),
                math.min(255, part.Color.B * 255 * 0.7 + 200 * 0.3)
            )
            part.Transparency = 0.1
            part.Material = Enum.Material.SmoothPlastic
        end
    end
end

function Applicators.VoidParticles(folder, character, _powerData)
    local torso = character:FindFirstChild("Torso")
    if torso then
        local emitter = createParticleEmitter({
            Name = "VoidParticle",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 80)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 0, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(0.5, 0.7),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Lifetime = NumberRange.new(0.5, 1.5),
            Rate = 25,
            Speed = NumberRange.new(1, 3),
            LightEmission = 0,
            LightInfluence = 1,
            SpreadAngle = Vector2.new(180, 180),
        })
        emitter.Parent = torso
    end

    -- Void effect on hands
    for _, handName in ipairs({"Left Arm", "Right Arm"}) do
        local hand = character:FindFirstChild(handName)
        if hand then
            local emitter = createParticleEmitter({
                Name = "VoidHandParticle",
                Color = ColorSequence.new(Color3.fromRGB(40, 0, 60)),
                Size = NumberSequence.new(0.15),
                Lifetime = NumberRange.new(0.2, 0.5),
                Rate = 10,
                Speed = NumberRange.new(0.5, 1.5),
                LightEmission = 0,
                LightInfluence = 1,
            })
            emitter.Parent = hand
        end
    end
end

function Applicators.CelestialGlow(folder, character, _powerData)
    -- Golden holy light particles
    local torso = character:FindFirstChild("Torso")
    if torso then
        local emitter = createParticleEmitter({
            Name = "CelestialParticle",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 200)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 100)),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(0.5, 0.5),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Lifetime = NumberRange.new(0.5, 1.2),
            Rate = 30,
            Speed = NumberRange.new(1, 4),
            LightEmission = 1,
            SpreadAngle = Vector2.new(180, 180),
            Acceleration = Vector3.new(0, 3, 0),
        })
        emitter.Parent = torso
    end

    -- Bright head glow
    local head = character:FindFirstChild("Head")
    if head then
        local glow = createPointLight(Color3.fromRGB(255, 255, 180), 1.5, 12)
        glow.Name = "CelestialHeadGlow"
        glow.Parent = head

        local emitter = createParticleEmitter({
            Name = "CelestialHeadParticle",
            Color = ColorSequence.new(Color3.fromRGB(255, 255, 200)),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Lifetime = NumberRange.new(0.3, 0.6),
            Rate = 15,
            Speed = NumberRange.new(0.5, 2),
            LightEmission = 1,
            SpreadAngle = Vector2.new(180, 180),
        })
        emitter.Parent = head
    end
end

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------

function PowerVisualsService.new()
    local self = setmetatable({}, PowerVisualsService)
    self._visualConnections = {} -- {[Player] = {connections}}
    return self
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function PowerVisualsService:init()
    local powerEquippedRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.PowerEquipped)
    if powerEquippedRemote then
        powerEquippedRemote.OnServerEvent:Connect(function(player, powerId)
            self:applyVisuals(player, powerId)
        end)
    end

    -- Also listen for the server-side fire (PowerEquipped is typically fired to the
    -- client, so we also hook into the EquipPower remote to catch equips server-side)
    local equipRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.EquipPower)
    if equipRemote then
        equipRemote.OnServerEvent:Connect(function(player, powerId)
            -- Slight delay to let PowerManager process first
            task.defer(function()
                self:applyVisuals(player, powerId)
            end)
        end)
    end

    local unequipRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.UnequipPower)
    if unequipRemote then
        unequipRemote.OnServerEvent:Connect(function(player)
            self:applyVisuals(player, "Fists")
        end)
    end

    -- Clean up on player leaving
    game:GetService("Players").PlayerRemoving:Connect(function(player)
        self:clearVisuals(player)
        self._visualConnections[player] = nil
    end)

    -- Handle respawns: reapply visuals when character is added
    game:GetService("Players").PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(_character)
            -- Wait for character to load
            task.wait(0.5)
            -- Reapply visuals if the player has a stored power
            -- (PowerManager stores equipped power; we listen for re-equip events)
        end)
    end)
end

--------------------------------------------------------------------------------
-- Main visual application
--------------------------------------------------------------------------------

function PowerVisualsService:applyVisuals(player, powerId)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Clear any existing visuals first
    self:clearVisuals(player)

    -- Look up power data
    local powerData = PowerRegistry.getPower(powerId)
    if not powerData then return end

    -- Create visuals folder
    local visualsFolder = Instance.new("Folder")
    visualsFolder.Name = VISUALS_FOLDER_NAME
    visualsFolder.Parent = character

    -- Apply default robe (shirt/pants color tint)
    self:_applyRobeColors(character, powerData)

    -- Apply power-specific visual effects
    if powerId ~= "Fists" then
        local groupName = POWER_TO_GROUP[powerId]
        if groupName and Applicators[groupName] then
            -- Move particle emitters and lights into the visuals folder tracking
            -- (they are parented to character parts for positioning, but we track
            --  them via the folder for cleanup)
            Applicators[groupName](visualsFolder, character, powerData)
        end

        -- Apply color accent sash
        self:_applySash(visualsFolder, character, powerData)

        -- Apply tier-based trim
        self:_applyTierTrim(visualsFolder, character, powerData)
    end
end

--------------------------------------------------------------------------------
-- Clear all visuals
--------------------------------------------------------------------------------

function PowerVisualsService:clearVisuals(player)
    local character = player.Character
    if not character then return end

    -- Remove visuals folder and all welded parts in it
    local visualsFolder = character:FindFirstChild(VISUALS_FOLDER_NAME)
    if visualsFolder then
        visualsFolder:Destroy()
    end

    -- Remove any particle emitters, point lights, and attachments added by this service
    -- from character body parts
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("ParticleEmitter") and child.Name:find("Particle") or child.Name:find("Aura") or child.Name:find("Trail") or child.Name:find("Burst") or child.Name:find("Dust") then
                    child:Destroy()
                elseif child:IsA("PointLight") and (child.Name:find("Glow") or child.Name:find("Sheen") or child.Name == "PowerLight") then
                    child:Destroy()
                elseif child:IsA("Attachment") and child.Name:find("Attachment") and child.Name:find("Phoenix") or child.Name:find("Power") then
                    child:Destroy()
                end
            end

            -- Reset material/reflectance changes from Hardening
            if part.Reflectance > 0.2 then
                part.Reflectance = 0
            end
            if part.Material == Enum.Material.Metal then
                part.Material = Enum.Material.SmoothPlastic
            end
            -- Reset transparency from RubberBody
            if part.Transparency > 0 and part.Transparency <= 0.15 then
                part.Transparency = 0
            end
        end
    end

    -- Reset shirt/pants color (body colors)
    local bodyColors = character:FindFirstChildOfClass("BodyColors")
    if bodyColors then
        bodyColors.TorsoColor3 = DEFAULT_SHIRT_COLOR
        bodyColors.LeftArmColor3 = DEFAULT_SHIRT_COLOR
        bodyColors.RightArmColor3 = DEFAULT_SHIRT_COLOR
        bodyColors.LeftLegColor3 = DEFAULT_PANTS_COLOR
        bodyColors.RightLegColor3 = DEFAULT_PANTS_COLOR
    end
end

--------------------------------------------------------------------------------
-- Robe color application
--------------------------------------------------------------------------------

function PowerVisualsService:_applyRobeColors(character, powerData)
    local bodyColors = character:FindFirstChildOfClass("BodyColors")
    if not bodyColors then
        bodyColors = Instance.new("BodyColors")
        bodyColors.Parent = character
    end

    local displayColor = powerData.displayColor or DEFAULT_SHIRT_COLOR

    -- Blend power color with the gray robe base for a tinted look
    local blendFactor = 0.3
    local shirtR = DEFAULT_SHIRT_COLOR.R * (1 - blendFactor) + displayColor.R * blendFactor
    local shirtG = DEFAULT_SHIRT_COLOR.G * (1 - blendFactor) + displayColor.G * blendFactor
    local shirtB = DEFAULT_SHIRT_COLOR.B * (1 - blendFactor) + displayColor.B * blendFactor
    local tintedShirt = Color3.new(shirtR, shirtG, shirtB)

    local pantsR = DEFAULT_PANTS_COLOR.R * (1 - blendFactor) + displayColor.R * blendFactor
    local pantsG = DEFAULT_PANTS_COLOR.G * (1 - blendFactor) + displayColor.G * blendFactor
    local pantsB = DEFAULT_PANTS_COLOR.B * (1 - blendFactor) + displayColor.B * blendFactor
    local tintedPants = Color3.new(pantsR, pantsG, pantsB)

    bodyColors.TorsoColor3 = tintedShirt
    bodyColors.LeftArmColor3 = tintedShirt
    bodyColors.RightArmColor3 = tintedShirt
    bodyColors.LeftLegColor3 = tintedPants
    bodyColors.RightLegColor3 = tintedPants
end

--------------------------------------------------------------------------------
-- Sash (colored accent part on torso)
--------------------------------------------------------------------------------

function PowerVisualsService:_applySash(visualsFolder, character, powerData)
    local torso = character:FindFirstChild("Torso")
    if not torso then return end

    local displayColor = powerData.displayColor or DEFAULT_SHIRT_COLOR

    createWeldedPart(
        visualsFolder, torso,
        SASH_SIZE,
        SASH_OFFSET,
        displayColor,
        {
            Name = "PowerSash",
            Material = Enum.Material.Fabric,
            Transparency = 0.1,
        }
    )
end

--------------------------------------------------------------------------------
-- Tier-based trim (neon for tier 5+, legendary glow for tier 6+)
--------------------------------------------------------------------------------

function PowerVisualsService:_applyTierTrim(visualsFolder, character, powerData)
    local tier = powerData.tier or 0
    if tier < 5 then return end

    local torso = character:FindFirstChild("Torso")
    if not torso then return end

    local displayColor = powerData.displayColor or DEFAULT_SHIRT_COLOR

    -- Neon trim for tier 5+ (Master)
    local trim = createWeldedPart(
        visualsFolder, torso,
        TRIM_SIZE,
        TRIM_OFFSET,
        displayColor,
        {
            Name = "TierTrim",
            Material = Enum.Material.Neon,
            Transparency = 0.2,
        }
    )

    -- Legendary glow for tier 6+ (Legendary / UltraRare)
    if tier >= 6 then
        local glow = createPointLight(displayColor, 1.0, 10)
        glow.Name = "LegendaryGlow"
        glow.Parent = trim

        -- Extra aura particles for legendary tier
        local emitter = createParticleEmitter({
            Name = "LegendaryAuraParticle",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, displayColor),
                ColorSequenceKeypoint.new(1, Color3.new(
                    math.min(1, displayColor.R + 0.2),
                    math.min(1, displayColor.G + 0.2),
                    math.min(1, displayColor.B + 0.2)
                )),
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(0.5, 0.4),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Lifetime = NumberRange.new(0.5, 1.0),
            Rate = 20,
            Speed = NumberRange.new(1, 3),
            LightEmission = 1,
            SpreadAngle = Vector2.new(180, 180),
            Acceleration = Vector3.new(0, 2, 0),
        })
        emitter.Parent = torso
    end
end

return PowerVisualsService
