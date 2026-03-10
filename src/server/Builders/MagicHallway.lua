-- Builds the magical hallway inside the mansion with purple stone walls,
-- ivy vines, Roman pedestals in a row, and floating power orbs.
local MagicHallway = {}

local STONE = Color3.fromRGB(145, 125, 165)
local STONE_DARK = Color3.fromRGB(110, 95, 135)
local STONE_FLOOR = Color3.fromRGB(130, 115, 150)
local VINE_COLOR = Color3.fromRGB(45, 90, 45)
local MOSS_COLOR = Color3.fromRGB(85, 120, 55)
local PEDESTAL_COLOR = Color3.fromRGB(165, 150, 175)
local AMBIENT_COLOR = Color3.fromRGB(160, 130, 200)

local PEDESTAL_SPACING = 12
local MAX_PEDESTALS = 50
local HALLWAY_LENGTH = MAX_PEDESTALS * PEDESTAL_SPACING + 40

-- Build a single Roman pedestal (rectangular stone block with base and cap)
local function buildPedestal(parent, position, index)
	local pedestal = Instance.new("Model")
	pedestal.Name = "Pedestal_" .. index

	-- Slight height stagger: alternating pattern like the reference image
	local heightOffset = (index % 3 == 0) and 1.5 or (index % 3 == 1) and 0 or 0.8
	local baseY = position.Y + heightOffset

	-- Base (wider bottom)
	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(7, 2, 7)
	base.CFrame = CFrame.new(position.X, baseY + 1, position.Z)
	base.Anchored = true
	base.Material = Enum.Material.Limestone
	base.Color = PEDESTAL_COLOR
	base.Parent = pedestal

	-- Main column (rectangular, like reference image)
	local column = Instance.new("Part")
	column.Name = "Column"
	column.Size = Vector3.new(5.5, 8, 5.5)
	column.CFrame = CFrame.new(position.X, baseY + 6, position.Z)
	column.Anchored = true
	column.Material = Enum.Material.Limestone
	column.Color = PEDESTAL_COLOR
	column.Parent = pedestal

	-- Cap (wider top slab)
	local cap = Instance.new("Part")
	cap.Name = "Cap"
	cap.Size = Vector3.new(7, 1.5, 7)
	cap.CFrame = CFrame.new(position.X, baseY + 10.75, position.Z)
	cap.Anchored = true
	cap.Material = Enum.Material.Limestone
	cap.Color = PEDESTAL_COLOR
	cap.Parent = pedestal

	-- Floating orb anchor point (orb added by PowerDisplay system)
	local orbAttach = Instance.new("Attachment")
	orbAttach.Name = "OrbAttach"
	orbAttach.Position = Vector3.new(0, 3, 0)
	orbAttach.Parent = cap

	pedestal.Parent = parent
	return pedestal
end

-- Scatter decorative ivy/vine pieces on a wall
local function addVines(parent, wallCFrame, wallWidth, wallHeight, count, rng)
	for i = 1, count do
		local xOff = rng:NextNumber(-wallWidth / 2 + 3, wallWidth / 2 - 3)
		local yOff = rng:NextNumber(-wallHeight / 2 + 2, wallHeight / 2 - 5)
		local size = rng:NextNumber(2, 5)

		local vine = Instance.new("Part")
		vine.Name = "Vine_" .. i
		vine.Size = Vector3.new(size, size * 1.5, 1)
		vine.CFrame = wallCFrame * CFrame.new(xOff, yOff, -0.5)
			* CFrame.Angles(0, 0, rng:NextNumber(-0.3, 0.3))
		vine.Anchored = true
		vine.Material = Enum.Material.Grass
		vine.Color = VINE_COLOR
		vine.CanCollide = false
		vine.Parent = parent
	end
end

-- Scatter moss patches on floor
local function addMoss(parent, floorPos, length, width, count, rng)
	for i = 1, count do
		local xOff = rng:NextNumber(-length / 2 + 5, length / 2 - 5)
		local zOff = rng:NextNumber(-width / 2 + 2, width / 2 - 2)
		local size = rng:NextNumber(2, 6)

		local moss = Instance.new("Part")
		moss.Name = "Moss_" .. i
		moss.Size = Vector3.new(size, 0.2, size * 0.8)
		moss.CFrame = CFrame.new(floorPos.X + xOff, floorPos.Y + 1.6, floorPos.Z + zOff)
		moss.Anchored = true
		moss.Material = Enum.Material.Grass
		moss.Color = MOSS_COLOR
		moss.CanCollide = false
		moss.Parent = parent
	end
end

-- Scatter golden leaf particles on floor
local function addGoldenLeaves(parent, floorPos, length, width, count, rng)
	for i = 1, count do
		local xOff = rng:NextNumber(-length / 2 + 5, length / 2 - 5)
		local zOff = rng:NextNumber(-width / 2 + 2, width / 2 - 2)

		local leaf = Instance.new("Part")
		leaf.Name = "GoldenLeaf_" .. i
		leaf.Size = Vector3.new(0.6, 0.1, 0.4)
		leaf.CFrame = CFrame.new(floorPos.X + xOff, floorPos.Y + 1.55, floorPos.Z + zOff)
			* CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0)
		leaf.Anchored = true
		leaf.Material = Enum.Material.Neon
		leaf.Color = Color3.fromRGB(220, 180, 60)
		leaf.CanCollide = false
		leaf.Parent = parent
	end
end

function MagicHallway.build(parent, basePos)
	local hallway = Instance.new("Model")
	hallway.Name = "MagicHallway"

	local rng = Random.new(123)
	local floorY = basePos.Y + 8

	-- The hallway runs along the X axis inside the mansion
	local hallCenter = Vector3.new(basePos.X, floorY, basePos.Z)

	-- ===== INTERIOR FLOOR (purple stone) =====
	local floor = Instance.new("Part")
	floor.Name = "HallwayFloor"
	floor.Size = Vector3.new(HALLWAY_LENGTH, 3, 50)
	floor.CFrame = CFrame.new(hallCenter.X, floorY, hallCenter.Z)
	floor.Anchored = true
	floor.Material = Enum.Material.Limestone
	floor.Color = STONE_FLOOR
	floor.Parent = hallway

	-- ===== INTERIOR WALLS (purple stone, taller for dramatic feel) =====
	local wallHeight = 28
	local wallY = floorY + wallHeight / 2 + 1.5

	-- Left interior wall
	local leftIWall = Instance.new("Part")
	leftIWall.Name = "InteriorWallLeft"
	leftIWall.Size = Vector3.new(HALLWAY_LENGTH, wallHeight, 3)
	leftIWall.CFrame = CFrame.new(hallCenter.X, wallY, hallCenter.Z - 23.5)
	leftIWall.Anchored = true
	leftIWall.Material = Enum.Material.Limestone
	leftIWall.Color = STONE
	leftIWall.Parent = hallway

	-- Right interior wall
	local rightIWall = Instance.new("Part")
	rightIWall.Name = "InteriorWallRight"
	rightIWall.Size = Vector3.new(HALLWAY_LENGTH, wallHeight, 3)
	rightIWall.CFrame = CFrame.new(hallCenter.X, wallY, hallCenter.Z + 23.5)
	rightIWall.Anchored = true
	rightIWall.Material = Enum.Material.Limestone
	rightIWall.Color = STONE
	rightIWall.Parent = hallway

	-- ===== CEILING =====
	local ceiling = Instance.new("Part")
	ceiling.Name = "Ceiling"
	ceiling.Size = Vector3.new(HALLWAY_LENGTH, 3, 50)
	ceiling.CFrame = CFrame.new(hallCenter.X, floorY + wallHeight + 1.5, hallCenter.Z)
	ceiling.Anchored = true
	ceiling.Material = Enum.Material.Limestone
	ceiling.Color = STONE_DARK
	ceiling.Parent = hallway

	-- ===== WALL PILLARS (stone columns between pedestal sections) =====
	for side = -1, 1, 2 do
		local wallZ = hallCenter.Z + side * 23.5
		for i = 0, 8 do
			local xPos = hallCenter.X - HALLWAY_LENGTH / 2 + 20 + i * (HALLWAY_LENGTH / 9)
			local pillar = Instance.new("Part")
			pillar.Name = "WallPillar"
			pillar.Size = Vector3.new(4, wallHeight + 2, 4)
			pillar.CFrame = CFrame.new(xPos, wallY, wallZ + side * 0.5)
			pillar.Anchored = true
			pillar.Material = Enum.Material.Limestone
			pillar.Color = STONE_DARK
			pillar.Parent = hallway
		end
	end

	-- ===== IVY / VINES on walls =====
	addVines(hallway, leftIWall.CFrame, HALLWAY_LENGTH, wallHeight, 40, rng)
	addVines(hallway, rightIWall.CFrame * CFrame.Angles(0, math.rad(180), 0), HALLWAY_LENGTH, wallHeight, 40, rng)

	-- ===== MOSS on floor =====
	addMoss(hallway, hallCenter, HALLWAY_LENGTH, 45, 60, rng)

	-- ===== GOLDEN LEAVES on floor =====
	addGoldenLeaves(hallway, hallCenter, HALLWAY_LENGTH, 45, 80, rng)

	-- ===== AMBIENT PURPLE LIGHTING =====
	local lightSpacing = HALLWAY_LENGTH / 8
	for i = 0, 7 do
		local xPos = hallCenter.X - HALLWAY_LENGTH / 2 + 20 + i * lightSpacing

		local ambientLight = Instance.new("Part")
		ambientLight.Name = "AmbientLight_" .. i
		ambientLight.Size = Vector3.new(2, 1, 2)
		ambientLight.CFrame = CFrame.new(xPos, floorY + wallHeight, hallCenter.Z)
		ambientLight.Anchored = true
		ambientLight.Material = Enum.Material.Neon
		ambientLight.Color = AMBIENT_COLOR
		ambientLight.Transparency = 0.6
		ambientLight.CanCollide = false
		ambientLight.Parent = hallway

		local pl = Instance.new("PointLight")
		pl.Color = AMBIENT_COLOR
		pl.Brightness = 1.5
		pl.Range = 35
		pl.Parent = ambientLight
	end

	-- ===== PEDESTALS (side by side in a row along X axis) =====
	local pedestals = Instance.new("Folder")
	pedestals.Name = "Pedestals"
	pedestals.Parent = hallway

	local startX = hallCenter.X - (MAX_PEDESTALS - 1) * PEDESTAL_SPACING / 2
	for i = 1, MAX_PEDESTALS do
		local pedX = startX + (i - 1) * PEDESTAL_SPACING
		local pedPos = Vector3.new(pedX, floorY, hallCenter.Z)
		buildPedestal(pedestals, pedPos, i)
	end

	hallway.Parent = parent
	return hallway
end

return MagicHallway
