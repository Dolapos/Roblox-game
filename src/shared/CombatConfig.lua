--[[
    CombatConfig.lua
    Combat balance tuning parameters.

    DESIGN PHILOSOPHY:
    - Fists are ALWAYS viable. They have low cooldowns, decent damage, and good knockback.
    - Powers are more diverse and flashy but NOT strictly stronger.
    - A skilled fist user should beat an average power user.
    - Powers offer utility, range, and variety, not raw power advantage.
    - Late-game powers do NOT do 3x damage. That kills the game.

    RAGDOLL PHILOSOPHY (0.8s sweet spot):
    - 0.4-0.6s feels too short for readable combo follow-up
    - 1.2+ sec starts feeling unfair and annoying
    - 0.8s allows one follow-up read or reposition without making the victim feel deleted
]]

local CombatConfig = {}

-- Fist Combat (M1 click combo)
CombatConfig.Fists = {
    -- 3-hit combo chain on M1
    combo = {
        {name = "Jab", damage = 8, knockback = 10, range = 5, duration = 0.25,
         hitboxSize = Vector3.new(4, 4, 5), staggerType = "Light"},
        {name = "Cross", damage = 10, knockback = 12, range = 5, duration = 0.3,
         hitboxSize = Vector3.new(4, 4, 5), staggerType = "Light"},
        {name = "Uppercut", damage = 14, knockback = 20, range = 5, duration = 0.35,
         hitboxSize = Vector3.new(4, 6, 5), staggerType = "Launcher"},
    },
    comboCooldown = 0.4,
    fullComboCooldown = 1.2,
    comboResetTime = 1.5,
}

-- Ragdoll / Stagger Tuning
-- NOT every hit ragdolls the same. Tiered system:
CombatConfig.Ragdoll = {
    -- Hit type durations
    hitTypes = {
        Light = {duration = 0.2, isStagger = true},         -- light jabs, quick hits
        Medium = {duration = 0.5, isStagger = false},       -- standard power hits
        Heavy = {duration = 0.8, isStagger = false},        -- launcher / slam / heavy
        Launcher = {duration = 0.8, isStagger = false},     -- uppercuts that launch upward
        Slam = {duration = 0.9, isStagger = false},         -- air slam / wall smash
        Special = {duration = 1.0, isStagger = false},      -- special move hard knockdown (MAX)
    },

    -- Anti-abuse: diminishing returns on repeat ragdolls
    -- After a player is ragdolled:
    -- - 0.35s get-up protection
    -- - Repeat ragdolls within 2s are reduced
    getUpProtection = 0.35,          -- invulnerability frames after recovery
    diminishingWindow = 2.0,         -- seconds to track repeat ragdolls
    diminishingReductions = {
        [1] = 1.0,                   -- first ragdoll: full duration
        [2] = 0.625,                 -- second within 2s: 0.5s instead of 0.8s
        [3] = 0.0,                   -- third within 2s: stagger only, no full ragdoll
    },

    -- Legacy fallback values
    baseDuration = 0.8,
    maxDuration = 1.0,
    knockbackRagdollThreshold = 25,
    fistRagdollOnlyFinisher = true,
}

-- Damage Scaling
-- CRITICAL: tier multipliers are nearly flat.
-- Late-game powers do NOT do 3x damage. They are diverse, not stronger.
CombatConfig.DamageScaling = {
    tierMultiplier = {
        [0] = 1.0,   -- Free (Fists)
        [1] = 1.0,   -- Starter
        [2] = 1.0,   -- Intermediate
        [3] = 1.0,   -- Advanced
        [4] = 1.0,   -- Expert
        [5] = 1.0,   -- Master
        [6] = 1.0,   -- Legendary
        [7] = 1.0,   -- Ultra Rare -- NO BONUS. Diversity, not damage.
    },
    -- Combo damage scaling (very slight, diminishing returns)
    comboMultiplier = {
        [1] = 1.0,
        [2] = 1.05,
        [3] = 1.08,
        [4] = 1.1,
        [5] = 1.12,
    },
    maxComboMultiplier = 1.12,
}

-- Cooldown Ranges (seconds)
CombatConfig.CooldownRanges = {
    Quick = {min = 1.5, max = 3.0},
    Medium = {min = 4.0, max = 7.0},
    Heavy = {min = 8.0, max = 12.0},
    Ultimate = {min = 15.0, max = 25.0},
}

-- Movement during combat
CombatConfig.Movement = {
    duringAttack = 0.3,
    duringCast = 0.5,
    afterDodge = 1.2,
    dodgeCooldown = 2.0,
    dodgeDistance = 15,
}

-- Hitbox defaults
CombatConfig.Hitbox = {
    defaultLifetime = 0.3,
    maxSize = Vector3.new(30, 30, 30),
    maxRange = 60,
}

return CombatConfig
