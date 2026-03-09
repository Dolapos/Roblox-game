--[[
    PowerRegistry.lua
    Master registry of ALL powers in the game.
    Each power has: id, name, category, tier, description, moves (referencing MoveDefinitions),
    displayColor, icon description, and unlock requirement.

    BALANCE NOTE: Higher tier powers are NOT stronger -- they are more diverse/unique.
    Fists remain competitive at all tiers.
]]

local Enums = require(script.Parent.Parent.Shared.Enums)

local PowerRegistry = {}

PowerRegistry.Powers = {
    ---============================================
    --- FISTS (Always available, Tier 0)
    ---============================================
    Fists = {
        id = "Fists",
        name = "Fists",
        category = Enums.PowerCategory.Fists,
        tier = Enums.PowerTier.Free,
        description = "Your bare hands. Quick, versatile, and always available. A skilled fist fighter can hold their own against any power.",
        displayColor = Color3.fromRGB(255, 255, 255),
        moves = {"FistJab", "FistCross", "FistUppercut"},
        hitsRequired = 0,
    },

    ---============================================
    --- ELEMENTAL POWERS
    ---============================================

    -- Tier 0 (Free)
    Quickstep = {
        id = "Quickstep",
        name = "Quickstep",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Free,
        description = "Swift wind-enhanced movement. Dash around opponents and strike from unexpected angles.",
        displayColor = Color3.fromRGB(200, 230, 255),
        moves = {"QuickstepDash", "QuickstepStrike", "QuickstepVortex"},
        hitsRequired = 0,
    },

    -- Tier 1 (50 hits)
    Splash = {
        id = "Splash",
        name = "Splash",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Starter,
        description = "Control water to push enemies back and create slippery zones.",
        displayColor = Color3.fromRGB(100, 150, 255),
        moves = {"SplashWave", "SplashBubble", "SplashGeyser"},
        hitsRequired = 50,
    },

    Fire = {
        id = "Fire",
        name = "Fire",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Starter,
        description = "Hurl fireballs and leave burning trails. Classic offensive element.",
        displayColor = Color3.fromRGB(255, 100, 30),
        moves = {"Fireball", "FirePillar", "FlameRush"},
        hitsRequired = 50,
    },

    -- Tier 2 (100 hits)
    Ember = {
        id = "Ember",
        name = "Ember",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Intermediate,
        description = "Smoldering cinder attacks with burn-over-time damage.",
        displayColor = Color3.fromRGB(255, 140, 50),
        moves = {"EmberShot", "CinderCloud", "EmberExplosion"},
        hitsRequired = 100,
    },

    Ice = {
        id = "Ice",
        name = "Ice",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Intermediate,
        description = "Freeze enemies briefly and create ice walls for tactical advantage.",
        displayColor = Color3.fromRGB(150, 220, 255),
        moves = {"IceSpike", "FrostWall", "Blizzard"},
        hitsRequired = 100,
    },

    Lightning = {
        id = "Lightning",
        name = "Lightning",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Intermediate,
        description = "Fast chain attacks that can jump between nearby enemies.",
        displayColor = Color3.fromRGB(255, 255, 100),
        moves = {"LightningBolt", "ChainLightning", "ThunderClap"},
        hitsRequired = 100,
    },

    -- Tier 3 (200 hits)
    Chain = {
        id = "Chain",
        name = "Chain",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Advanced,
        description = "Summon ethereal chains to bind and pull enemies.",
        displayColor = Color3.fromRGB(180, 180, 200),
        moves = {"ChainGrab", "ChainSlam", "ChainWhip"},
        hitsRequired = 150,
    },

    Earth = {
        id = "Earth",
        name = "Earth",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Advanced,
        description = "Summon rocks and create shockwaves that knock enemies off balance.",
        displayColor = Color3.fromRGB(150, 120, 80),
        moves = {"RockThrow", "Shockwave", "EarthPillar"},
        hitsRequired = 200,
    },

    Wind = {
        id = "Wind",
        name = "Wind",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Advanced,
        description = "Powerful knockback gusts and temporary flight for mobility.",
        displayColor = Color3.fromRGB(200, 255, 200),
        moves = {"GustPush", "Tornado", "WindFlight"},
        hitsRequired = 200,
    },

    -- Tier 4 (500 hits)
    Magma = {
        id = "Magma",
        name = "Magma",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Expert,
        description = "Slow but devastating magma attacks with area denial.",
        displayColor = Color3.fromRGB(255, 80, 0),
        moves = {"MagmaBurst", "LavaPool", "MagmaFist"},
        hitsRequired = 500,
    },

    Storm = {
        id = "Storm",
        name = "Storm",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Expert,
        description = "Summon storms with lightning strikes and tornadoes.",
        displayColor = Color3.fromRGB(100, 100, 180),
        moves = {"StormSurge", "TornadoSummon", "LightningStorm"},
        hitsRequired = 500,
    },

    Crystal = {
        id = "Crystal",
        name = "Crystal",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Expert,
        description = "Create crystalline shields and sharp projectiles.",
        displayColor = Color3.fromRGB(200, 100, 255),
        moves = {"CrystalShield", "ShardBarrage", "CrystalTrap"},
        hitsRequired = 500,
    },

    Sand = {
        id = "Sand",
        name = "Sand",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Expert,
        description = "Blind enemies with sandstorms and create sand traps.",
        displayColor = Color3.fromRGB(230, 200, 130),
        moves = {"SandBlind", "Sandstorm", "QuicksandTrap"},
        hitsRequired = 500,
    },

    PoisonGas = {
        id = "PoisonGas",
        name = "Poison Gas",
        category = Enums.PowerCategory.Elemental,
        tier = Enums.PowerTier.Expert,
        description = "Create toxic clouds that damage enemies over time.",
        displayColor = Color3.fromRGB(100, 200, 50),
        moves = {"ToxicCloud", "PoisonDart", "MiasmaZone"},
        hitsRequired = 500,
    },

    ---============================================
    --- ANIME-INSPIRED POWERS
    ---============================================

    -- Tier 1 (50 hits)
    Explosion = {
        id = "Explosion",
        name = "Explosion",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Starter,
        description = "Blast jumps and explosive punches. Flashy and fun!",
        displayColor = Color3.fromRGB(255, 200, 50),
        moves = {"ExplosionPunch", "BlastJump", "MegaExplosion"},
        hitsRequired = 50,
    },

    -- Tier 2 (100 hits)
    Hardening = {
        id = "Hardening",
        name = "Hardening",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Intermediate,
        description = "Temporarily harden your body into unbreakable armor.",
        displayColor = Color3.fromRGB(150, 150, 160),
        moves = {"HardenStrike", "IronBody", "ShatterPunch"},
        hitsRequired = 100,
    },

    Overdrive = {
        id = "Overdrive",
        name = "Overdrive",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Intermediate,
        description = "Massive speed boost with afterimage attacks.",
        displayColor = Color3.fromRGB(255, 50, 50),
        moves = {"OverdriveRush", "AfterimageStrike", "SpeedBlitz"},
        hitsRequired = 100,
    },

    -- Tier 3 (200 hits)
    Copy = {
        id = "Copy",
        name = "Copy",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Advanced,
        description = "Briefly steal another player's current ability.",
        displayColor = Color3.fromRGB(200, 200, 200),
        moves = {"CopyTouch", "MimicStrike", "AbilityEcho"},
        hitsRequired = 200,
    },

    ShadowStand = {
        id = "ShadowStand",
        name = "Shadow Stand",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Advanced,
        description = "An invisible helper that attacks enemies alongside you.",
        displayColor = Color3.fromRGB(50, 0, 80),
        moves = {"ShadowPunch", "ShadowRush", "ShadowBarrage"},
        hitsRequired = 200,
    },

    -- Tier 4 (500 hits)
    TimePunch = {
        id = "TimePunch",
        name = "Time Punch",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Expert,
        description = "Freeze enemies in time for devastating follow-up attacks.",
        displayColor = Color3.fromRGB(255, 215, 0),
        moves = {"TimeFreeze", "TimePunchCombo", "TimeSkip"},
        hitsRequired = 500,
    },

    ChainStand = {
        id = "ChainStand",
        name = "Chain Stand",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Expert,
        description = "Grab and slam enemies with spectral chains.",
        displayColor = Color3.fromRGB(180, 130, 255),
        moves = {"ChainGrapple", "ChainSlamStand", "ChainCage"},
        hitsRequired = 500,
    },

    -- Tier 5 (1000 hits)
    Berserker = {
        id = "Berserker",
        name = "Berserker",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Master,
        description = "Transform into berserker mode with devastating melee.",
        displayColor = Color3.fromRGB(200, 0, 0),
        moves = {"BerserkerRage", "FrenzySlash", "BerserkerSmash"},
        hitsRequired = 1000,
    },

    EnergyAura = {
        id = "EnergyAura",
        name = "Energy Aura",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Master,
        description = "Channel pure energy into devastating beam and burst attacks.",
        displayColor = Color3.fromRGB(0, 200, 255),
        moves = {"AuraBlast", "EnergyBeam", "AuraBurst"},
        hitsRequired = 1000,
    },

    SpiritBeast = {
        id = "SpiritBeast",
        name = "Spirit Beast",
        category = Enums.PowerCategory.Anime,
        tier = Enums.PowerTier.Master,
        description = "Summon a spirit beast that fights alongside you.",
        displayColor = Color3.fromRGB(100, 255, 150),
        moves = {"BeastSummon", "BeastCharge", "BeastRoar"},
        hitsRequired = 1000,
    },

    ---============================================
    --- MYTHOLOGICAL POWERS
    ---============================================

    -- Tier 2 (100 hits)
    ThunderGod = {
        id = "ThunderGod",
        name = "Thunder God",
        category = Enums.PowerCategory.Mythological,
        tier = Enums.PowerTier.Intermediate,
        description = "Call down divine lightning smites from the sky.",
        displayColor = Color3.fromRGB(255, 255, 180),
        moves = {"DivineBolt", "ThunderSmite", "StormWrath"},
        hitsRequired = 100,
    },

    -- Tier 3 (200 hits)
    SunGod = {
        id = "SunGod",
        name = "Sun God",
        category = Enums.PowerCategory.Mythological,
        tier = Enums.PowerTier.Advanced,
        description = "Blinding light beams and radiant energy attacks.",
        displayColor = Color3.fromRGB(255, 230, 100),
        moves = {"SolarBeam", "RadiantBurst", "SunFlare"},
        hitsRequired = 200,
    },

    OceanGod = {
        id = "OceanGod",
        name = "Ocean God",
        category = Enums.PowerCategory.Mythological,
        tier = Enums.PowerTier.Advanced,
        description = "Summon giant tidal waves and water prisons.",
        displayColor = Color3.fromRGB(0, 100, 200),
        moves = {"TidalWave", "WaterPrison", "Whirlpool"},
        hitsRequired = 200,
    },

    -- Tier 4 (500 hits)
    Hellfire = {
        id = "Hellfire",
        name = "Hellfire",
        category = Enums.PowerCategory.Mythological,
        tier = Enums.PowerTier.Expert,
        description = "Dark flame dashes and demonic claw attacks.",
        displayColor = Color3.fromRGB(150, 0, 50),
        moves = {"FlameDash", "DemonClaw", "HellfireEruption"},
        hitsRequired = 500,
    },

    SoulDrain = {
        id = "SoulDrain",
        name = "Soul Drain",
        category = Enums.PowerCategory.Mythological,
        tier = Enums.PowerTier.Expert,
        description = "Steal health from enemies and grow stronger.",
        displayColor = Color3.fromRGB(100, 0, 150),
        moves = {"LifeSteal", "SoulPull", "SoulExplosion"},
        hitsRequired = 500,
    },

    DemonWings = {
        id = "DemonWings",
        name = "Demon Wings",
        category = Enums.PowerCategory.Mythological,
        tier = Enums.PowerTier.Expert,
        description = "Sprout demon wings for flight and aerial dive attacks.",
        displayColor = Color3.fromRGB(80, 0, 100),
        moves = {"WingSlash", "AerialDive", "DarkFlight"},
        hitsRequired = 500,
    },

    -- Tier 5 (1000 hits)
    DragonForm = {
        id = "DragonForm",
        name = "Dragon Form",
        category = Enums.PowerCategory.Mythological,
        tier = Enums.PowerTier.Master,
        description = "Transform into a dragon with breath attacks.",
        displayColor = Color3.fromRGB(200, 50, 0),
        moves = {"DragonBreath", "TailSwipe", "DragonRoar"},
        hitsRequired = 1000,
    },

    PhoenixRebirth = {
        id = "PhoenixRebirth",
        name = "Phoenix Rebirth",
        category = Enums.PowerCategory.Mythological,
        tier = Enums.PowerTier.Master,
        description = "Fire attacks with a passive rebirth on defeat (long cooldown).",
        displayColor = Color3.fromRGB(255, 150, 0),
        moves = {"PhoenixFlame", "PhoenixDash", "Rebirth"},
        hitsRequired = 1000,
    },

    MinotaurStrength = {
        id = "MinotaurStrength",
        name = "Minotaur Strength",
        category = Enums.PowerCategory.Mythological,
        tier = Enums.PowerTier.Master,
        description = "Raw brute force with devastating charge attacks.",
        displayColor = Color3.fromRGB(120, 80, 40),
        moves = {"BullCharge", "GroundSlam", "HornToss"},
        hitsRequired = 1000,
    },

    ---============================================
    --- SCI-FI POWERS
    ---============================================

    -- Tier 2 (100 hits)
    Telekinesis = {
        id = "Telekinesis",
        name = "Telekinesis",
        category = Enums.PowerCategory.SciFi,
        tier = Enums.PowerTier.Intermediate,
        description = "Throw players and objects with your mind.",
        displayColor = Color3.fromRGB(180, 100, 255),
        moves = {"TKPush", "TKGrab", "TKSlam"},
        hitsRequired = 100,
    },

    -- Tier 3 (200 hits)
    MindControl = {
        id = "MindControl",
        name = "Mind Control",
        category = Enums.PowerCategory.SciFi,
        tier = Enums.PowerTier.Advanced,
        description = "Confuse enemy movement and reverse their controls briefly.",
        displayColor = Color3.fromRGB(255, 100, 200),
        moves = {"Confuse", "MindBlast", "PsychicPulse"},
        hitsRequired = 200,
    },

    GravityField = {
        id = "GravityField",
        name = "Gravity Field",
        category = Enums.PowerCategory.SciFi,
        tier = Enums.PowerTier.Advanced,
        description = "Manipulate gravity to pull or push all nearby players.",
        displayColor = Color3.fromRGB(100, 50, 200),
        moves = {"GravityPull", "GravityPush", "ZeroGravity"},
        hitsRequired = 200,
    },

    -- Tier 4 (500 hits)
    TimeStop = {
        id = "TimeStop",
        name = "Time Stop",
        category = Enums.PowerCategory.SciFi,
        tier = Enums.PowerTier.Expert,
        description = "Briefly freeze time around you (very short duration, long cooldown).",
        displayColor = Color3.fromRGB(255, 215, 0),
        moves = {"TimeHalt", "TimeRewind", "TimeClone"},
        hitsRequired = 500,
    },

    NanobotSwarm = {
        id = "NanobotSwarm",
        name = "Nanobot Swarm",
        category = Enums.PowerCategory.SciFi,
        tier = Enums.PowerTier.Expert,
        description = "Control tiny machines to create weapons and armor.",
        displayColor = Color3.fromRGB(150, 200, 200),
        moves = {"SwarmAttack", "NanoShield", "SwarmDrain"},
        hitsRequired = 500,
    },

    LaserBeam = {
        id = "LaserBeam",
        name = "Laser Beam",
        category = Enums.PowerCategory.SciFi,
        tier = Enums.PowerTier.Expert,
        description = "High-tech laser attacks with precision damage.",
        displayColor = Color3.fromRGB(255, 50, 50),
        moves = {"LaserShot", "LaserSweep", "MegaLaser"},
        hitsRequired = 500,
    },

    EnergyShield = {
        id = "EnergyShield",
        name = "Energy Shield",
        category = Enums.PowerCategory.SciFi,
        tier = Enums.PowerTier.Expert,
        description = "Project energy shields and reflect attacks back.",
        displayColor = Color3.fromRGB(0, 200, 255),
        moves = {"ShieldBash", "Reflect", "ShieldDome"},
        hitsRequired = 500,
    },

    ---============================================
    --- UNIQUE POWERS
    ---============================================

    -- Tier 3 (200 hits)
    LuckManipulation = {
        id = "LuckManipulation",
        name = "Luck Manipulation",
        category = Enums.PowerCategory.Unique,
        tier = Enums.PowerTier.Advanced,
        description = "Random buffs and debuffs - chaos is your weapon!",
        displayColor = Color3.fromRGB(255, 215, 0),
        moves = {"LuckyStrike", "MisfortuneCurse", "JackpotBurst"},
        hitsRequired = 200,
    },

    GlitchAbility = {
        id = "GlitchAbility",
        name = "Glitch",
        category = Enums.PowerCategory.Unique,
        tier = Enums.PowerTier.Advanced,
        description = "Teleport randomly and cause visual glitches for enemies.",
        displayColor = Color3.fromRGB(0, 255, 100),
        moves = {"GlitchTeleport", "GlitchStrike", "SystemCrash"},
        hitsRequired = 200,
    },

    -- Tier 4 (500 hits)
    TrapMaster = {
        id = "TrapMaster",
        name = "Trap Master",
        category = Enums.PowerCategory.Unique,
        tier = Enums.PowerTier.Expert,
        description = "Place traps on the map to catch unsuspecting players.",
        displayColor = Color3.fromRGB(200, 150, 50),
        moves = {"PlaceTrap", "TripWire", "TrapField"},
        hitsRequired = 500,
    },

    PortalMaker = {
        id = "PortalMaker",
        name = "Portal Maker",
        category = Enums.PowerCategory.Unique,
        tier = Enums.PowerTier.Expert,
        description = "Create portals to teleport across the arena.",
        displayColor = Color3.fromRGB(150, 50, 200),
        moves = {"PortalPunch", "PortalTeleport", "PortalTrap"},
        hitsRequired = 500,
    },

    BanHammer = {
        id = "BanHammer",
        name = "Ban Hammer",
        category = Enums.PowerCategory.Unique,
        tier = Enums.PowerTier.Expert,
        description = "Swing a massive hammer that launches players into the sky!",
        displayColor = Color3.fromRGB(255, 0, 0),
        moves = {"HammerSmash", "HammerLaunch", "JudgmentStrike"},
        hitsRequired = 500,
    },

    RubberBody = {
        id = "RubberBody",
        name = "Rubber Body",
        category = Enums.PowerCategory.Unique,
        tier = Enums.PowerTier.Expert,
        description = "Stretch your punches and bounce off attacks!",
        displayColor = Color3.fromRGB(255, 180, 200),
        moves = {"StretchPunch", "RubberSnapback", "GumGumGatling"},
        hitsRequired = 500,
    },

    ---============================================
    --- ULTRA-RARE POWERS (Tier 6-7)
    ---============================================

    -- Tier 6 (2000 hits)
    RealityWarp = {
        id = "RealityWarp",
        name = "Reality Warp",
        category = Enums.PowerCategory.UltraRare,
        tier = Enums.PowerTier.Legendary,
        description = "Distort the environment itself. Reality bends to your will.",
        displayColor = Color3.fromRGB(255, 0, 255),
        moves = {"RealityShift", "DimensionRip", "WarpField"},
        hitsRequired = 2000,
    },

    BlackHole = {
        id = "BlackHole",
        name = "Black Hole",
        category = Enums.PowerCategory.UltraRare,
        tier = Enums.PowerTier.Legendary,
        description = "Create miniature black holes that pull everything in.",
        displayColor = Color3.fromRGB(20, 0, 40),
        moves = {"Singularity", "EventHorizon", "GravityCrush"},
        hitsRequired = 2000,
    },

    -- Tier 7 (5000 hits)
    CelestialJudgment = {
        id = "CelestialJudgment",
        name = "Celestial Judgment",
        category = Enums.PowerCategory.UltraRare,
        tier = Enums.PowerTier.UltraRare,
        description = "Rain divine judgment from the heavens. The ultimate power.",
        displayColor = Color3.fromRGB(255, 255, 200),
        moves = {"CelestialRain", "DivineSmite", "HeavenlyJudgment"},
        hitsRequired = 5000,
    },

    DragonGod = {
        id = "DragonGod",
        name = "Dragon God",
        category = Enums.PowerCategory.UltraRare,
        tier = Enums.PowerTier.UltraRare,
        description = "The ultimate dragon form. Ancient power beyond comprehension.",
        displayColor = Color3.fromRGB(255, 200, 0),
        moves = {"DragonGodBreath", "DragonGodClaw", "DragonGodRoar"},
        hitsRequired = 5000,
    },
}

-- Power Evolution Trees
PowerRegistry.EvolutionTrees = {
    Fire = {"Fire", "Magma", "Hellfire"},          -- Fire -> Inferno -> Sun Flame
    Ice = {"Ice", "Crystal", "BlackHole"},
    Lightning = {"Lightning", "Storm", "ThunderGod"},
    Earth = {"Earth", "Crystal", "MinotaurStrength"},
    Telekinesis = {"Telekinesis", "GravityField", "RealityWarp"},
}

-- Element Combo system: combining two elements in sequence creates a bonus effect
PowerRegistry.ElementCombos = {
    ["Ice+Lightning"] = {name = "Shatter", bonusDamage = 1.5, description = "Frozen target shatters for bonus damage"},
    ["Fire+Wind"] = {name = "Fire Tornado", bonusDamage = 1.4, description = "Creates a spinning fire vortex"},
    ["Earth+Fire"] = {name = "Magma Eruption", bonusDamage = 1.3, description = "Ground erupts with lava"},
    ["Lightning+Wind"] = {name = "Thunder Storm", bonusDamage = 1.3, description = "Electrified tornado"},
    ["Ice+Fire"] = {name = "Steam Explosion", bonusDamage = 1.2, description = "Explosive steam cloud"},
    ["Earth+Lightning"] = {name = "Magnetize", bonusDamage = 1.2, description = "Pull target toward you"},
}

-- Helper function to get all powers in a category
function PowerRegistry.getPowersByCategory(category)
    local result = {}
    for _, power in pairs(PowerRegistry.Powers) do
        if power.category == category then
            table.insert(result, power)
        end
    end
    table.sort(result, function(a, b) return a.hitsRequired < b.hitsRequired end)
    return result
end

-- Helper function to get all powers at or below a tier
function PowerRegistry.getPowersByMaxTier(maxTier)
    local result = {}
    for _, power in pairs(PowerRegistry.Powers) do
        if power.tier <= maxTier then
            table.insert(result, power)
        end
    end
    return result
end

-- Helper function to get all powers a player has unlocked based on hits
function PowerRegistry.getUnlockedPowers(totalHits)
    local result = {}
    for _, power in pairs(PowerRegistry.Powers) do
        if totalHits >= power.hitsRequired then
            table.insert(result, power)
        end
    end
    table.sort(result, function(a, b) return a.hitsRequired < b.hitsRequired end)
    return result
end

-- Get a specific power by ID
function PowerRegistry.getPower(powerId)
    return PowerRegistry.Powers[powerId]
end

return PowerRegistry
