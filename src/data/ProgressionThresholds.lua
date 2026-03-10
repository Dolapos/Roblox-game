--[[
    ProgressionThresholds.lua
    Defines what unlocks at each hit milestone.
    Designed for easy expansion - just add new entries.
]]

local ProgressionThresholds = {
    {hits = 0, unlocks = {"Fists", "Quickstep"}, message = "Welcome! You start with Fists and Quickstep."},
    {hits = 50, unlocks = {"Splash", "Fire", "Explosion"}, message = "50 Hits! Splash, Fire, and Explosion unlocked!"},
    {hits = 100, unlocks = {"Ember", "Ice", "Lightning", "Hardening", "Overdrive", "ThunderGod", "Telekinesis"}, message = "100 Hits! Many new powers available!"},
    {hits = 150, unlocks = {"Chain"}, message = "150 Hits! Chain unlocked!"},
    {hits = 200, unlocks = {"Earth", "Wind", "Copy", "ShadowStand", "SunGod", "OceanGod", "MindControl", "GravityField", "LuckManipulation", "GlitchAbility"}, message = "200 Hits! A wave of new powers!"},
    {hits = 250, unlocks = {"Breeze"}, message = "250 Hits! Breeze unlocked!"},
    {hits = 300, unlocks = {"Rust"}, message = "300 Hits! Rust unlocked!"},
    {hits = 350, unlocks = {"Watermelon"}, message = "350 Hits! Watermelon unlocked!"},
    {hits = 400, unlocks = {"Knife"}, message = "400 Hits! Knife unlocked!"},
    {hits = 450, unlocks = {"Immolation"}, message = "450 Hits! Immolation unlocked!"},
    {hits = 500, unlocks = {"Magma", "Storm", "Crystal", "Sand", "PoisonGas", "TimePunch", "ChainStand", "Hellfire", "SoulDrain", "DemonWings", "TimeStop", "NanobotSwarm", "LaserBeam", "EnergyShield", "TrapMaster", "PortalMaker", "BanHammer", "RubberBody"}, message = "500 Hits! Expert tier unlocked!"},
    {hits = 900, unlocks = {"Spear"}, message = "900 Hits! Spear unlocked!"},
    {hits = 1000, unlocks = {"Berserker", "EnergyAura", "SpiritBeast", "DragonForm", "PhoenixRebirth", "MinotaurStrength"}, message = "1000 Hits! Master tier achieved!"},
    {hits = 1800, unlocks = {"Berserk"}, message = "1800 Hits! Berserk unlocked!"},
    {hits = 2000, unlocks = {"RealityWarp", "BlackHole"}, message = "2000 Hits! Legendary powers unlocked!"},
    {hits = 4200, unlocks = {"Gravel"}, message = "4200 Hits! Gravel unlocked!"},
    {hits = 5000, unlocks = {"CelestialJudgment", "DragonGod"}, message = "5000 Hits! ULTRA RARE powers unlocked!"},
    {hits = 5200, unlocks = {"Volcano"}, message = "5200 Hits! Volcano unlocked!"},
    {hits = 8000, unlocks = {"Singularity"}, message = "8000 Hits! Singularity unlocked!"},
    {hits = 12000, unlocks = {"GravityHand"}, message = "12000 Hits! Gravity Hand unlocked! ULTIMATE POWER!"},
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
