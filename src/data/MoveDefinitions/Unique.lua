--[[
    Unique.lua
    Move definitions for all Unique/Fun powers.
]]

local Enums = require(script.Parent.Parent.Parent.Shared.Enums)

return {
    -- === LUCK MANIPULATION (200 hits) ===
    LuckyStrike = {
        id = "LuckyStrike", name = "Lucky Strike", slot = Enums.MoveSlot.Q,
        description = "Hit with random damage - could be tiny or massive!",
        damageType = Enums.DamageType.Chaos, baseDamage = 10, cooldown = 3.0,
        range = 8, knockback = 12, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(5, 5, 8), castTime = 0.25, recoveryTime = 0.3,
        randomDamageRange = {5, 30}, animationId = "", causeRagdoll = false,
    },
    MisfortuneCurse = {
        id = "MisfortuneCurse", name = "Misfortune Curse", slot = Enums.MoveSlot.E,
        description = "Curse an enemy with bad luck - random debuffs!",
        damageType = Enums.DamageType.Chaos, baseDamage = 8, cooldown = 6.0,
        range = 15, knockback = 5, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(5, 5, 5), castTime = 0.3, recoveryTime = 0.3,
        randomDebuff = true, debuffDuration = 4,
        animationId = "", causeRagdoll = false,
    },
    JackpotBurst = {
        id = "JackpotBurst", name = "Jackpot Burst", slot = Enums.MoveSlot.R,
        description = "50% chance of a huge explosion, 50% chance it fizzles!",
        damageType = Enums.DamageType.Chaos, baseDamage = 30, cooldown = 10.0,
        range = 15, knockback = 30, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(15, 15, 15), castTime = 0.5, recoveryTime = 0.5,
        jackpotChance = 0.5, fizzleDamage = 5,
        animationId = "", causeRagdoll = true,
    },

    -- === GLITCH (200 hits) ===
    GlitchTeleport = {
        id = "GlitchTeleport", name = "Glitch Teleport", slot = Enums.MoveSlot.Q,
        description = "Teleport to a random nearby position.",
        damageType = Enums.DamageType.Chaos, baseDamage = 8, cooldown = 3.0,
        range = 20, knockback = 8, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(6, 6, 6), castTime = 0.1, recoveryTime = 0.2,
        randomTeleport = true, teleportRange = 20,
        animationId = "", causeRagdoll = false,
    },
    GlitchStrike = {
        id = "GlitchStrike", name = "Glitch Strike", slot = Enums.MoveSlot.E,
        description = "Attack that causes visual glitches on enemy's screen.",
        damageType = Enums.DamageType.Chaos, baseDamage = 14, cooldown = 5.0,
        range = 10, knockback = 12, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 5, 10), castTime = 0.2, recoveryTime = 0.4,
        statusEffect = "Glitched", statusDuration = 2.0,
        animationId = "", causeRagdoll = false,
    },
    SystemCrash = {
        id = "SystemCrash", name = "System Crash", slot = Enums.MoveSlot.R,
        description = "Crash the area - all enemies get random teleported away.",
        damageType = Enums.DamageType.Chaos, baseDamage = 16, cooldown = 14.0,
        range = 15, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(15, 10, 15), castTime = 0.5, recoveryTime = 0.5,
        randomTeleportAll = true, teleportRange = 30,
        animationId = "", causeRagdoll = true,
    },

    -- === TRAP MASTER (500 hits) ===
    PlaceTrap = {
        id = "PlaceTrap", name = "Place Trap", slot = Enums.MoveSlot.Q,
        description = "Place an invisible trap that damages enemies who step on it.",
        damageType = Enums.DamageType.Physical, baseDamage = 15, cooldown = 5.0,
        range = 15, knockback = 15, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(5, 2, 5), castTime = 0.3, recoveryTime = 0.2,
        isTrap = true, trapDuration = 20, trapInvisible = true,
        animationId = "", causeRagdoll = true,
    },
    TripWire = {
        id = "TripWire", name = "Trip Wire", slot = Enums.MoveSlot.E,
        description = "Set a wire that trips enemies who cross it.",
        damageType = Enums.DamageType.Physical, baseDamage = 8, cooldown = 6.0,
        range = 12, knockback = 10, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(12, 1, 1), castTime = 0.3, recoveryTime = 0.2,
        isTrap = true, trapDuration = 15, causesTrip = true,
        animationId = "", causeRagdoll = true,
    },
    TrapField = {
        id = "TrapField", name = "Trap Field", slot = Enums.MoveSlot.R,
        description = "Scatter multiple small traps in an area.",
        damageType = Enums.DamageType.Physical, baseDamage = 10, cooldown = 14.0,
        range = 20, knockback = 12, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(4, 2, 4), castTime = 0.5, recoveryTime = 0.4,
        isTrap = true, trapCount = 6, trapDuration = 25, trapInvisible = true,
        animationId = "", causeRagdoll = true,
    },

    -- === PORTAL MAKER (500 hits) ===
    PortalPunch = {
        id = "PortalPunch", name = "Portal Punch", slot = Enums.MoveSlot.Q,
        description = "Open a portal next to an enemy and punch through it.",
        damageType = Enums.DamageType.Chaos, baseDamage = 14, cooldown = 3.5,
        range = 20, knockback = 12, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 4, 5), castTime = 0.25, recoveryTime = 0.35,
        portalRange = 20, animationId = "", causeRagdoll = false,
    },
    PortalTeleport = {
        id = "PortalTeleport", name = "Portal Teleport", slot = Enums.MoveSlot.E,
        description = "Place a portal and teleport to it instantly.",
        damageType = Enums.DamageType.Chaos, baseDamage = 0, cooldown = 8.0,
        range = 30, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(0, 0, 0), castTime = 0.3, recoveryTime = 0.2,
        placePortal = true, portalDuration = 10,
        animationId = "", causeRagdoll = false,
    },
    PortalTrap = {
        id = "PortalTrap", name = "Portal Trap", slot = Enums.MoveSlot.R,
        description = "Create a portal trap that teleports enemies into the sky.",
        damageType = Enums.DamageType.Chaos, baseDamage = 12, cooldown = 12.0,
        range = 15, knockback = 30, knockbackDirection = Vector3.new(0, 1, 0).Unit,
        hitboxShape = Enums.HitboxShape.Sphere, hitboxSize = Vector3.new(6, 2, 6),
        castTime = 0.4, recoveryTime = 0.4, isTrap = true, trapDuration = 15,
        animationId = "", causeRagdoll = true,
    },

    -- === BAN HAMMER (500 hits) ===
    HammerSmash = {
        id = "HammerSmash", name = "Hammer Smash", slot = Enums.MoveSlot.Q,
        description = "Smash the ground with a massive hammer.",
        damageType = Enums.DamageType.Physical, baseDamage = 16, cooldown = 4.0,
        range = 8, knockback = 20, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(8, 4, 8), castTime = 0.4, recoveryTime = 0.5,
        splashRadius = 8, animationId = "", causeRagdoll = true,
    },
    HammerLaunch = {
        id = "HammerLaunch", name = "Hammer Launch", slot = Enums.MoveSlot.E,
        description = "Hit an enemy and launch them into the sky!",
        damageType = Enums.DamageType.Physical, baseDamage = 14, cooldown = 6.0,
        range = 6, knockback = 50, knockbackDirection = Vector3.new(0, 1, 0.2).Unit,
        hitboxShape = Enums.HitboxShape.Box, hitboxSize = Vector3.new(5, 5, 6),
        castTime = 0.35, recoveryTime = 0.5, animationId = "", causeRagdoll = true,
    },
    JudgmentStrike = {
        id = "JudgmentStrike", name = "Judgment Strike", slot = Enums.MoveSlot.R,
        description = "Call down a massive hammer from the sky. BANNED!",
        damageType = Enums.DamageType.Physical, baseDamage = 25, cooldown = 12.0,
        range = 20, knockback = 40, knockbackDirection = Vector3.new(0, 1, 0).Unit,
        hitboxShape = Enums.HitboxShape.Sphere, hitboxSize = Vector3.new(10, 30, 10),
        castTime = 0.7, recoveryTime = 0.6, isGroundTarget = true,
        animationId = "", causeRagdoll = true,
    },

    -- === RUBBER BODY (500 hits) ===
    StretchPunch = {
        id = "StretchPunch", name = "Stretch Punch", slot = Enums.MoveSlot.Q,
        description = "Stretch your arm for a long-range punch.",
        damageType = Enums.DamageType.Physical, baseDamage = 12, cooldown = 2.5,
        range = 20, knockback = 14, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(3, 3, 20), castTime = 0.2, recoveryTime = 0.3,
        stretchAnimation = true, animationId = "", causeRagdoll = false,
    },
    RubberSnapback = {
        id = "RubberSnapback", name = "Rubber Snapback", slot = Enums.MoveSlot.E,
        description = "Bounce back from a hit and counter-attack.",
        damageType = Enums.DamageType.Physical, baseDamage = 16, cooldown = 6.0,
        range = 10, knockback = 18, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 5, 10), castTime = 0.15, recoveryTime = 0.4,
        isCounter = true, counterWindow = 1.0,
        animationId = "", causeRagdoll = false,
    },
    GumGumGatling = {
        id = "GumGumGatling", name = "Gum Gum Gatling", slot = Enums.MoveSlot.R,
        description = "Rapid-fire stretch punches in all directions!",
        damageType = Enums.DamageType.Physical, baseDamage = 3, cooldown = 10.0,
        range = 15, knockback = 20, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(15, 8, 15), castTime = 0.3, recoveryTime = 0.6,
        multiStrike = 10, strikeDelay = 0.06,
        animationId = "", causeRagdoll = true,
    },

    -- === RUST (350 hits) ===
    RustTouch = {
        id = "RustTouch", name = "Corroding Touch", slot = Enums.MoveSlot.Q,
        description = "Touch an enemy to corrode their defenses.",
        damageType = Enums.DamageType.Earth, baseDamage = 8, cooldown = 3.0,
        range = 6, knockback = 5, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 4, 6), castTime = 0.15, recoveryTime = 0.2,
        statusEffect = "Weakened", statusDuration = 4.0, debuffMultiplier = 0.7,
        animationId = "", causeRagdoll = false,
    },
    RustCloud = {
        id = "RustCloud", name = "Oxidation Cloud", slot = Enums.MoveSlot.E,
        description = "Release a cloud of corrosive rust particles.",
        damageType = Enums.DamageType.Earth, baseDamage = 6, cooldown = 6.0,
        range = 12, knockback = 8, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(14, 8, 14), castTime = 0.3, recoveryTime = 0.4,
        isZone = true, zoneDuration = 4, damagePerSecond = 4,
        statusEffect = "Weakened", statusDuration = 3.0,
        animationId = "", causeRagdoll = false,
    },
    RustDecay = {
        id = "RustDecay", name = "Total Decay", slot = Enums.MoveSlot.R,
        description = "Accelerate entropy. Everything in range crumbles.",
        damageType = Enums.DamageType.Earth, baseDamage = 18, cooldown = 12.0,
        range = 0, knockback = 15, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(18, 10, 18), castTime = 0.5, recoveryTime = 0.6,
        statusEffect = "Weakened", statusDuration = 5.0, debuffMultiplier = 0.5,
        animationId = "", causeRagdoll = true, staggerType = "Heavy",
    },

    -- === WATERMELON (400 hits) ===
    MelonToss = {
        id = "MelonToss", name = "Melon Toss", slot = Enums.MoveSlot.Q,
        description = "Hurl an explosive watermelon at the enemy.",
        damageType = Enums.DamageType.Physical, baseDamage = 14, cooldown = 3.0,
        range = 25, knockback = 16, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(6, 6, 6), castTime = 0.25, recoveryTime = 0.3,
        isProjectile = true, projectileSpeed = 45, splashRadius = 8,
        animationId = "", causeRagdoll = false,
    },
    MelonSplit = {
        id = "MelonSplit", name = "Melon Split", slot = Enums.MoveSlot.E,
        description = "Slice a melon mid-air, sending shrapnel everywhere.",
        damageType = Enums.DamageType.Physical, baseDamage = 5, cooldown = 5.0,
        range = 15, knockback = 10, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(14, 8, 14), castTime = 0.3, recoveryTime = 0.4,
        multiHit = 5, multiHitDelay = 0.05,
        animationId = "", causeRagdoll = false,
    },
    MelonBarrage = {
        id = "MelonBarrage", name = "Melon Barrage", slot = Enums.MoveSlot.R,
        description = "Summon a rain of watermelons from the sky!",
        damageType = Enums.DamageType.Physical, baseDamage = 8, cooldown = 12.0,
        range = 18, knockback = 22, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(18, 15, 18), castTime = 0.5, recoveryTime = 0.6,
        multiStrike = 6, strikeDelay = 0.3,
        isGroundTarget = true, animationId = "", causeRagdoll = true,
    },

    -- === KNIFE (450 hits) ===
    KnifeSlash = {
        id = "KnifeSlash", name = "Quick Slash", slot = Enums.MoveSlot.Q,
        description = "A lightning-fast knife slash.",
        damageType = Enums.DamageType.Physical, baseDamage = 10, cooldown = 1.5,
        range = 6, knockback = 8, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(5, 4, 6), castTime = 0.1, recoveryTime = 0.15,
        animationId = "", causeRagdoll = false, staggerType = "Light",
    },
    KnifeThrow = {
        id = "KnifeThrow", name = "Knife Throw", slot = Enums.MoveSlot.E,
        description = "Throw a spinning knife at range.",
        damageType = Enums.DamageType.Physical, baseDamage = 14, cooldown = 4.0,
        range = 30, knockback = 10, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(2, 2, 30), castTime = 0.15, recoveryTime = 0.25,
        isProjectile = true, projectileSpeed = 70,
        animationId = "", causeRagdoll = false,
    },
    KnifeFlurry = {
        id = "KnifeFlurry", name = "Knife Flurry", slot = Enums.MoveSlot.R,
        description = "Unleash a devastating flurry of slashes.",
        damageType = Enums.DamageType.Physical, baseDamage = 4, cooldown = 8.0,
        range = 6, knockback = 18, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(5, 5, 7), castTime = 0.1, recoveryTime = 0.5,
        multiStrike = 8, strikeDelay = 0.08,
        animationId = "", causeRagdoll = true,
    },

    -- === SPEAR (900 hits) ===
    SpearThrust = {
        id = "SpearThrust", name = "Piercing Thrust", slot = Enums.MoveSlot.Q,
        description = "A precise forward thrust with massive range.",
        damageType = Enums.DamageType.Physical, baseDamage = 14, cooldown = 2.5,
        range = 14, knockback = 12, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(3, 3, 14), castTime = 0.2, recoveryTime = 0.3,
        animationId = "", causeRagdoll = false,
    },
    SpearSweep = {
        id = "SpearSweep", name = "Wide Sweep", slot = Enums.MoveSlot.E,
        description = "Sweep the spear in a wide arc, hitting all nearby.",
        damageType = Enums.DamageType.Physical, baseDamage = 12, cooldown = 5.0,
        range = 10, knockback = 18, hitboxShape = Enums.HitboxShape.Cone,
        hitboxSize = Vector3.new(12, 5, 10), castTime = 0.25, recoveryTime = 0.4,
        animationId = "", causeRagdoll = false, staggerType = "Medium",
    },
    SpearImpale = {
        id = "SpearImpale", name = "Impale", slot = Enums.MoveSlot.R,
        description = "Charge forward and impale the enemy on your spear.",
        damageType = Enums.DamageType.Physical, baseDamage = 22, cooldown = 10.0,
        range = 18, knockback = 25, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(3, 3, 18), castTime = 0.2, recoveryTime = 0.5,
        isDash = true, dashDistance = 18,
        animationId = "", causeRagdoll = true, staggerType = "Heavy",
    },
}
