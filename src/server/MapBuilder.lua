--[[
    MapBuilder.lua
    Procedurally builds the Magic Hall and Arena maps.
    Magic Hall: Grand medieval hall with power pedestals and a teleport portal.
    Arena: Open-air battlefield with trees, rocks, water, and destructible objects.
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PowerRegistry = require(ReplicatedStorage.Data.PowerRegistry)

local MapBuilder = {}

-- Arena center offset (Z=500 from origin, same as ZoneConfig)
local ARENA_CENTER = Vector3.new(0, 0, 500)

----------------------------------------------
-- MAGIC HALL
----------------------------------------------
function MapBuilder.buildMagicHall()
    local hallFolder = Workspace:FindFirstChild("MagicHall")
    if not hallFolder then
        hallFolder = Instance.new("Folder")
        hallFolder.Name = "MagicHall"
        hallFolder.Parent = Workspace
    end

    local HALL_HALF = 100 -- half of 200-stud hall
    local WALL_H = 40

    ------------------------------------------------
    -- FLOOR - polished marble with inlaid pattern
    ------------------------------------------------
    MapBuilder._createPart("HallFloor", {
        Size = Vector3.new(200, 2, 200),
        Position = Vector3.new(0, -1, 0),
        Color = Color3.fromRGB(230, 225, 240),
        Material = Enum.Material.Marble,
        Parent = hallFolder,
    })

    -- Center circle (magic sigil area)
    MapBuilder._createPart("CenterCircle", {
        Size = Vector3.new(40, 0.1, 40),
        Position = Vector3.new(0, 0.1, 0),
        Color = Color3.fromRGB(180, 140, 220),
        Material = Enum.Material.Marble,
        Shape = Enum.PartType.Cylinder,
        Orientation = Vector3.new(0, 0, 90),
        Parent = hallFolder,
    })

    -- Outer decorative ring
    MapBuilder._createPart("OuterRing", {
        Size = Vector3.new(60, 0.08, 60),
        Position = Vector3.new(0, 0.08, 0),
        Color = Color3.fromRGB(200, 170, 240),
        Material = Enum.Material.Neon,
        Shape = Enum.PartType.Cylinder,
        Orientation = Vector3.new(0, 0, 90),
        Transparency = 0.6,
        CanCollide = false,
        Parent = hallFolder,
    })

    ------------------------------------------------
    -- WALLS - lighter stone with decorative trim
    ------------------------------------------------
    local wallColor = Color3.fromRGB(210, 200, 220)

    -- North wall
    MapBuilder._createWall(hallFolder, "NorthWall",
        Vector3.new(200, WALL_H, 4), Vector3.new(0, WALL_H/2, -HALL_HALF), wallColor)

    -- South wall (split for portal archway)
    MapBuilder._createWall(hallFolder, "SouthWallLeft",
        Vector3.new(75, WALL_H, 4), Vector3.new(-62.5, WALL_H/2, HALL_HALF), wallColor)
    MapBuilder._createWall(hallFolder, "SouthWallRight",
        Vector3.new(75, WALL_H, 4), Vector3.new(62.5, WALL_H/2, HALL_HALF), wallColor)
    -- Arch above portal opening
    MapBuilder._createWall(hallFolder, "SouthArch",
        Vector3.new(50, 15, 4), Vector3.new(0, WALL_H - 7.5, HALL_HALF), wallColor)

    -- East/West walls
    MapBuilder._createWall(hallFolder, "EastWall",
        Vector3.new(4, WALL_H, 200), Vector3.new(HALL_HALF, WALL_H/2, 0), wallColor)
    MapBuilder._createWall(hallFolder, "WestWall",
        Vector3.new(4, WALL_H, 200), Vector3.new(-HALL_HALF, WALL_H/2, 0), wallColor)

    ------------------------------------------------
    -- CEILING with large skylights
    ------------------------------------------------
    MapBuilder._createPart("Ceiling", {
        Size = Vector3.new(200, 2, 200),
        Position = Vector3.new(0, WALL_H + 1, 0),
        Color = Color3.fromRGB(200, 195, 210),
        Material = Enum.Material.Slate,
        Transparency = 0,
        Parent = hallFolder,
    })

    -- Skylights (bright glass panels)
    for i = -2, 2 do
        local skylight = MapBuilder._createPart("Skylight_" .. i, {
            Size = Vector3.new(15, 2.1, 15),
            Position = Vector3.new(i * 25, WALL_H + 1, 0),
            Color = Color3.fromRGB(240, 235, 255),
            Material = Enum.Material.Neon,
            Transparency = 0.3,
            Parent = hallFolder,
        })
        local beam = Instance.new("SpotLight")
        beam.Brightness = 5
        beam.Range = 50
        beam.Angle = 50
        beam.Color = Color3.fromRGB(255, 250, 240)
        beam.Face = Enum.NormalId.Bottom
        beam.Parent = skylight
    end

    ------------------------------------------------
    -- PILLARS with torches
    ------------------------------------------------
    for i = -3, 3 do
        for _, side in ipairs({-1, 1}) do
            local px = side * 80
            local pz = i * 25

            MapBuilder._createPart("Pillar_" .. i .. "_" .. side, {
                Size = Vector3.new(5, WALL_H, 5),
                Position = Vector3.new(px, WALL_H/2, pz),
                Color = Color3.fromRGB(220, 210, 230),
                Material = Enum.Material.Marble,
                Parent = hallFolder,
            })

            MapBuilder._createPart("PillarCap_" .. i .. "_" .. side, {
                Size = Vector3.new(7, 2, 7),
                Position = Vector3.new(px, WALL_H + 0.5, pz),
                Color = Color3.fromRGB(225, 215, 235),
                Material = Enum.Material.Marble,
                Parent = hallFolder,
            })

            -- Wall torch (warm light)
            local torch = MapBuilder._createPart("Torch_" .. i .. "_" .. side, {
                Size = Vector3.new(1, 2, 1),
                Position = Vector3.new(px + side * -3, 12, pz),
                Color = Color3.fromRGB(255, 200, 100),
                Material = Enum.Material.Neon,
                CanCollide = false,
                Parent = hallFolder,
            })

            local torchLight = Instance.new("PointLight")
            torchLight.Color = Color3.fromRGB(255, 220, 150)
            torchLight.Brightness = 1.5
            torchLight.Range = 20
            torchLight.Parent = torch

            local flame = Instance.new("ParticleEmitter")
            flame.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80), Color3.fromRGB(255, 100, 20))
            flame.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.6),
                NumberSequenceKeypoint.new(1, 0),
            })
            flame.Lifetime = NumberRange.new(0.3, 0.7)
            flame.Rate = 20
            flame.Speed = NumberRange.new(2, 4)
            flame.SpreadAngle = Vector2.new(10, 10)
            flame.LightEmission = 1
            flame.Parent = torch
        end
    end

    ------------------------------------------------
    -- VINE DECORATIONS (organic touches)
    ------------------------------------------------
    for i = 1, 15 do
        local x = math.random(-90, 90)
        local z = math.random(-90, 90)
        local wallSide = math.random(1, 4)
        local vinePos

        if wallSide == 1 then vinePos = Vector3.new(x, math.random(8, 30), -HALL_HALF + 2)
        elseif wallSide == 2 then vinePos = Vector3.new(x, math.random(8, 30), HALL_HALF - 2)
        elseif wallSide == 3 then vinePos = Vector3.new(HALL_HALF - 2, math.random(8, 30), z)
        else vinePos = Vector3.new(-HALL_HALF + 2, math.random(8, 30), z) end

        MapBuilder._createPart("Vine_" .. i, {
            Size = Vector3.new(math.random(2, 4), math.random(6, 14), 1),
            Position = vinePos,
            Color = Color3.fromRGB(70, math.random(150, 200), 70),
            Material = Enum.Material.Grass,
            CanCollide = false,
            Parent = hallFolder,
        })
    end

    -- Floor petals
    for i = 1, 20 do
        MapBuilder._createPart("Petal_" .. i, {
            Size = Vector3.new(math.random(1, 2), 0.1, math.random(1, 2)),
            Position = Vector3.new(math.random(-70, 70), 0.1, math.random(-70, 70)),
            Color = Color3.fromRGB(255, math.random(180, 230), math.random(100, 180)),
            Material = Enum.Material.Grass,
            CanCollide = false,
            Parent = hallFolder,
        })
    end

    ------------------------------------------------
    -- AMBIENT LIGHTING (bright & warm)
    ------------------------------------------------
    local floorAmbient = Instance.new("PointLight")
    floorAmbient.Brightness = 2
    floorAmbient.Range = 80
    floorAmbient.Color = Color3.fromRGB(255, 245, 230)
    floorAmbient.Parent = hallFolder:FindFirstChild("HallFloor") or hallFolder

    -- Floating mystical particles
    local floor = hallFolder:FindFirstChild("HallFloor")
    if floor then
        local particles = Instance.new("ParticleEmitter")
        particles.Color = ColorSequence.new(Color3.fromRGB(220, 200, 255), Color3.fromRGB(180, 140, 240))
        particles.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(0.5, 0.5),
            NumberSequenceKeypoint.new(1, 0),
        })
        particles.Lifetime = NumberRange.new(3, 6)
        particles.Rate = 12
        particles.Speed = NumberRange.new(0.5, 2)
        particles.SpreadAngle = Vector2.new(180, 180)
        particles.LightEmission = 0.9
        particles.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.4),
            NumberSequenceKeypoint.new(1, 1),
        })
        particles.Parent = floor
    end

    ------------------------------------------------
    -- SPAWN LOCATION
    ------------------------------------------------
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "MagicHallSpawn"
    spawnLocation.Size = Vector3.new(10, 1, 10)
    spawnLocation.Position = Vector3.new(0, 0.5, 0)
    spawnLocation.Transparency = 1
    spawnLocation.CanCollide = false
    spawnLocation.Anchored = true
    spawnLocation.Parent = hallFolder

    ------------------------------------------------
    -- TELEPORT PORTAL (south wall archway)
    ------------------------------------------------
    MapBuilder._buildPortal(hallFolder)
end

----------------------------------------------
-- TELEPORT PORTAL in Magic Hall
----------------------------------------------
function MapBuilder._buildPortal(hallFolder)
    local portalModel = Instance.new("Model")
    portalModel.Name = "TeleportPortal"
    portalModel.Parent = hallFolder

    -- Portal frame (stone archway)
    -- Left column
    MapBuilder._createPart("PortalFrameL", {
        Size = Vector3.new(4, 24, 4),
        Position = Vector3.new(-14, 12, 97),
        Color = Color3.fromRGB(160, 140, 200),
        Material = Enum.Material.Marble,
        Parent = portalModel,
    })

    -- Right column
    MapBuilder._createPart("PortalFrameR", {
        Size = Vector3.new(4, 24, 4),
        Position = Vector3.new(14, 12, 97),
        Color = Color3.fromRGB(160, 140, 200),
        Material = Enum.Material.Marble,
        Parent = portalModel,
    })

    -- Top arch
    MapBuilder._createPart("PortalArch", {
        Size = Vector3.new(32, 4, 4),
        Position = Vector3.new(0, 25, 97),
        Color = Color3.fromRGB(170, 150, 210),
        Material = Enum.Material.Marble,
        Parent = portalModel,
    })

    -- Rune stones on frame
    for _, xOff in ipairs({-14, 14}) do
        for h = 5, 20, 5 do
            local rune = MapBuilder._createPart("Rune_" .. xOff .. "_" .. h, {
                Size = Vector3.new(1, 1, 0.5),
                Position = Vector3.new(xOff, h, 95),
                Color = Color3.fromRGB(180, 120, 255),
                Material = Enum.Material.Neon,
                CanCollide = false,
                Parent = portalModel,
            })
            local runeLight = Instance.new("PointLight")
            runeLight.Color = Color3.fromRGB(180, 120, 255)
            runeLight.Brightness = 0.5
            runeLight.Range = 5
            runeLight.Parent = rune
        end
    end

    -- Portal vortex surface (the glowing portal itself)
    local vortex = MapBuilder._createPart("PortalVortex", {
        Size = Vector3.new(24, 22, 2),
        Position = Vector3.new(0, 12, 97),
        Color = Color3.fromRGB(100, 60, 200),
        Material = Enum.Material.Neon,
        Transparency = 0.25,
        CanCollide = false,
        Parent = portalModel,
    })

    -- Strong glow
    local portalGlow = Instance.new("PointLight")
    portalGlow.Color = Color3.fromRGB(150, 100, 255)
    portalGlow.Brightness = 4
    portalGlow.Range = 40
    portalGlow.Parent = vortex

    -- Swirling particles
    local swirl = Instance.new("ParticleEmitter")
    swirl.Color = ColorSequence.new(
        Color3.fromRGB(180, 130, 255),
        Color3.fromRGB(100, 50, 220)
    )
    swirl.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 1.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    swirl.Lifetime = NumberRange.new(1, 2.5)
    swirl.Rate = 60
    swirl.Speed = NumberRange.new(3, 8)
    swirl.SpreadAngle = Vector2.new(180, 180)
    swirl.LightEmission = 1
    swirl.Rotation = NumberRange.new(-180, 180)
    swirl.RotSpeed = NumberRange.new(-100, 100)
    swirl.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 1),
    })
    swirl.Parent = vortex

    -- Secondary particle layer (sparkles)
    local sparkle = Instance.new("ParticleEmitter")
    sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    sparkle.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 0),
    })
    sparkle.Lifetime = NumberRange.new(0.5, 1.5)
    sparkle.Rate = 30
    sparkle.Speed = NumberRange.new(2, 6)
    sparkle.SpreadAngle = Vector2.new(180, 180)
    sparkle.LightEmission = 1
    sparkle.Parent = vortex

    -- Ground glow ring at portal base
    local groundGlow = MapBuilder._createPart("PortalGroundGlow", {
        Size = Vector3.new(28, 0.2, 10),
        Position = Vector3.new(0, 0.1, 97),
        Color = Color3.fromRGB(150, 100, 255),
        Material = Enum.Material.Neon,
        Transparency = 0.5,
        CanCollide = false,
        Parent = portalModel,
    })

    -- "Enter Arena" label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 16, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = vortex

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeColor3 = Color3.fromRGB(100, 50, 200)
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.Fantasy
    label.Text = "ENTER ARENA"
    label.Parent = billboard
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

    local allPowers = {}
    for id, power in pairs(PowerRegistry.Powers) do
        if id ~= "Fists" then
            table.insert(allPowers, power)
        end
    end

    table.sort(allPowers, function(a, b) return a.hitsRequired < b.hitsRequired end)

    local numPowers = #allPowers
    local radius = 60
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

    local base = MapBuilder._createPart("Base", {
        Size = Vector3.new(6, 4, 6),
        Position = position + Vector3.new(0, 2, 0),
        Color = Color3.fromRGB(210, 200, 225),
        Material = Enum.Material.Marble,
        Parent = pedestalModel,
    })

    MapBuilder._createPart("Top", {
        Size = Vector3.new(7, 0.5, 7),
        Position = position + Vector3.new(0, 4.25, 0),
        Color = Color3.fromRGB(220, 210, 235),
        Material = Enum.Material.Marble,
        Parent = pedestalModel,
    })

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

    local pointLight = Instance.new("PointLight")
    pointLight.Color = power.displayColor
    pointLight.Brightness = 2.5
    pointLight.Range = 18
    pointLight.Parent = orb

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

    -- Labels
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

    -- Proximity prompt
    local prompt = Instance.new("ProximityPrompt")
    prompt.ObjectText = power.name
    prompt.ActionText = "Select Power"
    prompt.MaxActivationDistance = 8
    prompt.HoldDuration = 0.5
    prompt.Parent = base

    local powerIdValue = Instance.new("StringValue")
    powerIdValue.Name = "PowerId"
    powerIdValue.Value = power.id
    powerIdValue.Parent = base

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
-- ARENA - Interactive open-air battlefield
----------------------------------------------
function MapBuilder.buildArena()
    local arenaFolder = Workspace:FindFirstChild("Arena")
    if not arenaFolder then
        arenaFolder = Instance.new("Folder")
        arenaFolder.Name = "Arena"
        arenaFolder.Parent = Workspace
    end

    local C = ARENA_CENTER
    local HALF = 250
    local WALL_H = 15

    local function tagPart(part, tags)
        for name, value in pairs(tags) do
            if type(value) == "boolean" then
                local bv = Instance.new("BoolValue"); bv.Name = name; bv.Value = value; bv.Parent = part
            elseif type(value) == "number" then
                local nv = Instance.new("NumberValue"); nv.Name = name; nv.Value = value; nv.Parent = part
            end
        end
    end

    ------------------------------------------------
    -- TERRAIN: Multi-material ground
    ------------------------------------------------
    -- Main arena floor (lighter, sunlit stone)
    local floor = MapBuilder._createPart("ArenaFloor", {
        Size = Vector3.new(500, 2, 500),
        Position = C + Vector3.new(0, -1, 0),
        Color = Color3.fromRGB(195, 190, 175),
        Material = Enum.Material.Slate,
        Parent = arenaFolder,
    })

    -- Grass patches around edges
    local grassPositions = {
        {-180, -180}, {-180, 0}, {-180, 180},
        {180, -180}, {180, 0}, {180, 180},
        {0, -200}, {0, 200},
        {-100, -180}, {100, -180}, {-100, 180}, {100, 180},
    }
    for i, pos in ipairs(grassPositions) do
        MapBuilder._createPart("GrassPatch_" .. i, {
            Size = Vector3.new(math.random(30, 50), 0.3, math.random(30, 50)),
            Position = C + Vector3.new(pos[1], -0.8, pos[2]),
            Color = Color3.fromRGB(math.random(80, 110), math.random(160, 200), math.random(60, 90)),
            Material = Enum.Material.Grass,
            Parent = arenaFolder,
        })
    end

    -- Dirt paths
    local dirtPaths = {
        {Vector3.new(0, -0.7, 0), Vector3.new(12, 0.4, 180)},  -- N-S path
        {Vector3.new(0, -0.7, 0), Vector3.new(180, 0.4, 12)},  -- E-W path
    }
    for i, path in ipairs(dirtPaths) do
        MapBuilder._createPart("DirtPath_" .. i, {
            Size = path[2],
            Position = C + path[1],
            Color = Color3.fromRGB(160, 140, 110),
            Material = Enum.Material.Sand,
            Parent = arenaFolder,
        })
    end

    -- Center fighting ring
    MapBuilder._createPart("CenterRing", {
        Size = Vector3.new(120, 0.2, 120),
        Position = C + Vector3.new(0, 0.1, 0),
        Color = Color3.fromRGB(220, 200, 240),
        Material = Enum.Material.Neon,
        Transparency = 0.75,
        Shape = Enum.PartType.Cylinder,
        Orientation = Vector3.new(0, 0, 90),
        CanCollide = false,
        Parent = arenaFolder,
    })

    ------------------------------------------------
    -- BORDER WALLS
    ------------------------------------------------
    local borderColor = Color3.fromRGB(160, 155, 145)
    MapBuilder._createWall(arenaFolder, "ArenaWallN",
        Vector3.new(500, WALL_H, 3), C + Vector3.new(0, WALL_H/2, -HALF), borderColor)
    MapBuilder._createWall(arenaFolder, "ArenaWallS",
        Vector3.new(500, WALL_H, 3), C + Vector3.new(0, WALL_H/2, HALF), borderColor)
    MapBuilder._createWall(arenaFolder, "ArenaWallE",
        Vector3.new(3, WALL_H, 500), C + Vector3.new(HALF, WALL_H/2, 0), borderColor)
    MapBuilder._createWall(arenaFolder, "ArenaWallW",
        Vector3.new(3, WALL_H, 500), C + Vector3.new(-HALF, WALL_H/2, 0), borderColor)

    ------------------------------------------------
    -- TREES (interactive - destructible, provide cover)
    ------------------------------------------------
    local treePositions = {
        {-160, -140, 14, 80}, {-120, -170, 12, 70}, {-190, -60, 16, 90},
        {160, -140, 13, 75}, {180, -80, 15, 85}, {130, -180, 11, 65},
        {-160, 140, 14, 80}, {-180, 60, 12, 70}, {-130, 180, 15, 85},
        {160, 140, 13, 75}, {190, 80, 16, 90}, {140, 170, 11, 65},
        {-80, -160, 10, 60}, {80, -160, 12, 70}, {-80, 160, 11, 65}, {80, 160, 13, 75},
        -- Some mid-field trees for tactical play
        {-100, -50, 10, 55}, {100, 50, 10, 55},
        {-50, 100, 9, 50}, {50, -100, 9, 50},
    }

    for i, td in ipairs(treePositions) do
        MapBuilder._buildTree(arenaFolder, i, C + Vector3.new(td[1], 0, td[2]), td[3], td[4], tagPart)
    end

    ------------------------------------------------
    -- ROCK FORMATIONS (cover, destructible)
    ------------------------------------------------
    local rockData = {
        {offset = Vector3.new(-90, 6, -70), size = Vector3.new(8, 12, 8), hp = 120},
        {offset = Vector3.new(90, 6, -70), size = Vector3.new(8, 12, 8), hp = 120},
        {offset = Vector3.new(-90, 6, 70), size = Vector3.new(8, 12, 8), hp = 120},
        {offset = Vector3.new(90, 6, 70), size = Vector3.new(8, 12, 8), hp = 120},
        {offset = Vector3.new(-140, 5, 0), size = Vector3.new(7, 10, 7), hp = 100},
        {offset = Vector3.new(140, 5, 0), size = Vector3.new(7, 10, 7), hp = 100},
        {offset = Vector3.new(-65, 4, -30), size = Vector3.new(5, 8, 5), hp = 80},
        {offset = Vector3.new(65, 4, 30), size = Vector3.new(5, 8, 5), hp = 80},
    }

    for i, data in ipairs(rockData) do
        local pillar = MapBuilder._createPart("RockPillar_" .. i, {
            Size = data.size,
            Position = C + data.offset,
            Color = Color3.fromRGB(150, 140, 130),
            Material = Enum.Material.Slate,
            Parent = arenaFolder,
        })
        tagPart(pillar, { Destructible = true, Health = data.hp, Interactable = true })
    end

    ------------------------------------------------
    -- RUINED WALLS (scattered cover)
    ------------------------------------------------
    local ruinedWallData = {
        {offset = Vector3.new(-160, 4, -150), size = Vector3.new(30, 8, 3), hp = 100},
        {offset = Vector3.new(150, 5, -140), size = Vector3.new(25, 10, 3), hp = 120},
        {offset = Vector3.new(-170, 4, 140), size = Vector3.new(28, 8, 3), hp = 100},
        {offset = Vector3.new(160, 3.5, 160), size = Vector3.new(20, 7, 3), hp = 90},
        {offset = Vector3.new(180, 5, -50), size = Vector3.new(3, 10, 25), hp = 110},
        {offset = Vector3.new(-180, 4, 60), size = Vector3.new(3, 8, 22), hp = 100},
        {offset = Vector3.new(-120, 3.5, -90), size = Vector3.new(18, 7, 3), hp = 80},
        {offset = Vector3.new(-120, 3.5, -80), size = Vector3.new(3, 7, 16), hp = 80},
        {offset = Vector3.new(120, 3.5, 90), size = Vector3.new(18, 7, 3), hp = 80},
        {offset = Vector3.new(120, 3.5, 100), size = Vector3.new(3, 7, 16), hp = 80},
    }

    for i, data in ipairs(ruinedWallData) do
        local wall = MapBuilder._createPart("RuinedWall_" .. i, {
            Size = data.size,
            Position = C + data.offset,
            Color = Color3.fromRGB(175, 165, 155),
            Material = Enum.Material.Brick,
            Parent = arenaFolder,
        })
        tagPart(wall, { Destructible = true, Health = data.hp, Interactable = true })
    end

    ------------------------------------------------
    -- PLATFORMS (elevated, climbable)
    ------------------------------------------------
    local platformData = {
        {offset = Vector3.new(-110, 2, -110), size = Vector3.new(30, 4, 30)},
        {offset = Vector3.new(110, 2.5, -110), size = Vector3.new(25, 5, 25)},
        {offset = Vector3.new(-110, 2, 110), size = Vector3.new(25, 4, 30)},
        {offset = Vector3.new(110, 1.5, 110), size = Vector3.new(30, 3, 25)},
        {offset = Vector3.new(-60, 2, -120), size = Vector3.new(18, 4, 14)},
        {offset = Vector3.new(60, 2.5, 120), size = Vector3.new(18, 5, 14)},
        {offset = Vector3.new(-75, 1.5, 0), size = Vector3.new(12, 3, 12)},
        {offset = Vector3.new(75, 1.5, 0), size = Vector3.new(12, 3, 12)},
    }

    for i, data in ipairs(platformData) do
        local plat = MapBuilder._createPart("Platform_" .. i, {
            Size = data.size,
            Position = C + data.offset,
            Color = Color3.fromRGB(185, 175, 165),
            Material = Enum.Material.Cobblestone,
            Parent = arenaFolder,
        })
        tagPart(plat, { Climbable = true, Interactable = true })
    end

    ------------------------------------------------
    -- WATER FEATURES (hazard areas)
    ------------------------------------------------
    -- Small pond (slows players)
    local pond = MapBuilder._createPart("Pond", {
        Size = Vector3.new(30, 0.5, 30),
        Position = C + Vector3.new(-150, -0.7, 0),
        Color = Color3.fromRGB(80, 140, 200),
        Material = Enum.Material.Glass,
        Transparency = 0.3,
        Parent = arenaFolder,
    })
    tagPart(pond, { WaterHazard = true, SlowFactor = 0.6 })

    -- Water particles on pond
    local waterParticles = Instance.new("ParticleEmitter")
    waterParticles.Color = ColorSequence.new(Color3.fromRGB(120, 180, 240))
    waterParticles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0),
    })
    waterParticles.Lifetime = NumberRange.new(1, 2)
    waterParticles.Rate = 8
    waterParticles.Speed = NumberRange.new(0.5, 1.5)
    waterParticles.SpreadAngle = Vector2.new(180, 0)
    waterParticles.LightEmission = 0.3
    waterParticles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    })
    waterParticles.Parent = pond

    -- Stream / creek
    MapBuilder._createPart("Creek", {
        Size = Vector3.new(6, 0.3, 80),
        Position = C + Vector3.new(150, -0.7, 0),
        Color = Color3.fromRGB(90, 150, 210),
        Material = Enum.Material.Glass,
        Transparency = 0.3,
        Parent = arenaFolder,
    })

    ------------------------------------------------
    -- CRATES (moveable, destructible)
    ------------------------------------------------
    local crateData = {
        {offset = Vector3.new(-100, 2.5, -40), size = Vector3.new(5, 5, 5), hp = 50},
        {offset = Vector3.new(100, 2.5, 40), size = Vector3.new(5, 5, 5), hp = 50},
        {offset = Vector3.new(-80, 2, -130), size = Vector3.new(4, 4, 4), hp = 40},
        {offset = Vector3.new(80, 2, 130), size = Vector3.new(4, 4, 4), hp = 40},
        {offset = Vector3.new(-50, 2.5, 100), size = Vector3.new(5, 5, 5), hp = 50},
        {offset = Vector3.new(50, 2.5, -100), size = Vector3.new(5, 5, 5), hp = 50},
        {offset = Vector3.new(-130, 2, 50), size = Vector3.new(5, 4, 5), hp = 40},
        {offset = Vector3.new(-130, 5.5, 50), size = Vector3.new(4, 3, 4), hp = 30},
        {offset = Vector3.new(130, 2, -50), size = Vector3.new(5, 4, 5), hp = 40},
        {offset = Vector3.new(130, 5.5, -50), size = Vector3.new(4, 3, 4), hp = 30},
    }

    for i, data in ipairs(crateData) do
        local crate = MapBuilder._createPart("Crate_" .. i, {
            Size = data.size,
            Position = C + data.offset,
            Color = Color3.fromRGB(160, 130, 80),
            Material = Enum.Material.WoodPlanks,
            Parent = arenaFolder,
        })
        tagPart(crate, { Destructible = true, Health = data.hp, Moveable = true })
    end

    ------------------------------------------------
    -- BROKEN COLUMNS
    ------------------------------------------------
    local columnData = {
        {offset = Vector3.new(-50, 4, -150), size = Vector3.new(5, 8, 5), hp = 90, moveable = false},
        {offset = Vector3.new(50, 3, 150), size = Vector3.new(5, 6, 5), hp = 70, moveable = true},
        {offset = Vector3.new(-170, 5, -80), size = Vector3.new(6, 10, 6), hp = 100, moveable = false},
        {offset = Vector3.new(170, 4, 80), size = Vector3.new(5, 8, 5), hp = 90, moveable = false},
        {offset = Vector3.new(-40, 2, -170), size = Vector3.new(12, 4, 4), hp = 60, moveable = true},
        {offset = Vector3.new(40, 2, 170), size = Vector3.new(4, 4, 12), hp = 60, moveable = true},
    }

    for i, data in ipairs(columnData) do
        local col = MapBuilder._createPart("BrokenColumn_" .. i, {
            Size = data.size,
            Position = C + data.offset,
            Color = Color3.fromRGB(190, 180, 170),
            Material = Enum.Material.Marble,
            Parent = arenaFolder,
        })
        local tags = { Destructible = true, Health = data.hp, Interactable = true }
        if data.moveable then tags.Moveable = true end
        tagPart(col, tags)
    end

    ------------------------------------------------
    -- LOW WALLS (jumpable cover)
    ------------------------------------------------
    local lowWallData = {
        {offset = Vector3.new(-40, 1.5, -80), size = Vector3.new(20, 3, 2)},
        {offset = Vector3.new(40, 1.5, 80), size = Vector3.new(20, 3, 2)},
        {offset = Vector3.new(0, 1.5, -60), size = Vector3.new(2, 3, 16)},
        {offset = Vector3.new(0, 1.5, 60), size = Vector3.new(2, 3, 16)},
        {offset = Vector3.new(-30, 1.5, -40), size = Vector3.new(12, 3, 2)},
        {offset = Vector3.new(30, 1.5, 40), size = Vector3.new(12, 3, 2)},
    }

    for i, data in ipairs(lowWallData) do
        local lw = MapBuilder._createPart("LowWall_" .. i, {
            Size = data.size,
            Position = C + data.offset,
            Color = Color3.fromRGB(180, 170, 160),
            Material = Enum.Material.Brick,
            Parent = arenaFolder,
        })
        tagPart(lw, { Interactable = true })
    end

    ------------------------------------------------
    -- CORNER ENCLOSURES (tactical L-shapes)
    ------------------------------------------------
    local cornerConfigs = {
        {dir = Vector3.new(-1, 0, -1), label = "NW"},
        {dir = Vector3.new(1, 0, -1), label = "NE"},
        {dir = Vector3.new(-1, 0, 1), label = "SW"},
        {dir = Vector3.new(1, 0, 1), label = "SE"},
    }

    for _, cfg in ipairs(cornerConfigs) do
        local cc = C + cfg.dir * 185

        local wallA = MapBuilder._createPart("CornerWallA_" .. cfg.label, {
            Size = Vector3.new(24, 7, 3),
            Position = cc + Vector3.new(0, 3.5, cfg.dir.Z * 12),
            Color = Color3.fromRGB(170, 160, 150),
            Material = Enum.Material.Brick,
            Parent = arenaFolder,
        })
        tagPart(wallA, { Destructible = true, Health = 90, Interactable = true })

        local wallB = MapBuilder._createPart("CornerWallB_" .. cfg.label, {
            Size = Vector3.new(3, 7, 20),
            Position = cc + Vector3.new(cfg.dir.X * 12, 3.5, 0),
            Color = Color3.fromRGB(170, 160, 150),
            Material = Enum.Material.Brick,
            Parent = arenaFolder,
        })
        tagPart(wallB, { Destructible = true, Health = 90, Interactable = true })

        local boulder = MapBuilder._createPart("CornerBoulder_" .. cfg.label, {
            Size = Vector3.new(6, 5, 6),
            Position = cc + Vector3.new(cfg.dir.X * -5, 2.5, cfg.dir.Z * -5),
            Color = Color3.fromRGB(140, 135, 125),
            Material = Enum.Material.Slate,
            Parent = arenaFolder,
        })
        tagPart(boulder, { Moveable = true, Interactable = true, Destructible = true, Health = 60 })
    end

    ------------------------------------------------
    -- SCATTERED BOULDERS
    ------------------------------------------------
    local boulderData = {
        {offset = Vector3.new(-30, 2, -100), size = Vector3.new(6, 4, 5)},
        {offset = Vector3.new(30, 2.5, 100), size = Vector3.new(7, 5, 6)},
        {offset = Vector3.new(-160, 2, -30), size = Vector3.new(5, 4, 5)},
        {offset = Vector3.new(160, 2, 30), size = Vector3.new(5, 4, 6)},
        {offset = Vector3.new(-20, 1.5, 140), size = Vector3.new(4, 3, 4)},
        {offset = Vector3.new(20, 1.5, -140), size = Vector3.new(4, 3, 5)},
    }

    for i, data in ipairs(boulderData) do
        local rock = MapBuilder._createPart("Boulder_" .. i, {
            Size = data.size,
            Position = C + data.offset,
            Color = Color3.fromRGB(145, 138, 128),
            Material = Enum.Material.Slate,
            Parent = arenaFolder,
        })
        tagPart(rock, { Moveable = true, Interactable = true })
    end

    ------------------------------------------------
    -- BUSHES (decorative cover, can hide in)
    ------------------------------------------------
    local bushPositions = {
        {-70, -130}, {70, -130}, {-70, 130}, {70, 130},
        {-140, -100}, {140, -100}, {-140, 100}, {140, 100},
        {-30, -60}, {30, 60}, {-60, 30}, {60, -30},
    }

    for i, pos in ipairs(bushPositions) do
        local bush = MapBuilder._createPart("Bush_" .. i, {
            Size = Vector3.new(math.random(4, 7), math.random(3, 5), math.random(4, 7)),
            Position = C + Vector3.new(pos[1], 1.5, pos[2]),
            Color = Color3.fromRGB(math.random(50, 80), math.random(140, 180), math.random(40, 70)),
            Material = Enum.Material.LeafyGrass,
            CanCollide = false,
            Parent = arenaFolder,
        })
        tagPart(bush, { HideSpot = true })
    end

    ------------------------------------------------
    -- ARENA LIGHTING (bright, open sky feel)
    ------------------------------------------------
    local arenaLight = Instance.new("PointLight")
    arenaLight.Brightness = 1.5
    arenaLight.Range = 80
    arenaLight.Color = Color3.fromRGB(255, 248, 235)
    arenaLight.Parent = floor

    -- Overhead lights for visibility
    for _, xOff in ipairs({-120, 0, 120}) do
        for _, zOff in ipairs({-120, 0, 120}) do
            local skyLight = MapBuilder._createPart("ArenaOverhead_" .. xOff .. "_" .. zOff, {
                Size = Vector3.new(4, 1, 4),
                Position = C + Vector3.new(xOff, 35, zOff),
                Color = Color3.fromRGB(255, 250, 230),
                Material = Enum.Material.Neon,
                Transparency = 0.95,
                CanCollide = false,
                Parent = arenaFolder,
            })
            local sl = Instance.new("PointLight")
            sl.Brightness = 1.2
            sl.Range = 60
            sl.Color = Color3.fromRGB(255, 248, 235)
            sl.Parent = skyLight
        end
    end

    ------------------------------------------------
    -- PERIMETER TORCHES (8 pillars with fire)
    ------------------------------------------------
    for i = 0, 7 do
        local angle = (i / 8) * math.pi * 2
        local x = math.cos(angle) * 220
        local z = math.sin(angle) * 220

        MapBuilder._createPart("ArenaPillar_" .. i, {
            Size = Vector3.new(6, 25, 6),
            Position = C + Vector3.new(x, 12.5, z),
            Color = Color3.fromRGB(180, 170, 160),
            Material = Enum.Material.Marble,
            Parent = arenaFolder,
        })

        local torch = MapBuilder._createPart("ArenaTorch_" .. i, {
            Size = Vector3.new(2, 3, 2),
            Position = C + Vector3.new(x, 26, z),
            Color = Color3.fromRGB(255, 180, 60),
            Material = Enum.Material.Neon,
            CanCollide = false,
            Parent = arenaFolder,
        })

        local fireP = Instance.new("ParticleEmitter")
        fireP.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80), Color3.fromRGB(255, 100, 20))
        fireP.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        })
        fireP.Lifetime = NumberRange.new(0.4, 0.8)
        fireP.Rate = 25
        fireP.Speed = NumberRange.new(3, 6)
        fireP.SpreadAngle = Vector2.new(12, 12)
        fireP.LightEmission = 1
        fireP.Parent = torch

        local tl = Instance.new("PointLight")
        tl.Color = Color3.fromRGB(255, 200, 100)
        tl.Brightness = 2
        tl.Range = 35
        tl.Parent = torch
    end

    ------------------------------------------------
    -- RETURN PORTAL MARKER
    ------------------------------------------------
    local returnPortal = MapBuilder._createPart("ReturnPortalArea", {
        Size = Vector3.new(14, 0.2, 14),
        Position = C + Vector3.new(0, 0.1, -100),
        Color = Color3.fromRGB(150, 100, 255),
        Material = Enum.Material.Neon,
        Transparency = 0.4,
        CanCollide = false,
        Parent = arenaFolder,
    })

    -- Return portal glow
    local rpParticles = Instance.new("ParticleEmitter")
    rpParticles.Color = ColorSequence.new(Color3.fromRGB(180, 140, 255))
    rpParticles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0),
    })
    rpParticles.Lifetime = NumberRange.new(0.5, 1.5)
    rpParticles.Rate = 15
    rpParticles.Speed = NumberRange.new(2, 5)
    rpParticles.SpreadAngle = Vector2.new(180, 0)
    rpParticles.LightEmission = 1
    rpParticles.Parent = returnPortal

    ------------------------------------------------
    -- NPC BOSS SPAWN AREA (center-ish, marked)
    ------------------------------------------------
    local bossArena = MapBuilder._createPart("BossSpawnArea", {
        Size = Vector3.new(40, 0.15, 40),
        Position = C + Vector3.new(0, 0.08, 0),
        Color = Color3.fromRGB(255, 80, 80),
        Material = Enum.Material.Neon,
        Transparency = 0.85,
        CanCollide = false,
        Parent = arenaFolder,
    })
end

----------------------------------------------
-- TREE BUILDER
----------------------------------------------
function MapBuilder._buildTree(parent, index, basePos, height, hp, tagPart)
    local treeModel = Instance.new("Model")
    treeModel.Name = "Tree_" .. index

    -- Trunk
    local trunkHeight = height * 0.6
    local trunk = MapBuilder._createPart("Trunk", {
        Size = Vector3.new(3, trunkHeight, 3),
        Position = basePos + Vector3.new(0, trunkHeight / 2, 0),
        Color = Color3.fromRGB(math.random(100, 130), math.random(70, 90), math.random(40, 60)),
        Material = Enum.Material.Wood,
        Parent = treeModel,
    })
    tagPart(trunk, { Destructible = true, Health = hp, Interactable = true, IsTree = true })

    -- Canopy layers (multiple spheres for fullness)
    local canopyBase = basePos + Vector3.new(0, trunkHeight, 0)
    local leafColor = Color3.fromRGB(
        math.random(40, 80),
        math.random(140, 200),
        math.random(30, 70)
    )

    -- Main canopy
    MapBuilder._createPart("Canopy1", {
        Size = Vector3.new(height * 0.8, height * 0.5, height * 0.8),
        Position = canopyBase + Vector3.new(0, height * 0.2, 0),
        Color = leafColor,
        Material = Enum.Material.LeafyGrass,
        Shape = Enum.PartType.Ball,
        CanCollide = false,
        Parent = treeModel,
    })

    -- Upper canopy
    MapBuilder._createPart("Canopy2", {
        Size = Vector3.new(height * 0.5, height * 0.4, height * 0.5),
        Position = canopyBase + Vector3.new(0, height * 0.4, 0),
        Color = Color3.fromRGB(
            math.min(leafColor.R * 255 + 15, 255),
            math.min(leafColor.G * 255 + 20, 255),
            math.min(leafColor.B * 255 + 10, 255)
        ),
        Material = Enum.Material.LeafyGrass,
        Shape = Enum.PartType.Ball,
        CanCollide = false,
        Parent = treeModel,
    })

    -- Leaf particles (falling leaves)
    local leafEmitter = Instance.new("ParticleEmitter")
    leafEmitter.Color = ColorSequence.new(leafColor, Color3.fromRGB(200, 180, 50))
    leafEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    leafEmitter.Lifetime = NumberRange.new(3, 6)
    leafEmitter.Rate = 2
    leafEmitter.Speed = NumberRange.new(0.5, 2)
    leafEmitter.SpreadAngle = Vector2.new(60, 60)
    leafEmitter.Rotation = NumberRange.new(-180, 180)
    leafEmitter.RotSpeed = NumberRange.new(-30, 30)
    leafEmitter.LightEmission = 0.2
    leafEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.8, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    leafEmitter.Parent = treeModel:FindFirstChild("Canopy1")

    treeModel.Parent = parent
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

    if properties.Shape then part.Shape = properties.Shape end
    if properties.Transparency then part.Transparency = properties.Transparency end
    if properties.CanCollide ~= nil then part.CanCollide = properties.CanCollide end
    if properties.Orientation then part.Orientation = properties.Orientation end
    if properties.Parent then part.Parent = properties.Parent end

    return part
end

function MapBuilder._createWall(parent, name, size, position, color)
    return MapBuilder._createPart(name, {
        Size = size,
        Position = position,
        Color = color or Color3.fromRGB(180, 170, 160),
        Material = Enum.Material.Slate,
        Parent = parent,
    })
end

return MapBuilder
