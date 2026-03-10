--[[
    Constants.lua
    Game-wide constants for the Magic Fighting Game
]]

local Constants = {}

-- Health
Constants.MAX_HEALTH = 100
Constants.HEALTH_REGEN_RATE = 0.5 -- HP per second when out of combat
Constants.OUT_OF_COMBAT_TIME = 8 -- seconds before regen kicks in

-- Combat
Constants.BASE_FIST_DAMAGE = 8
Constants.FIST_COMBO_MULTIPLIER = 1.15 -- each consecutive fist hit multiplier
Constants.MAX_COMBO_COUNT = 15
Constants.COMBO_WINDOW = 2.0 -- seconds between hits to maintain combo
Constants.COMBO_RESET_TIME = 3.0 -- seconds after last hit to fully reset combo

-- Ragdoll (0.8s sweet spot - see CombatConfig for full tiered system)
Constants.BASE_RAGDOLL_DURATION = 0.8 -- seconds (heavy hits)
Constants.MAX_RAGDOLL_DURATION = 1.0 -- hard cap (special moves only)
Constants.RAGDOLL_GETUP_PROTECTION = 0.35 -- invulnerability after recovery
Constants.RAGDOLL_DIMINISHING_WINDOW = 2.0 -- seconds for anti-abuse tracking

-- Knockback
Constants.BASE_KNOCKBACK = 15
Constants.FIST_KNOCKBACK = 12
Constants.MAX_KNOCKBACK = 50

-- Movement
Constants.BASE_WALK_SPEED = 16
Constants.SPRINT_SPEED = 24
Constants.COMBAT_WALK_SPEED = 14

-- Power Slots / Keybinds
Constants.MOVE_SLOTS = {"Q", "E", "R", "T", "Y", "G"}
Constants.FIST_SLOT = "M1" -- Left click for fist attacks

-- Zone Names
Constants.ZONE_MAGIC_HALL = "MagicHall"
Constants.ZONE_ARENA = "Arena"
Constants.ZONE_UNKNOWN = "Unknown"

-- Progression
Constants.HITS_FOR_UNLOCK = {
    [0] = 0,       -- Tier 0: Free
    [1] = 50,      -- Tier 1: Starter
    [2] = 100,     -- Tier 2: Intermediate
    [3] = 200,     -- Tier 3: Advanced
    [4] = 500,     -- Tier 4: Expert
    [5] = 1000,    -- Tier 5: Master
    [6] = 2000,    -- Tier 6: Legendary
    [7] = 5000,    -- Tier 7: Ultra Rare
    [8] = 8000,    -- Tier 8: Mythic
    [9] = 12000,   -- Tier 9: Ultimate
}

-- Cooldown Minimums
Constants.MIN_COOLDOWN = 0.5
Constants.GLOBAL_COOLDOWN = 0.3 -- minimum time between ANY two moves

-- Map Dimensions
Constants.MAGIC_HALL_SIZE = Vector3.new(200, 50, 200)
Constants.ARENA_SIZE = Vector3.new(500, 10, 500)
Constants.PORTAL_POSITION = Vector3.new(0, 5, -80) -- relative to Magic Hall center

-- DataStore
Constants.DATA_STORE_NAME = "MagicFightingGameV1"
Constants.DATA_SAVE_INTERVAL = 60 -- seconds

return Constants
