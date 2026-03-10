--[[
    Anime.lua
    Move definitions for all Anime-inspired powers.
]]

local Enums = require(script.Parent.Parent.Parent.Shared.Enums)

return {
    -- === EXPLOSION (50 hits) ===
    ExplosionPunch = {
        id = "ExplosionPunch", name = "Explosion Punch", slot = Enums.MoveSlot.Q,
        description = "Punch that detonates on contact.",
        damageType = Enums.DamageType.Fire, baseDamage = 14, cooldown = 3.0,
        range = 5, knockback = 18, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(6, 6, 6), castTime = 0.25, recoveryTime = 0.35,
        splashRadius = 6, animationId = "", causeRagdoll = false,
    },
    BlastJump = {
        id = "BlastJump", name = "Blast Jump", slot = Enums.MoveSlot.E,
        description = "Explode beneath you to launch into the air.",
        damageType = Enums.DamageType.Fire, baseDamage = 8, cooldown = 5.0,
        range = 8, knockback = 15, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(8, 4, 8), castTime = 0.2, recoveryTime = 0.3,
        selfLaunch = true, launchForce = 60, splashRadius = 8,
        animationId = "", causeRagdoll = false,
    },
    MegaExplosion = {
        id = "MegaExplosion", name = "Mega Explosion", slot = Enums.MoveSlot.R,
        description = "Channel a massive explosion that devastates the area.",
        damageType = Enums.DamageType.Fire, baseDamage = 22, cooldown = 10.0,
        range = 15, knockback = 30, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(15, 15, 15), castTime = 0.7, recoveryTime = 0.6,
        splashRadius = 15, animationId = "", causeRagdoll = true,
    },

    -- === HARDENING (100 hits) ===
    HardenStrike = {
        id = "HardenStrike", name = "Harden Strike", slot = Enums.MoveSlot.Q,
        description = "Harden your fist and strike with stone force.",
        damageType = Enums.DamageType.Physical, baseDamage = 15, cooldown = 3.5,
        range = 5, knockback = 14, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 4, 5), castTime = 0.3, recoveryTime = 0.4,
        armorDuringCast = 0.5, animationId = "", causeRagdoll = false,
    },
    IronBody = {
        id = "IronBody", name = "Iron Body", slot = Enums.MoveSlot.E,
        description = "Turn your entire body to iron, reducing damage taken.",
        damageType = Enums.DamageType.Physical, baseDamage = 0, cooldown = 12.0,
        range = 0, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(0, 0, 0), castTime = 0.3, recoveryTime = 0.2,
        buffType = "DamageReduction", buffAmount = 0.6, buffDuration = 4,
        slowEffect = 0.3, animationId = "", causeRagdoll = false,
    },
    ShatterPunch = {
        id = "ShatterPunch", name = "Shatter Punch", slot = Enums.MoveSlot.R,
        description = "Hardened fist shatters on impact for area damage.",
        damageType = Enums.DamageType.Physical, baseDamage = 20, cooldown = 8.0,
        range = 5, knockback = 25, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(8, 8, 8), castTime = 0.4, recoveryTime = 0.6,
        splashRadius = 8, animationId = "", causeRagdoll = true,
    },

    -- === OVERDRIVE (100 hits) ===
    OverdriveRush = {
        id = "OverdriveRush", name = "Overdrive Rush", slot = Enums.MoveSlot.Q,
        description = "Dash at extreme speed to strike enemies.",
        damageType = Enums.DamageType.Physical, baseDamage = 10, cooldown = 3.0,
        range = 20, knockback = 10, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(3, 3, 20), castTime = 0.1, recoveryTime = 0.25,
        isDash = true, dashDistance = 20, animationId = "", causeRagdoll = false,
    },
    AfterimageStrike = {
        id = "AfterimageStrike", name = "Afterimage Strike", slot = Enums.MoveSlot.E,
        description = "Leave an afterimage and strike from behind.",
        damageType = Enums.DamageType.Physical, baseDamage = 16, cooldown = 6.0,
        range = 15, knockback = 12, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 4, 5), castTime = 0.2, recoveryTime = 0.4,
        teleportBehind = true, animationId = "", causeRagdoll = false,
    },
    SpeedBlitz = {
        id = "SpeedBlitz", name = "Speed Blitz", slot = Enums.MoveSlot.R,
        description = "Unleash a barrage of speed-enhanced strikes.",
        damageType = Enums.DamageType.Physical, baseDamage = 4, cooldown = 10.0,
        range = 6, knockback = 20, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(5, 5, 6), castTime = 0.15, recoveryTime = 0.6,
        multiStrike = 6, strikeDelay = 0.1, animationId = "", causeRagdoll = true,
    },

    -- === COPY (200 hits) ===
    CopyTouch = {
        id = "CopyTouch", name = "Copy Touch", slot = Enums.MoveSlot.Q,
        description = "Touch an enemy to copy their currently equipped power for 15 seconds.",
        damageType = Enums.DamageType.Psychic, baseDamage = 5, cooldown = 20.0,
        range = 5, knockback = 5, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 4, 5), castTime = 0.3, recoveryTime = 0.3,
        copyPower = true, copyDuration = 15, animationId = "", causeRagdoll = false,
    },
    MimicStrike = {
        id = "MimicStrike", name = "Mimic Strike", slot = Enums.MoveSlot.E,
        description = "Use the Q move of the last copied power.",
        damageType = Enums.DamageType.Psychic, baseDamage = 12, cooldown = 5.0,
        range = 10, knockback = 12, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(5, 5, 10), castTime = 0.3, recoveryTime = 0.4,
        useCopiedQ = true, animationId = "", causeRagdoll = false,
    },
    AbilityEcho = {
        id = "AbilityEcho", name = "Ability Echo", slot = Enums.MoveSlot.R,
        description = "Echo the last ability used against you back at the attacker.",
        damageType = Enums.DamageType.Psychic, baseDamage = 15, cooldown = 12.0,
        range = 20, knockback = 15, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(6, 6, 6), castTime = 0.4, recoveryTime = 0.5,
        echoLastReceived = true, animationId = "", causeRagdoll = true,
    },

    -- === SHADOW STAND (200 hits) ===
    ShadowPunch = {
        id = "ShadowPunch", name = "Shadow Punch", slot = Enums.MoveSlot.Q,
        description = "Your shadow punches in sync, doubling hit area.",
        damageType = Enums.DamageType.Dark, baseDamage = 11, cooldown = 2.5,
        range = 7, knockback = 10, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 4, 7), castTime = 0.2, recoveryTime = 0.3,
        dualHitbox = true, animationId = "", causeRagdoll = false,
    },
    ShadowRush = {
        id = "ShadowRush", name = "Shadow Rush", slot = Enums.MoveSlot.E,
        description = "Shadow dashes forward and strikes independently.",
        damageType = Enums.DamageType.Dark, baseDamage = 14, cooldown = 5.0,
        range = 18, knockback = 15, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(4, 4, 18), castTime = 0.25, recoveryTime = 0.4,
        isProjectile = true, projectileSpeed = 60, animationId = "", causeRagdoll = false,
    },
    ShadowBarrage = {
        id = "ShadowBarrage", name = "Shadow Barrage", slot = Enums.MoveSlot.R,
        description = "Both you and your shadow unleash a barrage of punches.",
        damageType = Enums.DamageType.Dark, baseDamage = 3, cooldown = 9.0,
        range = 6, knockback = 20, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 5, 6), castTime = 0.3, recoveryTime = 0.6,
        multiStrike = 8, strikeDelay = 0.08, dualHitbox = true,
        animationId = "", causeRagdoll = true,
    },

    -- === TIME PUNCH (500 hits) ===
    TimeFreeze = {
        id = "TimeFreeze", name = "Time Freeze", slot = Enums.MoveSlot.Q,
        description = "Freeze a single enemy in time for 1 second.",
        damageType = Enums.DamageType.Time, baseDamage = 5, cooldown = 8.0,
        range = 12, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(4, 4, 4), castTime = 0.3, recoveryTime = 0.3,
        statusEffect = "Frozen", statusDuration = 1.0,
        animationId = "", causeRagdoll = false,
    },
    TimePunchCombo = {
        id = "TimePunchCombo", name = "Time Punch", slot = Enums.MoveSlot.E,
        description = "Rapid punches enhanced by time manipulation.",
        damageType = Enums.DamageType.Time, baseDamage = 5, cooldown = 5.0,
        range = 5, knockback = 15, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 4, 5), castTime = 0.2, recoveryTime = 0.4,
        multiStrike = 4, strikeDelay = 0.05, animationId = "", causeRagdoll = false,
    },
    TimeSkip = {
        id = "TimeSkip", name = "Time Skip", slot = Enums.MoveSlot.R,
        description = "Skip forward in time, appearing behind the nearest enemy.",
        damageType = Enums.DamageType.Time, baseDamage = 18, cooldown = 10.0,
        range = 25, knockback = 20, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(5, 5, 5), castTime = 0.15, recoveryTime = 0.5,
        teleportBehind = true, teleportRange = 25,
        animationId = "", causeRagdoll = true,
    },

    -- === CHAIN STAND (500 hits) ===
    ChainGrapple = {
        id = "ChainGrapple", name = "Chain Grapple", slot = Enums.MoveSlot.Q,
        description = "Spectral chains grapple and pull an enemy.",
        damageType = Enums.DamageType.Spirit, baseDamage = 10, cooldown = 4.0,
        range = 20, knockback = -18, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(3, 3, 20), castTime = 0.3, recoveryTime = 0.35,
        pullTarget = true, animationId = "", causeRagdoll = false,
    },
    ChainSlamStand = {
        id = "ChainSlamStand", name = "Chain Slam", slot = Enums.MoveSlot.E,
        description = "Grab enemy with chains and slam them into the ground.",
        damageType = Enums.DamageType.Spirit, baseDamage = 18, cooldown = 7.0,
        range = 8, knockback = 20, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 6, 8), castTime = 0.35, recoveryTime = 0.5,
        grabAndSlam = true, animationId = "", causeRagdoll = true,
    },
    ChainCage = {
        id = "ChainCage", name = "Chain Cage", slot = Enums.MoveSlot.R,
        description = "Encase enemies in a cage of chains, trapping them.",
        damageType = Enums.DamageType.Spirit, baseDamage = 10, cooldown = 12.0,
        range = 15, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(10, 10, 10), castTime = 0.5, recoveryTime = 0.5,
        statusEffect = "Trapped", statusDuration = 2.0,
        animationId = "", causeRagdoll = false,
    },

    -- === BERSERKER (1000 hits) ===
    BerserkerRage = {
        id = "BerserkerRage", name = "Berserker Rage", slot = Enums.MoveSlot.Q,
        description = "Enter rage mode: increased damage and speed for 6 seconds.",
        damageType = Enums.DamageType.Physical, baseDamage = 0, cooldown = 15.0,
        range = 0, knockback = 10, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(8, 8, 8), castTime = 0.5, recoveryTime = 0.3,
        buffType = "Rage", buffAmount = 1.3, buffDuration = 6,
        speedBoost = 1.3, animationId = "", causeRagdoll = false,
    },
    FrenzySlash = {
        id = "FrenzySlash", name = "Frenzy Slash", slot = Enums.MoveSlot.E,
        description = "Wild slashing attack that hits multiple times.",
        damageType = Enums.DamageType.Physical, baseDamage = 6, cooldown = 4.0,
        range = 7, knockback = 12, hitboxShape = Enums.HitboxShape.Cone,
        hitboxSize = Vector3.new(8, 5, 7), castTime = 0.2, recoveryTime = 0.4,
        multiStrike = 4, strikeDelay = 0.1, animationId = "", causeRagdoll = false,
    },
    BerserkerSmash = {
        id = "BerserkerSmash", name = "Berserker Smash", slot = Enums.MoveSlot.R,
        description = "Leap into the air and smash the ground with full force.",
        damageType = Enums.DamageType.Physical, baseDamage = 24, cooldown = 10.0,
        range = 12, knockback = 30, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(12, 6, 12), castTime = 0.5, recoveryTime = 0.7,
        selfLaunch = true, launchForce = 40, splashRadius = 12,
        animationId = "", causeRagdoll = true,
    },

    -- === ENERGY AURA (1000 hits) ===
    AuraBlast = {
        id = "AuraBlast", name = "Aura Blast", slot = Enums.MoveSlot.Q,
        description = "Fire a concentrated blast of energy.",
        damageType = Enums.DamageType.Spirit, baseDamage = 14, cooldown = 3.0,
        range = 25, knockback = 12, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(4, 4, 4), castTime = 0.25, recoveryTime = 0.3,
        isProjectile = true, projectileSpeed = 60, animationId = "", causeRagdoll = false,
    },
    EnergyBeam = {
        id = "EnergyBeam", name = "Energy Beam", slot = Enums.MoveSlot.E,
        description = "Fire a sustained beam of pure energy.",
        damageType = Enums.DamageType.Spirit, baseDamage = 3, cooldown = 8.0,
        range = 40, knockback = 8, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(3, 3, 40), castTime = 0.4, recoveryTime = 0.5,
        isBeam = true, beamDuration = 1.5, damagePerSecond = 12,
        animationId = "", causeRagdoll = false,
    },
    AuraBurst = {
        id = "AuraBurst", name = "Aura Burst", slot = Enums.MoveSlot.R,
        description = "Release all stored energy in a massive burst.",
        damageType = Enums.DamageType.Spirit, baseDamage = 22, cooldown = 12.0,
        range = 15, knockback = 28, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(15, 15, 15), castTime = 0.6, recoveryTime = 0.6,
        splashRadius = 15, animationId = "", causeRagdoll = true,
    },

    -- === SPIRIT BEAST (1000 hits) ===
    BeastSummon = {
        id = "BeastSummon", name = "Beast Summon", slot = Enums.MoveSlot.Q,
        description = "Summon a spirit beast that charges forward.",
        damageType = Enums.DamageType.Spirit, baseDamage = 16, cooldown = 5.0,
        range = 30, knockback = 18, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 6, 30), castTime = 0.4, recoveryTime = 0.3,
        isProjectile = true, projectileSpeed = 45, animationId = "", causeRagdoll = false,
    },
    BeastCharge = {
        id = "BeastCharge", name = "Beast Charge", slot = Enums.MoveSlot.E,
        description = "Ride your spirit beast in a charging attack.",
        damageType = Enums.DamageType.Spirit, baseDamage = 18, cooldown = 7.0,
        range = 25, knockback = 22, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 6, 25), castTime = 0.3, recoveryTime = 0.5,
        isDash = true, dashDistance = 25, animationId = "", causeRagdoll = true,
    },
    BeastRoar = {
        id = "BeastRoar", name = "Beast Roar", slot = Enums.MoveSlot.R,
        description = "Your spirit beast roars, stunning all nearby enemies.",
        damageType = Enums.DamageType.Spirit, baseDamage = 12, cooldown = 10.0,
        range = 15, knockback = 20, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(15, 10, 15), castTime = 0.5, recoveryTime = 0.5,
        stunDuration = 1.0, animationId = "", causeRagdoll = true,
    },

    -- === BERSERK (1800 hits) ===
    BerserkRoar = {
        id = "BerserkRoar", name = "Primal Roar", slot = Enums.MoveSlot.Q,
        description = "Unleash a terrifying roar that weakens and pushes enemies.",
        damageType = Enums.DamageType.Physical, baseDamage = 10, cooldown = 5.0,
        range = 12, knockback = 22, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(14, 10, 14), castTime = 0.3, recoveryTime = 0.4,
        buffType = "Rage", buffAmount = 1.4, buffDuration = 8,
        speedBoost = 1.2, animationId = "", causeRagdoll = false,
    },
    BerserkSlam = {
        id = "BerserkSlam", name = "Earth Shatter", slot = Enums.MoveSlot.E,
        description = "Slam both fists into the ground, cracking the earth.",
        damageType = Enums.DamageType.Physical, baseDamage = 20, cooldown = 7.0,
        range = 14, knockback = 25, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(14, 6, 14), castTime = 0.4, recoveryTime = 0.5,
        isGroundTarget = true, splashRadius = 14,
        animationId = "", causeRagdoll = true, staggerType = "Slam",
    },
    BerserkFrenzy = {
        id = "BerserkFrenzy", name = "Blood Frenzy", slot = Enums.MoveSlot.R,
        description = "Enter a berserker frenzy: rapid devastating strikes.",
        damageType = Enums.DamageType.Physical, baseDamage = 6, cooldown = 14.0,
        range = 8, knockback = 30, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(8, 6, 8), castTime = 0.3, recoveryTime = 0.7,
        multiStrike = 8, strikeDelay = 0.1,
        animationId = "", causeRagdoll = true, staggerType = "Heavy",
    },
}
