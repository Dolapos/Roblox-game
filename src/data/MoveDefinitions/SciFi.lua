--[[
    SciFi.lua
    Move definitions for all Sci-Fi powers.
]]

local Enums = require(script.Parent.Parent.Parent.Shared.Enums)

return {
    -- === TELEKINESIS (100 hits) ===
    TKPush = {
        id = "TKPush", name = "TK Push", slot = Enums.MoveSlot.Q,
        description = "Push enemies away with telekinetic force.",
        damageType = Enums.DamageType.Psychic, baseDamage = 10, cooldown = 3.0,
        range = 18, knockback = 22, hitboxShape = Enums.HitboxShape.Cone,
        hitboxSize = Vector3.new(10, 6, 18), castTime = 0.25, recoveryTime = 0.3,
        animationId = "", causeRagdoll = false,
    },
    TKGrab = {
        id = "TKGrab", name = "TK Grab", slot = Enums.MoveSlot.E,
        description = "Grab an enemy with your mind and hold them in place.",
        damageType = Enums.DamageType.Psychic, baseDamage = 5, cooldown = 6.0,
        range = 20, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(4, 4, 4), castTime = 0.3, recoveryTime = 0.3,
        statusEffect = "Grabbed", statusDuration = 1.5,
        animationId = "", causeRagdoll = false,
    },
    TKSlam = {
        id = "TKSlam", name = "TK Slam", slot = Enums.MoveSlot.R,
        description = "Lift enemies up and slam them into the ground.",
        damageType = Enums.DamageType.Psychic, baseDamage = 20, cooldown = 8.0,
        range = 15, knockback = 25, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(8, 8, 8), castTime = 0.5, recoveryTime = 0.6,
        grabAndSlam = true, animationId = "", causeRagdoll = true,
    },

    -- === MIND CONTROL (200 hits) ===
    Confuse = {
        id = "Confuse", name = "Confuse", slot = Enums.MoveSlot.Q,
        description = "Reverse an enemy's movement controls for 2 seconds.",
        damageType = Enums.DamageType.Psychic, baseDamage = 5, cooldown = 8.0,
        range = 15, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(5, 5, 5), castTime = 0.3, recoveryTime = 0.3,
        statusEffect = "Confused", statusDuration = 2.0,
        animationId = "", causeRagdoll = false,
    },
    MindBlast = {
        id = "MindBlast", name = "Mind Blast", slot = Enums.MoveSlot.E,
        description = "Blast an enemy's mind, dealing damage and disorienting them.",
        damageType = Enums.DamageType.Psychic, baseDamage = 16, cooldown = 5.0,
        range = 12, knockback = 15, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(6, 6, 6), castTime = 0.3, recoveryTime = 0.4,
        statusEffect = "Confused", statusDuration = 1.0,
        animationId = "", causeRagdoll = false,
    },
    PsychicPulse = {
        id = "PsychicPulse", name = "Psychic Pulse", slot = Enums.MoveSlot.R,
        description = "Release a massive psychic pulse that hits all nearby.",
        damageType = Enums.DamageType.Psychic, baseDamage = 18, cooldown = 10.0,
        range = 16, knockback = 22, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(16, 10, 16), castTime = 0.5, recoveryTime = 0.5,
        statusEffect = "Confused", statusDuration = 1.5,
        animationId = "", causeRagdoll = true,
    },

    -- === GRAVITY FIELD (200 hits) ===
    GravityPull = {
        id = "GravityPull", name = "Gravity Pull", slot = Enums.MoveSlot.Q,
        description = "Pull all nearby enemies toward you.",
        damageType = Enums.DamageType.Psychic, baseDamage = 8, cooldown = 4.0,
        range = 18, knockback = -20, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(18, 10, 18), castTime = 0.3, recoveryTime = 0.3,
        pullTarget = true, animationId = "", causeRagdoll = false,
    },
    GravityPush = {
        id = "GravityPush", name = "Gravity Push", slot = Enums.MoveSlot.E,
        description = "Reverse gravity in an area, launching enemies up.",
        damageType = Enums.DamageType.Psychic, baseDamage = 14, cooldown = 6.0,
        range = 15, knockback = 25, knockbackDirection = Vector3.new(0, 1, 0).Unit,
        hitboxShape = Enums.HitboxShape.Sphere, hitboxSize = Vector3.new(12, 12, 12),
        castTime = 0.4, recoveryTime = 0.4, animationId = "", causeRagdoll = true,
    },
    ZeroGravity = {
        id = "ZeroGravity", name = "Zero Gravity", slot = Enums.MoveSlot.R,
        description = "Create a zero gravity zone where everyone floats helplessly.",
        damageType = Enums.DamageType.Psychic, baseDamage = 6, cooldown = 12.0,
        range = 18, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(18, 18, 18), castTime = 0.5, recoveryTime = 0.5,
        isZone = true, zoneDuration = 3, statusEffect = "Float", statusDuration = 3,
        animationId = "", causeRagdoll = false,
    },

    -- === TIME STOP (500 hits) ===
    TimeHalt = {
        id = "TimeHalt", name = "Time Halt", slot = Enums.MoveSlot.Q,
        description = "Stop time briefly in a small area (1.5s).",
        damageType = Enums.DamageType.Time, baseDamage = 5, cooldown = 15.0,
        range = 12, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(12, 12, 12), castTime = 0.4, recoveryTime = 0.3,
        statusEffect = "Frozen", statusDuration = 1.5,
        animationId = "", causeRagdoll = false,
    },
    TimeRewind = {
        id = "TimeRewind", name = "Time Rewind", slot = Enums.MoveSlot.E,
        description = "Rewind yourself 3 seconds, restoring HP and position.",
        damageType = Enums.DamageType.Time, baseDamage = 0, cooldown = 18.0,
        range = 0, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(0, 0, 0), castTime = 0.3, recoveryTime = 0.2,
        rewindDuration = 3, restoreHealth = true,
        animationId = "", causeRagdoll = false,
    },
    TimeClone = {
        id = "TimeClone", name = "Time Clone", slot = Enums.MoveSlot.R,
        description = "Create a time clone that replays your last 5 seconds of attacks.",
        damageType = Enums.DamageType.Time, baseDamage = 0, cooldown = 20.0,
        range = 0, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(0, 0, 0), castTime = 0.4, recoveryTime = 0.3,
        createClone = true, cloneDuration = 5, cloneDamageMultiplier = 0.6,
        animationId = "", causeRagdoll = false,
    },

    -- === NANOBOT SWARM (500 hits) ===
    SwarmAttack = {
        id = "SwarmAttack", name = "Swarm Attack", slot = Enums.MoveSlot.Q,
        description = "Send a swarm of nanobots to attack an enemy.",
        damageType = Enums.DamageType.Tech, baseDamage = 4, cooldown = 3.0,
        range = 20, knockback = 5, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(5, 5, 5), castTime = 0.25, recoveryTime = 0.3,
        isProjectile = true, projectileSpeed = 40, damagePerSecond = 6,
        isZone = true, zoneDuration = 3, animationId = "", causeRagdoll = false,
    },
    NanoShield = {
        id = "NanoShield", name = "Nano Shield", slot = Enums.MoveSlot.E,
        description = "Nanobots form a protective shield around you.",
        damageType = Enums.DamageType.Tech, baseDamage = 0, cooldown = 10.0,
        range = 0, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(0, 0, 0), castTime = 0.3, recoveryTime = 0.2,
        isBarrier = true, barrierHealth = 45, barrierDuration = 5,
        animationId = "", causeRagdoll = false,
    },
    SwarmDrain = {
        id = "SwarmDrain", name = "Swarm Drain", slot = Enums.MoveSlot.R,
        description = "Nanobots drain health from all nearby enemies.",
        damageType = Enums.DamageType.Tech, baseDamage = 6, cooldown = 12.0,
        range = 12, knockback = 5, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(12, 8, 12), castTime = 0.4, recoveryTime = 0.4,
        isZone = true, zoneDuration = 4, damagePerSecond = 5,
        lifeSteal = 0.3, animationId = "", causeRagdoll = false,
    },

    -- === LASER BEAM (500 hits) ===
    LaserShot = {
        id = "LaserShot", name = "Laser Shot", slot = Enums.MoveSlot.Q,
        description = "Fire a precision laser that deals high damage.",
        damageType = Enums.DamageType.Tech, baseDamage = 15, cooldown = 3.5,
        range = 40, knockback = 8, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(2, 2, 40), castTime = 0.25, recoveryTime = 0.3,
        isBeam = true, beamDuration = 0.3, animationId = "", causeRagdoll = false,
    },
    LaserSweep = {
        id = "LaserSweep", name = "Laser Sweep", slot = Enums.MoveSlot.E,
        description = "Sweep a laser in an arc, hitting multiple enemies.",
        damageType = Enums.DamageType.Tech, baseDamage = 12, cooldown = 6.0,
        range = 25, knockback = 12, hitboxShape = Enums.HitboxShape.Cone,
        hitboxSize = Vector3.new(15, 4, 25), castTime = 0.3, recoveryTime = 0.5,
        isBeam = true, beamDuration = 0.8, animationId = "", causeRagdoll = false,
    },
    MegaLaser = {
        id = "MegaLaser", name = "Mega Laser", slot = Enums.MoveSlot.R,
        description = "Channel a massive laser beam for devastating damage.",
        damageType = Enums.DamageType.Tech, baseDamage = 6, cooldown = 14.0,
        range = 50, knockback = 15, hitboxShape = Enums.HitboxShape.Line,
        hitboxSize = Vector3.new(6, 6, 50), castTime = 0.6, recoveryTime = 0.6,
        isBeam = true, beamDuration = 2.0, damagePerSecond = 15,
        animationId = "", causeRagdoll = true,
    },

    -- === ENERGY SHIELD (500 hits) ===
    ShieldBash = {
        id = "ShieldBash", name = "Shield Bash", slot = Enums.MoveSlot.Q,
        description = "Bash enemies with an energy shield.",
        damageType = Enums.DamageType.Tech, baseDamage = 12, cooldown = 3.0,
        range = 5, knockback = 18, hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(6, 5, 5), castTime = 0.2, recoveryTime = 0.3,
        armorDuringCast = 0.5, animationId = "", causeRagdoll = false,
    },
    Reflect = {
        id = "Reflect", name = "Reflect", slot = Enums.MoveSlot.E,
        description = "Activate a reflect shield that bounces attacks back.",
        damageType = Enums.DamageType.Tech, baseDamage = 0, cooldown = 10.0,
        range = 0, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(0, 0, 0), castTime = 0.2, recoveryTime = 0.2,
        buffType = "Reflect", buffAmount = 1.0, buffDuration = 2,
        animationId = "", causeRagdoll = false,
    },
    ShieldDome = {
        id = "ShieldDome", name = "Shield Dome", slot = Enums.MoveSlot.R,
        description = "Create a dome that blocks all incoming projectiles.",
        damageType = Enums.DamageType.Tech, baseDamage = 0, cooldown = 15.0,
        range = 0, knockback = 0, hitboxShape = Enums.HitboxShape.Sphere,
        hitboxSize = Vector3.new(15, 15, 15), castTime = 0.4, recoveryTime = 0.3,
        isBarrier = true, barrierHealth = 80, barrierDuration = 5,
        animationId = "", causeRagdoll = false,
    },
}
