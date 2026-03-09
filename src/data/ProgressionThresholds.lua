--[[
    ProgressionThresholds.lua
    Defines what unlocks at each hit milestone.
]]

local ProgressionThresholds = {
    -- Each entry: {hits = required hits, unlocks = {list of power IDs}, message = unlock message}
    {hits = 0, unlocks = {"Fists", "Quickstep"}, message = "Welcome! You start with Fists and Quickstep."},
    {hits = 50, unlocks = {"Splash", "Fire", "Explosion"}, message = "50 Hits! Splash, Fire, and Explosion unlocked!"},
    {hits = 100, unlocks = {"Ember", "Ice", "Lightning", "Hardening", "Overdrive", "ThunderGod", "Telekinesis"}, message = "100 Hits! Many new powers available!"},
    {hits = 150, unlocks = {"Chain"}, message = "150 Hits! Chain unlocked!"},
    {hits = 200, unlocks = {"Earth", "Wind", "Copy", "ShadowStand", "SunGod", "OceanGod", "MindControl", "GravityField", "LuckManipulation", "GlitchAbility"}, message = "200 Hits! A wave of new powers!"},
    {hits = 500, unlocks = {"Magma", "Storm", "Crystal", "Sand", "PoisonGas", "TimePunch", "ChainStand", "Hellfire", "SoulDrain", "DemonWings", "TimeStop", "NanobotSwarm", "LaserBeam", "EnergyShield", "TrapMaster", "PortalMaker", "BanHammer", "RubberBody"}, message = "500 Hits! Expert tier unlocked!"},
    {hits = 1000, unlocks = {"Berserker", "EnergyAura", "SpiritBeast", "DragonForm", "PhoenixRebirth", "MinotaurStrength"}, message = "1000 Hits! Master tier achieved!"},
    {hits = 2000, unlocks = {"RealityWarp", "BlackHole"}, message = "2000 Hits! Legendary powers unlocked!"},
    {hits = 5000, unlocks = {"CelestialJudgment", "DragonGod"}, message = "5000 Hits! ULTRA RARE powers unlocked!"},
}

-- Helper: get all unlocked power IDs for a given hit count
function ProgressionThresholds.getUnlockedPowerIds(totalHits)
    local unlocked = {}
    for _, threshold in ipairs(ProgressionThresholds) do
        if totalHits >= threshold.hits then
            for _, powerId in ipairs(threshold.unlocks) do
                table.insert(unlocked, powerId)
            end
        end
    end
    return unlocked
end

-- Helper: get the next milestone info
function ProgressionThresholds.getNextMilestone(totalHits)
    for _, threshold in ipairs(ProgressionThresholds) do
        if totalHits < threshold.hits then
            return {
                hitsNeeded = threshold.hits,
                hitsRemaining = threshold.hits - totalHits,
                unlocks = threshold.unlocks,
                message = threshold.message,
            }
        end
    end
    return nil -- All milestones reached
end

return ProgressionThresholds
