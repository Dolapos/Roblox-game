-- Builds the golden mansion/temple on the floating island
local Mansion = {}

local GOLD = Color3.fromRGB(205, 185, 120)
local GOLD_DARK = Color3.fromRGB(175, 155, 90)
local ROOF_COLOR = Color3.fromRGB(120, 120, 130)
local COLUMN_COLOR = Color3.fromRGB(210, 200, 170)
local WALL_MAT = Enum.Material.SmoothPlastic
local ROOF_MAT = Enum.Material.Slate

function Mansion.build(parent, basePos)
	local mansion = Instance.new("Model")
	mansion.Name = "Mansion"

	local floorY = basePos.Y + 8

	-- ===== MAIN HALL (center building - houses the magic hallway) =====
	-- Floor
	local mainFloor = Instance.new("Part")
	mainFloor.Name = "MainFloor"
	mainFloor.Size = Vector3.new(180, 3, 60)
	mainFloor.CFrame = CFrame.new(basePos.X, floorY, basePos.Z)
	mainFloor.Anchored = true
	mainFloor.Material = WALL_MAT
	mainFloor.Color = GOLD_DARK
	mainFloor.Parent = mansion

	-- Left wall
	local leftWall = Instance.new("Part")
	leftWall.Name = "LeftWall"
	leftWall.Size = Vector3.new(180, 30, 4)
	leftWall.CFrame = CFrame.new(basePos.X, floorY + 16.5, basePos.Z - 28)
	leftWall.Anchored = true
	leftWall.Material = WALL_MAT
	leftWall.Color = GOLD
	leftWall.Parent = mansion

	-- Right wall
	local rightWall = Instance.new("Part")
	rightWall.Name = "RightWall"
	rightWall.Size = Vector3.new(180, 30, 4)
	rightWall.CFrame = CFrame.new(basePos.X, floorY + 16.5, basePos.Z + 28)
	rightWall.Anchored = true
	rightWall.Material = WALL_MAT
	rightWall.Color = GOLD
	rightWall.Parent = mansion

	-- Back wall
	local backWall = Instance.new("Part")
	backWall.Name = "BackWall"
	backWall.Size = Vector3.new(4, 30, 60)
	backWall.CFrame = CFrame.new(basePos.X + 88, floorY + 16.5, basePos.Z)
	backWall.Anchored = true
	backWall.Material = WALL_MAT
	backWall.Color = GOLD
	backWall.Parent = mansion

	-- Front wall (with doorway gap)
	local frontLeft = Instance.new("Part")
	frontLeft.Name = "FrontWallLeft"
	frontLeft.Size = Vector3.new(4, 30, 20)
	frontLeft.CFrame = CFrame.new(basePos.X - 88, floorY + 16.5, basePos.Z - 18)
	frontLeft.Anchored = true
	frontLeft.Material = WALL_MAT
	frontLeft.Color = GOLD
	frontLeft.Parent = mansion

	local frontRight = Instance.new("Part")
	frontRight.Name = "FrontWallRight"
	frontRight.Size = Vector3.new(4, 30, 20)
	frontRight.CFrame = CFrame.new(basePos.X - 88, floorY + 16.5, basePos.Z + 18)
	frontRight.Anchored = true
	frontRight.Material = WALL_MAT
	frontRight.Color = GOLD
	frontRight.Parent = mansion

	-- Door arch top
	local doorArch = Instance.new("Part")
	doorArch.Name = "DoorArch"
	doorArch.Size = Vector3.new(4, 8, 16)
	doorArch.CFrame = CFrame.new(basePos.X - 88, floorY + 27.5, basePos.Z)
	doorArch.Anchored = true
	doorArch.Material = WALL_MAT
	doorArch.Color = GOLD
	doorArch.Parent = mansion

	-- Main roof (triangular prism via wedges)
	local roofCenter = Instance.new("Part")
	roofCenter.Name = "RoofCenter"
	roofCenter.Size = Vector3.new(180, 4, 66)
	roofCenter.CFrame = CFrame.new(basePos.X, floorY + 33, basePos.Z)
	roofCenter.Anchored = true
	roofCenter.Material = ROOF_MAT
	roofCenter.Color = ROOF_COLOR
	roofCenter.Parent = mansion

	-- Pitched roof - left slope
	local roofLeft = Instance.new("WedgePart")
	roofLeft.Name = "RoofSlopeLeft"
	roofLeft.Size = Vector3.new(180, 18, 36)
	roofLeft.CFrame = CFrame.new(basePos.X, floorY + 42, basePos.Z - 15) * CFrame.Angles(0, math.rad(180), 0)
	roofLeft.Anchored = true
	roofLeft.Material = ROOF_MAT
	roofLeft.Color = ROOF_COLOR
	roofLeft.Parent = mansion

	-- Pitched roof - right slope
	local roofRight = Instance.new("WedgePart")
	roofRight.Name = "RoofSlopeRight"
	roofRight.Size = Vector3.new(180, 18, 36)
	roofRight.CFrame = CFrame.new(basePos.X, floorY + 42, basePos.Z + 15)
	roofRight.Anchored = true
	roofRight.Material = ROOF_MAT
	roofRight.Color = ROOF_COLOR
	roofRight.Parent = mansion

	-- ===== CENTER ROTUNDA TOWER =====
	local rotundaY = floorY + 33

	-- Rotunda base cylinder
	local rotundaBase = Instance.new("Part")
	rotundaBase.Name = "RotundaBase"
	rotundaBase.Shape = Enum.PartType.Cylinder
	rotundaBase.Size = Vector3.new(30, 40, 40)
	rotundaBase.CFrame = CFrame.new(basePos.X, rotundaY + 15, basePos.Z) * CFrame.Angles(0, 0, math.rad(90))
	rotundaBase.Anchored = true
	rotundaBase.Material = WALL_MAT
	rotundaBase.Color = GOLD
	rotundaBase.Parent = mansion

	-- Rotunda columns
	for i = 0, 7 do
		local angle = math.rad(i * 45)
		local radius = 18
		local col = Instance.new("Part")
		col.Name = "RotundaColumn_" .. i
		col.Size = Vector3.new(3, 28, 3)
		col.CFrame = CFrame.new(
			basePos.X + math.cos(angle) * radius,
			rotundaY + 14,
			basePos.Z + math.sin(angle) * radius
		)
		col.Anchored = true
		col.Material = Enum.Material.Marble
		col.Color = COLUMN_COLOR
		col.Parent = mansion
	end

	-- Rotunda dome (half sphere approx)
	local dome = Instance.new("Part")
	dome.Name = "RotundaDome"
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(42, 24, 42)
	dome.CFrame = CFrame.new(basePos.X, rotundaY + 30, basePos.Z)
	dome.Anchored = true
	dome.Material = ROOF_MAT
	dome.Color = ROOF_COLOR
	dome.Parent = mansion

	-- ===== SIDE WINGS =====
	for _, side in ipairs({-1, 1}) do
		local wingZ = basePos.Z + side * 50

		-- Wing floor
		local wFloor = Instance.new("Part")
		wFloor.Name = "WingFloor_" .. (side == -1 and "Left" or "Right")
		wFloor.Size = Vector3.new(50, 3, 40)
		wFloor.CFrame = CFrame.new(basePos.X, floorY, wingZ)
		wFloor.Anchored = true
		wFloor.Material = WALL_MAT
		wFloor.Color = GOLD_DARK
		wFloor.Parent = mansion

		-- Wing walls
		for _, wallData in ipairs({
			{Vector3.new(50, 22, 4), CFrame.new(basePos.X, floorY + 12.5, wingZ + side * 18)},
			{Vector3.new(4, 22, 40), CFrame.new(basePos.X + 23, floorY + 12.5, wingZ)},
			{Vector3.new(4, 22, 40), CFrame.new(basePos.X - 23, floorY + 12.5, wingZ)},
		}) do
			local w = Instance.new("Part")
			w.Size = wallData[1]
			w.CFrame = wallData[2]
			w.Anchored = true
			w.Material = WALL_MAT
			w.Color = GOLD
			w.Parent = mansion
		end

		-- Wing roof
		local wRoof = Instance.new("Part")
		wRoof.Size = Vector3.new(54, 3, 44)
		wRoof.CFrame = CFrame.new(basePos.X, floorY + 24, wingZ)
		wRoof.Anchored = true
		wRoof.Material = ROOF_MAT
		wRoof.Color = ROOF_COLOR
		wRoof.Parent = mansion

		-- Pitched wing roof
		local wRoofSlope = Instance.new("WedgePart")
		wRoofSlope.Size = Vector3.new(54, 12, 24)
		wRoofSlope.CFrame = CFrame.new(basePos.X, floorY + 31, wingZ + side * 10)
			* CFrame.Angles(0, side == 1 and 0 or math.rad(180), 0)
		wRoofSlope.Anchored = true
		wRoofSlope.Material = ROOF_MAT
		wRoofSlope.Color = ROOF_COLOR
		wRoofSlope.Parent = mansion
	end

	-- ===== WINDOWS on main hall =====
	for i = -3, 3 do
		if i ~= 0 then
			for _, zOff in ipairs({-28, 28}) do
				local window = Instance.new("Part")
				window.Name = "Window"
				window.Size = Vector3.new(8, 12, 1)
				window.CFrame = CFrame.new(
					basePos.X + i * 22,
					floorY + 16,
					basePos.Z + zOff + (zOff > 0 and 2 or -2)
				)
				window.Anchored = true
				window.Material = Enum.Material.Neon
				window.Color = Color3.fromRGB(255, 240, 180)
				window.Transparency = 0.3
				window.Parent = mansion
			end
		end
	end

	-- ===== ENTRANCE COLUMNS =====
	for _, zOff in ipairs({-7, 7}) do
		local col = Instance.new("Part")
		col.Name = "EntranceColumn"
		col.Size = Vector3.new(3, 28, 3)
		col.CFrame = CFrame.new(basePos.X - 90, floorY + 15.5, basePos.Z + zOff)
		col.Anchored = true
		col.Material = Enum.Material.Marble
		col.Color = COLUMN_COLOR
		col.Parent = mansion
	end

	-- Entrance steps
	for step = 0, 3 do
		local s = Instance.new("Part")
		s.Name = "Step_" .. step
		s.Size = Vector3.new(20 + step * 4, 2, 3)
		s.CFrame = CFrame.new(basePos.X - 93 - step * 3, floorY - 1 - step * 2, basePos.Z)
		s.Anchored = true
		s.Material = Enum.Material.Marble
		s.Color = COLUMN_COLOR
		s.Parent = mansion
	end

	mansion.Parent = parent
	return mansion
end

return Mansion
