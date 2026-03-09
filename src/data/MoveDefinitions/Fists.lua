--[[
    Fists.lua
    Move definitions for the Fists power (always available).
    Fists use M1 (click) for a 3-hit combo. They also have special moves on Q, E, R.
]]

local Enums = require(script.Parent.Parent.Parent.Shared.Enums)

return {
    FistJab = {
        id = "FistJab",
        name = "Jab",
        slot = Enums.MoveSlot.Q,
        description = "Quick forward jab with extended reach.",
        damageType = Enums.DamageType.Physical,
        baseDamage = 10,
        cooldown = 2.0,
        range = 6,
        knockback = 8,
        hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 4, 6),
        castTime = 0.15,
        recoveryTime = 0.3,
        animationId = "", -- Placeholder for animation asset ID
        causeRagdoll = false,
    },
    FistCross = {
        id = "FistCross",
        name = "Cross",
        slot = Enums.MoveSlot.E,
        description = "Heavy cross punch that staggers enemies.",
        damageType = Enums.DamageType.Physical,
        baseDamage = 14,
        cooldown = 3.0,
        range = 5,
        knockback = 15,
        hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 4, 5),
        castTime = 0.25,
        recoveryTime = 0.4,
        animationId = "",
        causeRagdoll = false,
    },
    FistUppercut = {
        id = "FistUppercut",
        name = "Uppercut",
        slot = Enums.MoveSlot.R,
        description = "Devastating uppercut that launches enemies upward.",
        damageType = Enums.DamageType.Physical,
        baseDamage = 18,
        cooldown = 5.0,
        range = 4,
        knockback = 25,
        knockbackDirection = Vector3.new(0, 1, 0.3).Unit, -- Upward launch
        hitboxShape = Enums.HitboxShape.Box,
        hitboxSize = Vector3.new(4, 6, 4),
        castTime = 0.3,
        recoveryTime = 0.5,
        animationId = "",
        causeRagdoll = true,
    },
}
