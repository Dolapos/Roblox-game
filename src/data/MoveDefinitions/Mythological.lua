--[[
    Mythological.lua
    Move definitions for all Mythological powers.
]]

local Enums = require(script.Parent.Parent.Parent.Shared.Enums)

return {
    -- === THUNDER GOD (100 hits) ===
    DivineBolt = {
        id = "DivineBolt", name = "Divine Bolt", slot = Enums.MoveSlot.Q,
        description = "Call a divine lightning bolt from the sky.",
        damageType = Enums.DamageType.Lightning, baseDamage = 14, cooldown = 3.5,
        range = 25, knockback = 12, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 30, 4), castTime = 0.3, recoveryTime = 0.3,
        isGroundTarget = true, animationId = "", causeRagdoll = false,
    },
    ThunderSmite = {
        id = "ThunderSmite", name = "Thunder Smite", slot = Enums.MoveSlot.E,
        description = "Smite a targeted area with concentrated thunder.",
        damageType = Enums.DamageType.Lightning, baseDamage = 18, cooldown = 6.0,
        range = 20, knockback = 20, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(8, 20, 8), castTime = 0.5, recoveryTime = 0.5,
        isGroundTarget = true, stunDuration = 0.6, animationId = "", causeRagdoll = true,
    },
    StormWrath = {
        id = "StormWrath", name = "Storm Wrath", slot = Enums.MoveSlot.R,
        description = "Unleash divine wrath, raining lightning in a wide area.",
        damageType = Enums.DamageType.Lightning, baseDamage = 22, cooldown = 12.0,
        range = 20, knockback = 25, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(20, 30, 20), castTime = 0.7, recoveryTime = 0.6,
        multiStrike = 6, strikeDelay = 0.2, animationId = "", causeRagdoll = true,
    },

    -- === SUN GOD (200 hits) ===
    SolarBeam = {
        id = "SolarBeam", name = "Solar Beam", slot = Enums.MoveSlot.Q,
        description = "Fire a beam of concentrated sunlight.",
        damageType = Enums.DamageType.Light, baseDamage = 15, cooldown = 4.0,
        range = 35, knockback = 10, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(4, 4, 35), castTime = 0.35, recoveryTime = 0.3,
        isBeam = true, beamDuration = 0.5, animationId = "", causeRagdoll = false,
    },
    RadiantBurst = {
        id = "RadiantBurst", name = "Radiant Burst", slot = Enums.MoveSlot.E,
        description = "Release a blinding burst of light around you.",
        damageType = Enums.DamageType.Light, baseDamage = 14, cooldown = 6.0,
        range = 12, knockback = 18, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(12, 12, 12), castTime = 0.3, recoveryTime = 0.5,
        statusEffect = "Blinded", statusDuration = 1.5,
        animationId = "", causeRagdoll = true,
    },
    SunFlare = {
        id = "SunFlare", name = "Sun Flare", slot = Enums.MoveSlot.R,
        description = "Call down a massive solar flare that scorches the area.",
        damageType = Enums.DamageType.Light, baseDamage = 24, cooldown = 12.0,
        range = 20, knockback = 25, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(16, 20, 16), castTime = 0.6, recoveryTime = 0.7,
        burnDamage = 5, burnDuration = 3, animationId = "", causeRagdoll = true,
    },

    -- === OCEAN GOD (200 hits) ===
    TidalWave = {
        id = "TidalWave", name = "Tidal Wave", slot = Enums.MoveSlot.Q,
        description = "Summon a giant wave that sweeps forward.",
        damageType = Enums.DamageType.Ice, baseDamage = 16, cooldown = 4.0,
        range = 25, knockback = 22, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(15, 10, 25), castTime = 0.4, recoveryTime = 0.4,
        isProjectile = true, projectileSpeed = 35, animationId = "", causeRagdoll = true,
    },
    WaterPrison = {
        id = "WaterPrison", name = "Water Prison", slot = Enums.MoveSlot.E,
        description = "Trap an enemy in a sphere of water.",
        damageType = Enums.DamageType.Ice, baseDamage = 8, cooldown = 8.0,
        range = 15, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(6, 6, 6), castTime = 0.4, recoveryTime = 0.3,
        statusEffect = "Trapped", statusDuration = 2.0,
        damagePerSecond = 3, animationId = "", causeRagdoll = false,
    },
    Whirlpool = {
        id = "Whirlpool", name = "Whirlpool", slot = Enums.MoveSlot.R,
        description = "Create a massive whirlpool that pulls enemies in.",
        damageType = Enums.DamageType.Ice, baseDamage = 12, cooldown = 12.0,
        range = 20, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(18, 6, 18), castTime = 0.5, recoveryTime = 0.5,
        isZone = true, zoneDuration = 4, pullForce = 25, damagePerSecond = 6,
        animationId = "", causeRagdoll = true,
    },

    -- === HELLFIRE (500 hits) ===
    FlameDash = {
        id = "FlameDash", name = "Flame Dash", slot = Enums.MoveSlot.Q,
        description = "Dash in dark flames, burning everything in your path.",
        damageType = Enums.DamageType.Dark, baseDamage = 14, cooldown = 3.5,
        range = 20, knockback = 12, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(4, 4, 20), castTime = 0.15, recoveryTime = 0.3,
        isDash = true, dashDistance = 20, burnDamage = 4, burnDuration = 3,
        animationId = "", causeRagdoll = false,
    },
    DemonClaw = {
        id = "DemonClaw", name = "Demon Claw", slot = Enums.MoveSlot.E,
        description = "Slash with demonic claws of dark fire.",
        damageType = Enums.DamageType.Dark, baseDamage = 18, cooldown = 5.0,
        range = 7, knockback = 16, hitboxShape = Enums.HitboxShape.Cone,
        hitboxSize = Vector3.new(8, 5, 7), castTime = 0.25, recoveryTime = 0.4,
        multiStrike = 2, strikeDelay = 0.1, burnDamage = 3, burnDuration = 2,
        animationId = "", causeRagdoll = false,
    },
    HellfireEruption = {
        id = "HellfireEruption", name = "Hellfire Eruption", slot = Enums.MoveSlot.R,
        description = "Erupt hellfire from the ground in a massive area.",
        damageType = Enums.DamageType.Dark, baseDamage = 24, cooldown = 12.0,
        range = 18, knockback = 28, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(18, 15, 18), castTime = 0.6, recoveryTime = 0.6,
        isGroundTarget = true, burnDamage = 5, burnDuration = 4,
        animationId = "", causeRagdoll = true,
    },

    -- === SOUL DRAIN (500 hits) ===
    LifeSteal = {
        id = "LifeSteal", name = "Life Steal", slot = Enums.MoveSlot.Q,
        description = "Drain health from an enemy to heal yourself.",
        damageType = Enums.DamageType.Dark, baseDamage = 10, cooldown = 4.0,
        range = 10, knockback = 5, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(3, 3, 10), castTime = 0.3, recoveryTime = 0.3,
        lifeSteal = 0.5, animationId = "", causeRagdoll = false,
    },
    SoulPull = {
        id = "SoulPull", name = "Soul Pull", slot = Enums.MoveSlot.E,
        description = "Pull the soul of a nearby enemy, weakening them.",
        damageType = Enums.DamageType.Dark, baseDamage = 12, cooldown = 7.0,
        range = 15, knockback = -15, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(5, 5, 5), castTime = 0.4, recoveryTime = 0.4,
        pullTarget = true, debuffType = "Weakened", debuffAmount = 0.7,
        debuffDuration = 3, animationId = "", causeRagdoll = false,
    },
    SoulExplosion = {
        id = "SoulExplosion", name = "Soul Explosion", slot = Enums.MoveSlot.R,
        description = "Release consumed souls in a devastating explosion.",
        damageType = Enums.DamageType.Dark, baseDamage = 22, cooldown = 12.0,
        range = 12, knockback = 25, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(12, 12, 12), castTime = 0.5, recoveryTime = 0.6,
        scalingWithDrain = true, lifeSteal = 0.3,
        animationId = "", causeRagdoll = true,
    },

    -- === DEMON WINGS (500 hits) ===
    WingSlash = {
        id = "WingSlash", name = "Wing Slash", slot = Enums.MoveSlot.Q,
        description = "Slash with razor-sharp demon wings.",
        damageType = Enums.DamageType.Dark, baseDamage = 13, cooldown = 3.0,
        range = 8, knockback = 12, hitboxShape = Enums.HitboxShape.Cone,
        hitboxSize = Vector3.new(10, 5, 8), castTime = 0.2, recoveryTime = 0.3,
        animationId = "", causeRagdoll = false,
    },
    AerialDive = {
        id = "AerialDive", name = "Aerial Dive", slot = Enums.MoveSlot.E,
        description = "Launch into the air then dive-bomb enemies.",
        damageType = Enums.DamageType.Dark, baseDamage = 18, cooldown = 6.0,
        range = 20, knockback = 22, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(8, 8, 8), castTime = 0.3, recoveryTime = 0.5,
        selfLaunch = true, launchForce = 50, diveDamageMultiplier = 1.3,
        animationId = "", causeRagdoll = true,
    },
    DarkFlight = {
        id = "DarkFlight", name = "Dark Flight", slot = Enums.MoveSlot.R,
        description = "Sprout wings and fly temporarily, raining dark feathers.",
        damageType = Enums.DamageType.Dark, baseDamage = 4, cooldown = 14.0,
        range = 20, knockback = 8, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(12, 4, 12), castTime = 0.4, recoveryTime = 0.3,
        grantsFlightDuration = 4, damagePerSecond = 4,
        animationId = "", causeRagdoll = false,
    },

    -- === DRAGON FORM (1000 hits) ===
    DragonBreath = {
        id = "DragonBreath", name = "Dragon Breath", slot = Enums.MoveSlot.Q,
        description = "Breathe a cone of fire like a dragon.",
        damageType = Enums.DamageType.Dragon, baseDamage = 4, cooldown = 4.0,
        range = 18, knockback = 10, hitboxShape = Enums.HitboxShape.Cone,
        hitboxSize = Vector3.new(12, 6, 18), castTime = 0.3, recoveryTime = 0.4,
        isBeam = true, beamDuration = 1.0, damagePerSecond = 10,
        burnDamage = 3, burnDuration = 3, animationId = "", causeRagdoll = false,
    },
    TailSwipe = {
        id = "TailSwipe", name = "Tail Swipe", slot = Enums.MoveSlot.E,
        description = "Spin with a massive dragon tail, hitting all around you.",
        damageType = Enums.DamageType.Dragon, baseDamage = 16, cooldown = 5.0,
        range = 10, knockback = 22, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(10, 4, 10), castTime = 0.3, recoveryTime = 0.5,
        animationId = "", causeRagdoll = true,
    },
    DragonRoar = {
        id = "DragonRoar", name = "Dragon Roar", slot = Enums.MoveSlot.R,
        description = "Terrifying roar that stuns and pushes all enemies away.",
        damageType = Enums.DamageType.Dragon, baseDamage = 14, cooldown = 10.0,
        range = 18, knockback = 30, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(18, 12, 18), castTime = 0.5, recoveryTime = 0.6,
        stunDuration = 0.8, animationId = "", causeRagdoll = true,
    },

    -- === PHOENIX REBIRTH (1000 hits) ===
    PhoenixFlame = {
        id = "PhoenixFlame", name = "Phoenix Flame", slot = Enums.MoveSlot.Q,
        description = "Hurl sacred phoenix fire at enemies.",
        damageType = Enums.DamageType.Fire, baseDamage = 15, cooldown = 3.5,
        range = 25, knockback = 12, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(5, 5, 5), castTime = 0.3, recoveryTime = 0.3,
        isProjectile = true, projectileSpeed = 55, burnDamage = 4, burnDuration = 3,
        animationId = "", causeRagdoll = false,
    },
    PhoenixDash = {
        id = "PhoenixDash", name = "Phoenix Dash", slot = Enums.MoveSlot.E,
        description = "Transform into a phoenix and dash through enemies.",
        damageType = Enums.DamageType.Fire, baseDamage = 18, cooldown = 6.0,
        range = 25, knockback = 18, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(5, 5, 25), castTime = 0.2, recoveryTime = 0.4,
        isDash = true, dashDistance = 25, burnDamage = 3, burnDuration = 2,
        animationId = "", causeRagdoll = false,
    },
    Rebirth = {
        id = "Rebirth", name = "Rebirth", slot = Enums.MoveSlot.R,
        description = "Passive: Revive once with 50% HP after defeat. 120s cooldown.",
        damageType = Enums.DamageType.Fire, baseDamage = 15, cooldown = 120.0,
        range = 10, knockback = 20, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(10, 10, 10), castTime = 0.0, recoveryTime = 0.5,
        isPassive = true, reviveHealth = 0.5, onDeathTrigger = true,
        splashRadius = 10, burnDamage = 5, burnDuration = 3,
        animationId = "", causeRagdoll = true,
    },

    -- === MINOTAUR STRENGTH (1000 hits) ===
    BullCharge = {
        id = "BullCharge", name = "Bull Charge", slot = Enums.MoveSlot.Q,
        description = "Charge forward like a bull, ramming into enemies.",
        damageType = Enums.DamageType.Physical, baseDamage = 16, cooldown = 4.0,
        range = 25, knockback = 25, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 6, 25), castTime = 0.3, recoveryTime = 0.4,
        isDash = true, dashDistance = 25, animationId = "", causeRagdoll = true,
    },
    GroundSlam = {
        id = "GroundSlam", name = "Ground Slam", slot = Enums.MoveSlot.E,
        description = "Slam the ground with incredible force.",
        damageType = Enums.DamageType.Physical, baseDamage = 20, cooldown = 6.0,
        range = 14, knockback = 22, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(14, 4, 14), castTime = 0.4, recoveryTime = 0.5,
        animationId = "", causeRagdoll = true,
    },
    HornToss = {
        id = "HornToss", name = "Horn Toss", slot = Enums.MoveSlot.R,
        description = "Grab an enemy and toss them high into the air.",
        damageType = Enums.DamageType.Physical, baseDamage = 22, cooldown = 9.0,
        range = 5, knockback = 40, knockbackDirection = Vector3.new(0, 1, 0.5).Unit,
        hitboxShape = Enums.HitboxShape.Box, hitboxSize = Vector3.new(5, 5, 5),
        castTime = 0.35, recoveryTime = 0.6,
        grabAndSlam = true, animationId = "", causeRagdoll = true,
    },
}
