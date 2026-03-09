--[[
    MapBuilder.lua
    Procedurally builds the Magic Hall and Arena maps.
    Creates a medieval fantasy aesthetic Magic Hall with power pedestals,
    and a large fighting arena.
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PowerRegistry = require(ReplicatedStorage.Data.PowerRegistry)

local MapBuilder = {}

----------------------------------------------
-- MAGIC HALL - Medieval Fantasy Aesthetic
----------------------------------------------
function MapBuilder.buildMagicHall()
    local hallFolder = Workspace:FindFirstChild("MagicHall")
    if not hallFolder then
        hallFolder = Instance.new("Folder")
        hallFolder.Name = "MagicHall"
        hallFolder.Parent = Workspace
    end

    -- Floor
    local floor = MapBuilder._createPart("HallFloor", {
        Size = Vector3.new(200, 2, 200),
        Position = Vector3.new(0, -1, 0),
        Color = Color3.fromRGB(180, 160, 190),
        Material = Enum.Material.Marble,
        Parent = hallFolder,
    })

    -- Decorative floor pattern (center circle)
    local centerCircle = MapBuilder._createPart("CenterCircle", {
        Size = Vector3.new(40, 0.1, 40),
        Position = Vector3.new(0, 0.1, 0),
        Color = Color3.fromRGB(150, 100, 180),
        Material = Enum.Material.Marble,
        Shape = Enum.PartType.Cylinder,
        Orientation = Vector3.new(0, 0, 90),
        Parent = hallFolder,
    })

    -- Walls
    local wallHeight = 40
    local wallThickness = 4
    local hallSize = 100 -- half of 200

    -- North wall
    MapBuilder._createWall(hallFolder, "NorthWall",
        Vector3.new(200, wallHeight, wallThickness),
        Vector3.new(0, wallHeight/2, -hallSize), Color3.fromRGB(140, 120, 160))

    -- South wall (with archway for portal)
    MapBuilder._createWall(hallFolder, "SouthWallLeft",
        Vector3.new(85, wallHeight, wallThickness),
        Vector3.new(-57.5, wallHeight/2, hallSize), Color3.fromRGB(140, 120, 160))
    MapBuilder._createWall(hallFolder, "SouthWallRight",
        Vector3.new(85, wallHeight, wallThickness),
        Vector3.new(57.5, wallHeight/2, hallSize), Color3.fromRGB(140, 120, 160))
    -- Arch above portal
    MapBuilder._createWall(hallFolder, "SouthWallArch",
        Vector3.new(30, wallHeight - 20, wallThickness),
        Vector3.new(0, wallHeight - (wallHeight-20)/2, hallSize), Color3.fromRGB(140, 120, 160))

    -- East wall
    MapBuilder._createWall(hallFolder, "EastWall",
        Vector3.new(wallThickness, wallHeight, 200),
        Vector3.new(hallSize, wallHeight/2, 0), Color3.fromRGB(140, 120, 160))

    -- West wall
    MapBuilder._createWall(hallFolder, "WestWall",
        Vector3.new(wallThickness, wallHeight, 200),
        Vector3.new(-hallSize, wallHeight/2, 0), Color3.fromRGB(140, 120, 160))

    -- Ceiling with skylights
    local ceiling = MapBuilder._createPart("Ceiling", {
        Size = Vector3.new(200, 2, 200),
        Position = Vector3.new(0, wallHeight + 1, 0),
        Color = Color3.fromRGB(120, 100, 140),
        Material = Enum.Material.Slate,
        Transparency = 0,
        Parent = hallFolder,
    })

    -- Skylight openings (transparent parts)
    for i = -1, 1 do
        local skylight = MapBuilder._createPart("Skylight" .. i, {
            Size = Vector3.new(10, 2.1, 10),
            Position = Vector3.new(i * 30, wallHeight + 1, 0),
            Color = Color3.fromRGB(200, 180, 255),
            Material = Enum.Material.Neon,
            Transparency = 0.5,
            Parent = hallFolder,
        })
        -- Light beam
        local beam = Instance.new("SpotLight")
        beam.Brightness = 3
        beam.Range = 40
        beam.Angle = 45
        beam.Color = Color3.fromRGB(220, 200, 255)
        beam.Face = Enum.NormalId.Bottom
        beam.Parent = skylight
    end

    -- Pillars along the sides
    for i = -3, 3 do
        for _, side in ipairs({-1, 1}) do
            local pillar = MapBuilder._createPart("Pillar_" .. i .. "_" .. side, {
                Size = Vector3.new(5, wallHeight, 5),
                Position = Vector3.new(side * 80, wallHeight/2, i * 25),
                Color = Color3.fromRGB(160, 140, 180),
                Material = Enum.Material.Marble,
                Parent = hallFolder,
            })

            -- Pillar top decoration
            MapBuilder._createPart("PillarTop_" .. i .. "_" .. side, {
                Size = Vector3.new(7, 2, 7),
                Position = Vector3.new(side * 80, wallHeight + 0.5, i * 25),
                Color = Color3.fromRGB(170, 150, 190),
                Material = Enum.Material.Marble,
                Parent = hallFolder,
            })
        end
    end

    -- Vine decorations (green parts on walls)
    for i = 1, 20 do
        local x = math.random(-90, 90)
        local z = math.random(-90, 90)
        local wallSide = math.random(1, 4)
        local vinePos

        if wallSide == 1 then vinePos = Vector3.new(x, math.random(5, 35), -hallSize + 2)
        elseif wallSide == 2 then vinePos = Vector3.new(x, math.random(5, 35), hallSize - 2)
        elseif wallSide == 3 then vinePos = Vector3.new(hallSize - 2, math.random(5, 35), z)
        else vinePos = Vector3.new(-hallSize + 2, math.random(5, 35), z) end

        MapBuilder._createPart("Vine_" .. i, {
            Size = Vector3.new(math.random(2, 5), math.random(5, 15), 1),
            Position = vinePos,
            Color = Color3.fromRGB(50, math.random(120, 180), 50),
            Material = Enum.Material.Grass,
            CanCollide = false,
            Parent = hallFolder,
        })
    end

    -- Floor leaves/petals scattered
    for i = 1, 30 do
        MapBuilder._createPart("Leaf_" .. i, {
            Size = Vector3.new(math.random(1, 3), 0.1, math.random(1, 3)),
            Position = Vector3.new(math.random(-80, 80), 0.1, math.random(-80, 80)),
            Color = Color3.fromRGB(255, math.random(150, 200), 50),
            Material = Enum.Material.Grass,
            CanCollide = false,
            Parent = hallFolder,
        })
    end

    -- Ambient lighting
    local ambientLight = Instance.new("PointLight")
    ambientLight.Brightness = 1.5
    ambientLight.Range = 60
    ambientLight.Color = Color3.fromRGB(200, 180, 255)
    ambientLight.Parent = floor

    -- Mystical floating particles
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 180, 255), Color3.fromRGB(150, 100, 200))
    particleEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    particleEmitter.Lifetime = NumberRange.new(3, 6)
    particleEmitter.Rate = 15
    particleEmitter.Speed = NumberRange.new(0.5, 2)
    particleEmitter.SpreadAngle = Vector2.new(180, 180)
    particleEmitter.LightEmission = 0.8
    particleEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    })
    particleEmitter.Parent = floor

    -- Spawn point
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "MagicHallSpawn"
    spawnLocation.Size = Vector3.new(10, 1, 10)
    spawnLocation.Position = Vector3.new(0, 0.5, 0)
    spawnLocation.Transparency = 1
    spawnLocation.CanCollide = false
    spawnLocation.Anchored = true
    spawnLocation.Parent = hallFolder
end

----------------------------------------------
-- POWER PEDESTALS in Magic Hall
----------------------------------------------
function MapBuilder.buildPedestalDisplay()
    local hallFolder = Workspace:FindFirstChild("MagicHall")
    if not hallFolder then return end

    local pedestalFolder = Instance.new("Folder")
    pedestalFolder.Name = "Pedestals"
    pedestalFolder.Parent = hallFolder

    -- Organize powers into display positions
    -- Arrange in a circular pattern around the hall center
    local allPowers = {}
    for id, power in pairs(PowerRegistry.Powers) do
        if id ~= "Fists" then -- Fists don't need a pedestal
            table.insert(allPowers, power)
        end
    end

    -- Sort by hits required
    table.sort(allPowers, function(a, b) return a.hitsRequired < b.hitsRequired end)

    local numPowers = #allPowers
    local radius = 60 -- distance from center
    local angleStep = (2 * math.pi) / math.max(numPowers, 1)

    for i, power in ipairs(allPowers) do
        local angle = (i - 1) * angleStep
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius

        MapBuilder._createPedestal(pedestalFolder, power, Vector3.new(x, 0, z))
    end
end

function MapBuilder._createPedestal(parent, power, position)
    local pedestalModel = Instance.new("Model")
    pedestalModel.Name = "Pedestal_" .. power.id

    -- Base pedestal
    local base = MapBuilder._createPart("Base", {
        Size = Vector3.new(6, 4, 6),
        Position = position + Vector3.new(0, 2, 0),
        Color = Color3.fromRGB(160, 140, 180),
        Material = Enum.Material.Marble,
        Parent = pedestalModel,
    })

    -- Top platform
    local top = MapBuilder._createPart("Top", {
        Size = Vector3.new(7, 0.5, 7),
        Position = position + Vector3.new(0, 4.25, 0),
        Color = Color3.fromRGB(180, 160, 200),
        Material = Enum.Material.Marble,
        Parent = pedestalModel,
    })

    -- Power orb (glowing sphere representing the power)
    local orb = MapBuilder._createPart("PowerOrb", {
        Size = Vector3.new(3, 3, 3),
        Position = position + Vector3.new(0, 7, 0),
        Color = power.displayColor,
        Material = Enum.Material.Neon,
        Shape = Enum.PartType.Ball,
        CanCollide = false,
        Anchored = true,
        Parent = pedestalModel,
    })

    -- Orb glow
    local pointLight = Instance.new("PointLight")
    pointLight.Color = power.displayColor
    pointLight.Brightness = 2
    pointLight.Range = 15
    pointLight.Parent = orb

    -- Particle effect around orb
    local orbParticle = Instance.new("ParticleEmitter")
    orbParticle.Color = ColorSequence.new(power.displayColor)
    orbParticle.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0),
    })
    orbParticle.Lifetime = NumberRange.new(0.5, 1.5)
    orbParticle.Rate = 20
    orbParticle.Speed = NumberRange.new(1, 3)
    orbParticle.SpreadAngle = Vector2.new(180, 180)
    orbParticle.LightEmission = 1
    orbParticle.Parent = orb

    -- Hit requirement label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = false
    billboard.Parent = orb

    local hitsLabel = Instance.new("TextLabel")
    hitsLabel.Size = UDim2.new(1, 0, 0.4, 0)
    hitsLabel.Position = UDim2.new(0, 0, 0, 0)
    hitsLabel.BackgroundTransparency = 1
    hitsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hitsLabel.TextStrokeTransparency = 0.3
    hitsLabel.TextScaled = true
    hitsLabel.Font = Enum.Font.Fantasy
    hitsLabel.Text = power.hitsRequired .. " Hits"
    hitsLabel.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.4, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = power.displayColor
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.Fantasy
    nameLabel.Text = power.name
    nameLabel.Parent = billboard

    -- Proximity prompt for selecting the power
    local prompt = Instance.new("ProximityPrompt")
    prompt.ObjectText = power.name
    prompt.ActionText = "Select Power"
    prompt.MaxActivationDistance = 8
    prompt.HoldDuration = 0.5
    prompt.Parent = base

    -- Store power ID for the prompt handler
    local powerIdValue = Instance.new("StringValue")
    powerIdValue.Name = "PowerId"
    powerIdValue.Value = power.id
    powerIdValue.Parent = base

    -- Handle proximity prompt activation (server-side: fire client remote to show UI)
    prompt.Triggered:Connect(function(player)
        local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
        if remotesFolder then
            local showPowerSelect = remotesFolder:FindFirstChild("ShowPowerSelect")
            if showPowerSelect then
                showPowerSelect:FireClient(player, power.id, power)
            end
        end
    end)

    pedestalModel.Parent = parent
end

----------------------------------------------
-- ARENA - Open fighting area
----------------------------------------------
function MapBuilder.buildArena()
    local arenaFolder = Workspace:FindFirstChild("Arena")
    if not arenaFolder then
        arenaFolder = Instance.new("Folder")
        arenaFolder.Name = "Arena"
        arenaFolder.Parent = Workspace
    end

    -- Arena constants
    local CENTER = Vector3.new(0, 0, 500) -- arena center from ZoneConfig
    local HALF = 250 -- half of 500 stud arena
    local WALL_H = 15 -- taller border walls

    -- Helper to add interaction tags to a part
    local function tagPart(part, tags)
        -- tags is a table like {Destructible = true, Health = 80, Moveable = true, ...}
        for name, value in pairs(tags) do
            if type(value) == "boolean" then
                local bv = Instance.new("BoolValue")
                bv.Name = name
                bv.Value = value
                bv.Parent = part
            elseif type(value) == "number" then
                local nv = Instance.new("NumberValue")
                nv.Name = name
                nv.Value = value
                nv.Parent = part
            end
        end
    end

    ------------------------------------------------
    -- FLOOR
    ------------------------------------------------
    -- Main arena floor (stone)
    local floor = MapBuilder._createPart("ArenaFloor", {
        Size = Vector3.new(500, 2, 500),
        Position = CENTER + Vector3.new(0, -1, 0),
        Color = Color3.fromRGB(165, 155, 145),
        Material = Enum.Material.Slate,
        Parent = arenaFolder,
    })

    -- Center fighting ring floor highlight (open area ~120 stud diameter)
    MapBuilder._createPart("CenterRing", {
        Size = Vector3.new(120, 0.2, 120),
        Position = CENTER + Vector3.new(0, 0.1, 0),
        Color = Color3.fromRGB(200, 180, 220),
        Material = Enum.Material.Neon,
        Transparency = 0.7,
        Shape = Enum.PartType.Cylinder,
        Orientation = Vector3.new(0, 0, 90),
        CanCollide = false,
        Parent = arenaFolder,
    })

    -- Inner ring marking (thinner decorative circle at 40 stud radius)
    MapBuilder._createPart("InnerRingMark", {
        Size = Vector3.new(80, 0.15, 80),
        Position = CENTER + Vector3.new(0, 0.12, 0),
        Color = Color3.fromRGB(220, 200, 240),
        Material = Enum.Material.Neon,
        Transparency = 0.8,
        Shape = Enum.PartType.Cylinder,
        Orientation = Vector3.new(0, 0, 90),
        CanCollide = false,
        Parent = arenaFolder,
    })

    ------------------------------------------------
    -- BORDER WALLS (taller, 15 studs)
    ------------------------------------------------
    MapBuilder._createWall(arenaFolder, "ArenaWallN",
        Vector3.new(500, WALL_H, 3),
        CENTER + Vector3.new(0, WALL_H / 2, -HALF), Color3.fromRGB(120, 110, 130))
    MapBuilder._createWall(arenaFolder, "ArenaWallS",
        Vector3.new(500, WALL_H, 3),
        CENTER + Vector3.new(0, WALL_H / 2, HALF), Color3.fromRGB(120, 110, 130))
    MapBuilder._createWall(arenaFolder, "ArenaWallE",
        Vector3.new(3, WALL_H, 500),
        CENTER + Vector3.new(HALF, WALL_H / 2, 0), Color3.fromRGB(120, 110, 130))
    MapBuilder._createWall(arenaFolder, "ArenaWallW",
        Vector3.new(3, WALL_H, 500),
        CENTER + Vector3.new(-HALF, WALL_H / 2, 0), Color3.fromRGB(120, 110, 130))

    ------------------------------------------------
    -- DECORATIVE PERIMETER PILLARS WITH TORCHES (8 pillars)
    ------------------------------------------------
    for i = 0, 7 do
        local angle = (i / 8) * math.pi * 2
        local x = math.cos(angle) * 220
        local z = math.sin(angle) * 220

        local pillar = MapBuilder._createPart("ArenaPillar_" .. i, {
            Size = Vector3.new(6, 25, 6),
            Position = CENTER + Vector3.new(x, 12.5, z),
            Color = Color3.fromRGB(150, 140, 170),
            Material = Enum.Material.Marble,
            Parent = arenaFolder,
        })

        -- Torch on top
        local torch = MapBuilder._createPart("Torch_" .. i, {
            Size = Vector3.new(2, 3, 2),
            Position = CENTER + Vector3.new(x, 26, z),
            Color = Color3.fromRGB(255, 150, 50),
            Material = Enum.Material.Neon,
            CanCollide = false,
            Parent = arenaFolder,
        })

        local fireParticle = Instance.new("ParticleEmitter")
        fireParticle.Color = ColorSequence.new(Color3.fromRGB(255, 200, 50), Color3.fromRGB(255, 80, 0))
        fireParticle.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        })
        fireParticle.Lifetime = NumberRange.new(0.5, 1)
        fireParticle.Rate = 30
        fireParticle.Speed = NumberRange.new(3, 6)
        fireParticle.SpreadAngle = Vector2.new(15, 15)
        fireParticle.LightEmission = 1
        fireParticle.Parent = torch

        local torchLight = Instance.new("PointLight")
        torchLight.Color = Color3.fromRGB(255, 180, 80)
        torchLight.Brightness = 2
        torchLight.Range = 30
        torchLight.Parent = torch
    end

    ------------------------------------------------
    -- ROCK PILLARS (destructible cover, mid-zone)
    ------------------------------------------------
    local rockPillarData = {
        { offset = Vector3.new(-90, 6, -70), size = Vector3.new(8, 12, 8), hp = 120 },
        { offset = Vector3.new(90, 6, -70), size = Vector3.new(8, 12, 8), hp = 120 },
        { offset = Vector3.new(-90, 6, 70), size = Vector3.new(8, 12, 8), hp = 120 },
        { offset = Vector3.new(90, 6, 70), size = Vector3.new(8, 12, 8), hp = 120 },
        { offset = Vector3.new(-140, 5, 0), size = Vector3.new(7, 10, 7), hp = 100 },
        { offset = Vector3.new(140, 5, 0), size = Vector3.new(7, 10, 7), hp = 100 },
        -- Smaller pillars closer to center ring edge
        { offset = Vector3.new(-65, 4, -30), size = Vector3.new(5, 8, 5), hp = 80 },
        { offset = Vector3.new(65, 4, 30), size = Vector3.new(5, 8, 5), hp = 80 },
    }

    for i, data in ipairs(rockPillarData) do
        local pillar = MapBuilder._createPart("RockPillar_" .. i, {
            Size = data.size,
            Position = CENTER + data.offset,
            Color = Color3.fromRGB(130, 120, 110),
            Material = Enum.Material.Slate,
            Parent = arenaFolder,
        })
        tagPart(pillar, {
            Destructible = true,
            Health = data.hp,
            Interactable = true,
        })
    end

    ------------------------------------------------
    -- RUINED WALLS (scattered around edges, some destructible)
    ------------------------------------------------
    local ruinedWallData = {
        -- North-ish ruins
        { offset = Vector3.new(-160, 4, -150), size = Vector3.new(30, 8, 3), hp = 100 },
        { offset = Vector3.new(-145, 3, -150), size = Vector3.new(12, 6, 3), hp = nil }, -- non-destructible remnant
        { offset = Vector3.new(150, 5, -140), size = Vector3.new(25, 10, 3), hp = 120 },
        -- South-ish ruins
        { offset = Vector3.new(-170, 4, 140), size = Vector3.new(28, 8, 3), hp = 100 },
        { offset = Vector3.new(160, 3.5, 160), size = Vector3.new(20, 7, 3), hp = 90 },
        -- East/West ruins
        { offset = Vector3.new(180, 5, -50), size = Vector3.new(3, 10, 25), hp = 110 },
        { offset = Vector3.new(-180, 4, 60), size = Vector3.new(3, 8, 22), hp = 100 },
        -- Mid-range partial walls (L-shapes for zoning)
        { offset = Vector3.new(-120, 3.5, -90), size = Vector3.new(18, 7, 3), hp = 80 },
        { offset = Vector3.new(-120, 3.5, -80), size = Vector3.new(3, 7, 16), hp = 80 },
        { offset = Vector3.new(120, 3.5, 90), size = Vector3.new(18, 7, 3), hp = 80 },
        { offset = Vector3.new(120, 3.5, 100), size = Vector3.new(3, 7, 16), hp = 80 },
    }

    for i, data in ipairs(ruinedWallData) do
        local wall = MapBuilder._createPart("RuinedWall_" .. i, {
            Size = data.size,
            Position = CENTER + data.offset,
            Color = Color3.fromRGB(145, 135, 125),
            Material = Enum.Material.Brick,
            Parent = arenaFolder,
        })
        local tags = { Interactable = true }
        if data.hp then
            tags.Destructible = true
            tags.Health = data.hp
        end
        tagPart(wall, tags)
    end

    ------------------------------------------------
    -- RAISED STONE PLATFORMS (3-5 studs high, climbable)
    ------------------------------------------------
    local platformData = {
        -- Large platforms in the four quadrants (outside the center ring)
        { offset = Vector3.new(-110, 2, -110), size = Vector3.new(30, 4, 30) },
        { offset = Vector3.new(110, 2.5, -110), size = Vector3.new(25, 5, 25) },
        { offset = Vector3.new(-110, 2, 110), size = Vector3.new(25, 4, 30) },
        { offset = Vector3.new(110, 1.5, 110), size = Vector3.new(30, 3, 25) },
        -- Elevated perches near mid-range
        { offset = Vector3.new(-60, 2, -120), size = Vector3.new(18, 4, 14) },
        { offset = Vector3.new(60, 2.5, 120), size = Vector3.new(18, 5, 14) },
        -- Small stepping platforms for vertical play
        { offset = Vector3.new(-75, 1.5, 0), size = Vector3.new(12, 3, 12) },
        { offset = Vector3.new(75, 1.5, 0), size = Vector3.new(12, 3, 12) },
    }

    for i, data in ipairs(platformData) do
        local plat = MapBuilder._createPart("Platform_" .. i, {
            Size = data.size,
            Position = CENTER + data.offset,
            Color = Color3.fromRGB(155, 145, 135),
            Material = Enum.Material.Cobblestone,
            Parent = arenaFolder,
        })
        tagPart(plat, {
            Climbable = true,
            Interactable = true,
        })
    end

    ------------------------------------------------
    -- SUNKEN PIT AREAS (lower sections, -3 to -4 studs)
    ------------------------------------------------
    -- We create pit floors below main floor level and cut-out ramps
    local pitData = {
        { offset = Vector3.new(-150, -2, 0), size = Vector3.new(40, 2, 40) },
        { offset = Vector3.new(150, -2.5, 0), size = Vector3.new(35, 1, 35) },
    }

    for i, data in ipairs(pitData) do
        -- Pit floor (lower)
        local pitFloor = MapBuilder._createPart("PitFloor_" .. i, {
            Size = data.size,
            Position = CENTER + data.offset,
            Color = Color3.fromRGB(140, 130, 120),
            Material = Enum.Material.Slate,
            Parent = arenaFolder,
        })
        tagPart(pitFloor, { Interactable = true })

        -- Cut the main floor by placing invisible walls around the pit edges as ramps
        -- Visual edge lip
        local lipThickness = 1
        -- North lip
        MapBuilder._createPart("PitLip_" .. i .. "_N", {
            Size = Vector3.new(data.size.X + 2, 1, lipThickness),
            Position = CENTER + data.offset + Vector3.new(0, data.offset.Y + 1.5, -data.size.Z / 2),
            Color = Color3.fromRGB(130, 120, 110),
            Material = Enum.Material.Slate,
            Parent = arenaFolder,
        })
        -- South lip
        MapBuilder._createPart("PitLip_" .. i .. "_S", {
            Size = Vector3.new(data.size.X + 2, 1, lipThickness),
            Position = CENTER + data.offset + Vector3.new(0, data.offset.Y + 1.5, data.size.Z / 2),
            Color = Color3.fromRGB(130, 120, 110),
            Material = Enum.Material.Slate,
            Parent = arenaFolder,
        })
    end

    ------------------------------------------------
    -- JUMPABLE STRUCTURES: LOW WALLS, CRATES, BROKEN COLUMNS
    ------------------------------------------------

    -- Low walls (waist-high, jumpable)
    local lowWallData = {
        { offset = Vector3.new(-40, 1.5, -80), size = Vector3.new(20, 3, 2) },
        { offset = Vector3.new(40, 1.5, 80), size = Vector3.new(20, 3, 2) },
        { offset = Vector3.new(0, 1.5, -60), size = Vector3.new(2, 3, 16) },
        { offset = Vector3.new(0, 1.5, 60), size = Vector3.new(2, 3, 16) },
        -- Diagonal-ish short walls in mid zone
        { offset = Vector3.new(-30, 1.5, -40), size = Vector3.new(12, 3, 2) },
        { offset = Vector3.new(30, 1.5, 40), size = Vector3.new(12, 3, 2) },
    }

    for i, data in ipairs(lowWallData) do
        local lw = MapBuilder._createPart("LowWall_" .. i, {
            Size = data.size,
            Position = CENTER + data.offset,
            Color = Color3.fromRGB(150, 140, 130),
            Material = Enum.Material.Brick,
            Parent = arenaFolder,
        })
        tagPart(lw, { Interactable = true })
    end

    -- Crates (moveable, destructible)
    local crateData = {
        { offset = Vector3.new(-100, 2.5, -40), size = Vector3.new(5, 5, 5), hp = 50 },
        { offset = Vector3.new(100, 2.5, 40), size = Vector3.new(5, 5, 5), hp = 50 },
        { offset = Vector3.new(-80, 2, -130), size = Vector3.new(4, 4, 4), hp = 40 },
        { offset = Vector3.new(80, 2, 130), size = Vector3.new(4, 4, 4), hp = 40 },
        { offset = Vector3.new(-50, 2.5, 100), size = Vector3.new(5, 5, 5), hp = 50 },
        { offset = Vector3.new(50, 2.5, -100), size = Vector3.new(5, 5, 5), hp = 50 },
        -- Stacked crate pairs
        { offset = Vector3.new(-130, 2, 50), size = Vector3.new(5, 4, 5), hp = 40 },
        { offset = Vector3.new(-130, 5.5, 50), size = Vector3.new(4, 3, 4), hp = 30 },
        { offset = Vector3.new(130, 2, -50), size = Vector3.new(5, 4, 5), hp = 40 },
        { offset = Vector3.new(130, 5.5, -50), size = Vector3.new(4, 3, 4), hp = 30 },
    }

    for i, data in ipairs(crateData) do
        local crate = MapBuilder._createPart("Crate_" .. i, {
            Size = data.size,
            Position = CENTER + data.offset,
            Color = Color3.fromRGB(140, 110, 70),
            Material = Enum.Material.WoodPlanks,
            Parent = arenaFolder,
        })
        tagPart(crate, {
            Destructible = true,
            Health = data.hp,
            Moveable = true,
        })
    end

    -- Broken columns (tall-ish, destructible, some moveable)
    local brokenColumnData = {
        { offset = Vector3.new(-50, 4, -150), size = Vector3.new(5, 8, 5), hp = 90, moveable = false },
        { offset = Vector3.new(50, 3, 150), size = Vector3.new(5, 6, 5), hp = 70, moveable = true },
        { offset = Vector3.new(-170, 5, -80), size = Vector3.new(6, 10, 6), hp = 100, moveable = false },
        { offset = Vector3.new(170, 4, 80), size = Vector3.new(5, 8, 5), hp = 90, moveable = false },
        -- Fallen column segments (horizontal, moveable)
        { offset = Vector3.new(-40, 2, -170), size = Vector3.new(12, 4, 4), hp = 60, moveable = true },
        { offset = Vector3.new(40, 2, 170), size = Vector3.new(4, 4, 12), hp = 60, moveable = true },
    }

    for i, data in ipairs(brokenColumnData) do
        local col = MapBuilder._createPart("BrokenColumn_" .. i, {
            Size = data.size,
            Position = CENTER + data.offset,
            Color = Color3.fromRGB(160, 150, 140),
            Material = Enum.Material.Marble,
            Parent = arenaFolder,
        })
        local tags = {
            Destructible = true,
            Health = data.hp,
            Interactable = true,
        }
        if data.moveable then
            tags.Moveable = true
        end
        tagPart(col, tags)
    end

    ------------------------------------------------
    -- CORNER ZONES (trap/zoning areas with partial enclosures)
    ------------------------------------------------
    -- Each corner gets a cluster: two short walls forming an L and a rock
    local cornerConfigs = {
        { dir = Vector3.new(-1, 0, -1), label = "NW" },
        { dir = Vector3.new(1, 0, -1), label = "NE" },
        { dir = Vector3.new(-1, 0, 1), label = "SW" },
        { dir = Vector3.new(1, 0, 1), label = "SE" },
    }

    for _, cfg in ipairs(cornerConfigs) do
        local cornerCenter = CENTER + cfg.dir * 185

        -- L-wall segment A (along X)
        local wallA = MapBuilder._createPart("CornerWallA_" .. cfg.label, {
            Size = Vector3.new(24, 7, 3),
            Position = cornerCenter + Vector3.new(0, 3.5, cfg.dir.Z * 12),
            Color = Color3.fromRGB(140, 130, 120),
            Material = Enum.Material.Brick,
            Parent = arenaFolder,
        })
        tagPart(wallA, { Destructible = true, Health = 90, Interactable = true })

        -- L-wall segment B (along Z)
        local wallB = MapBuilder._createPart("CornerWallB_" .. cfg.label, {
            Size = Vector3.new(3, 7, 20),
            Position = cornerCenter + Vector3.new(cfg.dir.X * 12, 3.5, 0),
            Color = Color3.fromRGB(140, 130, 120),
            Material = Enum.Material.Brick,
            Parent = arenaFolder,
        })
        tagPart(wallB, { Destructible = true, Health = 90, Interactable = true })

        -- Boulder in corner (moveable)
        local boulder = MapBuilder._createPart("CornerBoulder_" .. cfg.label, {
            Size = Vector3.new(6, 5, 6),
            Position = cornerCenter + Vector3.new(cfg.dir.X * -5, 2.5, cfg.dir.Z * -5),
            Color = Color3.fromRGB(120, 115, 105),
            Material = Enum.Material.Slate,
            Parent = arenaFolder,
        })
        tagPart(boulder, {
            Moveable = true,
            Interactable = true,
            Destructible = true,
            Health = 60,
        })
    end

    ------------------------------------------------
    -- SCATTERED BOULDERS / ROCKS (moveable, interactable)
    ------------------------------------------------
    local boulderData = {
        { offset = Vector3.new(-30, 2, -100), size = Vector3.new(6, 4, 5) },
        { offset = Vector3.new(30, 2.5, 100), size = Vector3.new(7, 5, 6) },
        { offset = Vector3.new(-160, 2, -30), size = Vector3.new(5, 4, 5) },
        { offset = Vector3.new(160, 2, 30), size = Vector3.new(5, 4, 6) },
        { offset = Vector3.new(-20, 1.5, 140), size = Vector3.new(4, 3, 4) },
        { offset = Vector3.new(20, 1.5, -140), size = Vector3.new(4, 3, 5) },
    }

    for i, data in ipairs(boulderData) do
        local rock = MapBuilder._createPart("Boulder_" .. i, {
            Size = data.size,
            Position = CENTER + data.offset,
            Color = Color3.fromRGB(125, 118, 108),
            Material = Enum.Material.Slate,
            Parent = arenaFolder,
        })
        tagPart(rock, {
            Moveable = true,
            Interactable = true,
        })
    end

    ------------------------------------------------
    -- ARENA AMBIENT LIGHTING
    ------------------------------------------------
    local arenaLight = Instance.new("PointLight")
    arenaLight.Brightness = 1
    arenaLight.Range = 60
    arenaLight.Color = Color3.fromRGB(255, 240, 220)
    arenaLight.Parent = floor

    -- Secondary overhead lights for better visibility
    for _, xOff in ipairs({-120, 0, 120}) do
        for _, zOff in ipairs({-120, 0, 120}) do
            local skyLight = MapBuilder._createPart("ArenaOverhead_" .. xOff .. "_" .. zOff, {
                Size = Vector3.new(4, 1, 4),
                Position = CENTER + Vector3.new(xOff, 30, zOff),
                Color = Color3.fromRGB(255, 240, 200),
                Material = Enum.Material.Neon,
                Transparency = 0.9,
                CanCollide = false,
                Parent = arenaFolder,
            })
            local sl = Instance.new("PointLight")
            sl.Brightness = 0.8
            sl.Range = 50
            sl.Color = Color3.fromRGB(255, 240, 220)
            sl.Parent = skyLight
        end
    end

    ------------------------------------------------
    -- RETURN PORTAL MARKER (preserved)
    ------------------------------------------------
    local returnPortalMarker = MapBuilder._createPart("ReturnPortalArea", {
        Size = Vector3.new(12, 0.2, 12),
        Position = CENTER + Vector3.new(0, 0.1, -90),
        Color = Color3.fromRGB(180, 120, 255),
        Material = Enum.Material.Neon,
        Transparency = 0.5,
        CanCollide = false,
        Parent = arenaFolder,
    })
end

----------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------
function MapBuilder._createPart(name, properties)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.Size = properties.Size or Vector3.new(4, 4, 4)
    part.Position = properties.Position or Vector3.new(0, 0, 0)
    part.Color = properties.Color or Color3.fromRGB(128, 128, 128)
    part.Material = properties.Material or Enum.Material.SmoothPlastic

    if properties.Shape then
        part.Shape = properties.Shape
    end
    if properties.Transparency then
        part.Transparency = properties.Transparency
    end
    if properties.CanCollide ~= nil then
        part.CanCollide = properties.CanCollide
    end
    if properties.Orientation then
        part.Orientation = properties.Orientation
    end
    if properties.Parent then
        part.Parent = properties.Parent
    end

    return part
end

function MapBuilder._createWall(parent, name, size, position, color)
    local wall = MapBuilder._createPart(name, {
        Size = size,
        Position = position,
        Color = color or Color3.fromRGB(140, 120, 160),
        Material = Enum.Material.Slate,
        Parent = parent,
    })
    return wall
end

return MapBuilder
