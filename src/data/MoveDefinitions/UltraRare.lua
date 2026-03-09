--[[
    UltraRare.lua
    Move definitions for Ultra-Rare powers (Tier 6-7).
    These are NOT overpowered - they have longer cooldowns and more unique mechanics.
]]

local Enums = require(script.Parent.Parent.Parent.Shared.Enums)

return {
    -- === REALITY WARP (2000 hits) ===
    RealityShift = {
        id = "RealityShift", name = "Reality Shift", slot = Enums.MoveSlot.Q,
        description = "Shift reality around an enemy, teleporting them randomly nearby.",
        damageType = Enums.DamageType.Chaos, baseDamage = 14, cooldown = 5.0,
        range = 20, knockback = 10, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(6, 6, 6), castTime = 0.3, recoveryTime = 0.3,
        randomTeleport = true, teleportRange = 15,
        animationId = "", causeRagdoll = false,
    },
    DimensionRip = {
        id = "DimensionRip", name = "Dimension Rip", slot = Enums.MoveSlot.E,
        description = "Tear a rift that pulls enemies in and damages them.",
        damageType = Enums.DamageType.Chaos, baseDamage = 16, cooldown = 8.0,
        range = 20, knockback = -15, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(12, 12, 12), castTime = 0.5, recoveryTime = 0.5,
        isZone = true, zoneDuration = 3, pullForce = 20, damagePerSecond = 6,
        animationId = "", causeRagdoll = false,
    },
    WarpField = {
        id = "WarpField", name = "Warp Field", slot = Enums.MoveSlot.R,
        description = "Create a field where reality is distorted - reversed controls and gravity.",
        damageType = Enums.DamageType.Chaos, baseDamage = 10, cooldown = 18.0,
        range = 18, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(18, 15, 18), castTime = 0.6, recoveryTime = 0.5,
        isZone = true, zoneDuration = 5, statusEffect = "Warped", statusDuration = 5,
        damagePerSecond = 4, animationId = "", causeRagdoll = false,
    },

    -- === BLACK HOLE (2000 hits) ===
    Singularity = {
        id = "Singularity", name = "Singularity", slot = Enums.MoveSlot.Q,
        description = "Create a small singularity that pulls one enemy in.",
        damageType = Enums.DamageType.Celestial, baseDamage = 12, cooldown = 4.0,
        range = 22, knockback = -25, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(8, 8, 8), castTime = 0.35, recoveryTime = 0.3,
        pullTarget = true, animationId = "", causeRagdoll = false,
    },
    EventHorizon = {
        id = "EventHorizon", name = "Event Horizon", slot = Enums.MoveSlot.E,
        description = "Create an event horizon that traps and damages nearby enemies.",
        damageType = Enums.DamageType.Celestial, baseDamage = 8, cooldown = 10.0,
        range = 18, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(14, 14, 14), castTime = 0.5, recoveryTime = 0.4,
        isZone = true, zoneDuration = 4, pullForce = 30, damagePerSecond = 7,
        statusEffect = "Trapped", statusDuration = 0.5,
        animationId = "", causeRagdoll = false,
    },
    GravityCrush = {
        id = "GravityCrush", name = "Gravity Crush", slot = Enums.MoveSlot.R,
        description = "Collapse gravity, crushing all enemies in the area.",
        damageType = Enums.DamageType.Celestial, baseDamage = 26, cooldown = 18.0,
        range = 15, knockback = 5, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(15, 15, 15), castTime = 0.7, recoveryTime = 0.7,
        pullForce = 40, statusEffect = "Crushed", statusDuration = 1.5,
        animationId = "", causeRagdoll = true,
    },

    -- === CELESTIAL JUDGMENT (5000 hits) ===
    CelestialRain = {
        id = "CelestialRain", name = "Celestial Rain", slot = Enums.MoveSlot.Q,
        description = "Rain celestial energy bolts from the sky.",
        damageType = Enums.DamageType.Celestial, baseDamage = 6, cooldown = 5.0,
        range = 20, knockback = 10, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(15, 30, 15), castTime = 0.4, recoveryTime = 0.3,
        multiStrike = 8, strikeDelay = 0.15, isGroundTarget = true,
        animationId = "", causeRagdoll = false,
    },
    DivineSmite = {
        id = "DivineSmite", name = "Divine Smite", slot = Enums.MoveSlot.E,
        description = "A single devastating beam of celestial energy from above.",
        damageType = Enums.DamageType.Celestial, baseDamage = 22, cooldown = 8.0,
        range = 25, knockback = 22, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 40, 6), castTime = 0.5, recoveryTime = 0.5,
        isGroundTarget = true, isBeam = true, beamDuration = 0.5,
        animationId = "", causeRagdoll = true,
    },
    HeavenlyJudgment = {
        id = "HeavenlyJudgment", name = "Heavenly Judgment", slot = Enums.MoveSlot.R,
        description = "Ultimate: Rain divine judgment over a massive area.",
        damageType = Enums.DamageType.Celestial, baseDamage = 28, cooldown = 25.0,
        range = 25, knockback = 30, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(25, 40, 25), castTime = 1.0, recoveryTime = 0.8,
        multiStrike = 12, strikeDelay = 0.12, isGroundTarget = true,
        animationId = "", causeRagdoll = true,
    },

    -- === DRAGON GOD (5000 hits) ===
    DragonGodBreath = {
        id = "DragonGodBreath", name = "Dragon God Breath", slot = Enums.MoveSlot.Q,
        description = "Breathe ancient dragon fire in a massive cone.",
        damageType = Enums.DamageType.Dragon, baseDamage = 6, cooldown = 4.5,
        range = 25, knockback = 12, hitboxShape = Enums.HitboxShape.Cone,
        hitboxSize = Vector3.new(16, 8, 25), castTime = 0.35, recoveryTime = 0.4,
        isBeam = true, beamDuration = 1.5, damagePerSecond = 12,
        burnDamage = 5, burnDuration = 4, animationId = "", causeRagdoll = false,
    },
    DragonGodClaw = {
        id = "DragonGodClaw", name = "Dragon God Claw", slot = Enums.MoveSlot.E,
        description = "Slash with divine dragon claws that rend reality.",
        damageType = Enums.DamageType.Dragon, baseDamage = 20, cooldown = 6.0,
        range = 10, knockback = 22, hitboxShape = Enums.HitboxShape.Cone,
        hitboxSize = Vector3.new(12, 8, 10), castTime = 0.3, recoveryTime = 0.5,
        multiStrike = 3, strikeDelay = 0.08,
        animationId = "", causeRagdoll = true,
    },
    DragonGodRoar = {
        id = "DragonGodRoar", name = "Dragon God Roar", slot = Enums.MoveSlot.R,
        description = "The roar of a Dragon God that shakes the entire arena.",
        damageType = Enums.DamageType.Dragon, baseDamage = 24, cooldown = 20.0,
        range = 25, knockback = 35, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(25, 15, 25), castTime = 0.7, recoveryTime = 0.7,
        stunDuration = 1.2, animationId = "", causeRagdoll = true,
    },
}
