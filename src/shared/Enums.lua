--[[
    Enums.lua
    Custom enumerations for the Magic Fighting Game
]]

local Enums = {}

Enums.Zone = {
    MagicHall = "MagicHall",
    Arena = "Arena",
    Unknown = "Unknown",
}

Enums.PowerCategory = {
    Fists = "Fists",
    Elemental = "Elemental",
    Anime = "Anime",
    Mythological = "Mythological",
    SciFi = "SciFi",
    Unique = "Unique",
    UltraRare = "UltraRare",
}

Enums.MoveSlot = {
    Q = "Q",
    E = "E",
    R = "R",
    T = "T",
    Y = "Y",
    G = "G",
    M1 = "M1",
}

Enums.DamageType = {
    Physical = "Physical",
    Fire = "Fire",
    Ice = "Ice",
    Lightning = "Lightning",
    Earth = "Earth",
    Wind = "Wind",
    Magma = "Magma",
    Storm = "Storm",
    Crystal = "Crystal",
    Sand = "Sand",
    Poison = "Poison",
    Dark = "Dark",
    Light = "Light",
    Psychic = "Psychic",
    Time = "Time",
    Tech = "Tech",
    Chaos = "Chaos",
    Celestial = "Celestial",
    Dragon = "Dragon",
    Spirit = "Spirit",
}

Enums.PowerTier = {
    Free = 0,
    Starter = 1,
    Intermediate = 2,
    Advanced = 3,
    Expert = 4,
    Master = 5,
    Legendary = 6,
    UltraRare = 7,
}

Enums.CombatState = {
    Idle = "Idle",
    Attacking = "Attacking",
    Ragdolled = "Ragdolled",
    Blocking = "Blocking",
    Stunned = "Stunned",
    Casting = "Casting",
}

Enums.HitboxShape = {
    Box = "Box",
    Sphere = "Sphere",
    Cone = "Cone",
    Line = "Line",
}

return Enums
