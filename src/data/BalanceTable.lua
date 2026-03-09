--[[
    BalanceTable.lua
    Central balance configuration.
    PHILOSOPHY: Powers are diverse, not strictly stronger. Fists always remain viable.
]]

local BalanceTable = {}

-- Fist scaling: fists get slightly stronger as the player progresses
-- This ensures fist-only players can still compete at higher levels
BalanceTable.FistScaling = {
    {hits = 0, damageMultiplier = 1.0, name = "Brawler"},
    {hits = 100, damageMultiplier = 1.05, name = "Fighter"},
    {hits = 500, damageMultiplier = 1.1, name = "Martial Artist"},
    {hits = 1000, damageMultiplier = 1.15, name = "Master Fighter"},
    {hits = 2000, damageMultiplier = 1.2, name = "Grandmaster"},
    {hits = 5000, damageMultiplier = 1.25, name = "Legendary Brawler"},
}

-- Get fist damage multiplier for a given hit count
function BalanceTable.getFistMultiplier(totalHits)
    local multiplier = 1.0
    for _, entry in ipairs(BalanceTable.FistScaling) do
        if totalHits >= entry.hits then
            multiplier = entry.damageMultiplier
        end
    end
    return multiplier
end

-- Power cooldown multiplier by tier
-- Higher tier moves tend to have slightly longer cooldowns
BalanceTable.CooldownMultiplier = {
    [0] = 1.0,
    [1] = 1.0,
    [2] = 1.0,
    [3] = 1.0,
    [4] = 1.05,
    [5] = 1.1,
    [6] = 1.15,
    [7] = 1.2,
}

-- Global damage cap per single hit (prevents one-shots)
BalanceTable.MAX_SINGLE_HIT_DAMAGE = 35

-- Health regeneration in arena
BalanceTable.ARENA_REGEN_RATE = 2 -- HP/sec when out of combat
BalanceTable.ARENA_REGEN_DELAY = 6 -- seconds after last damage taken

-- Respawn settings
BalanceTable.RESPAWN_TIME = 5 -- seconds
BalanceTable.RESPAWN_INVULNERABILITY = 3 -- seconds of invulnerability after respawn

return BalanceTable
