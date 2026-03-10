-- Builds the floating island base
local FloatingIsland = {}

function FloatingIsland.build(parent, position)
	local island = Instance.new("Model")
	island.Name = "FloatingIsland"

	-- Main island top disc (flattened cylinder)
	local top = Instance.new("Part")
	top.Name = "IslandTop"
	top.Shape = Enum.PartType.Cylinder
	top.Size = Vector3.new(12, 260, 260)
	top.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	top.Anchored = true
	top.Material = Enum.Material.SmoothPlastic
	top.Color = Color3.fromRGB(60, 195, 180)
	top.Parent = island

	-- Grass layer on top
	local grass = Instance.new("Part")
	grass.Name = "GrassLayer"
	grass.Shape = Enum.PartType.Cylinder
	grass.Size = Vector3.new(2, 258, 258)
	grass.CFrame = CFrame.new(position + Vector3.new(0, 7, 0)) * CFrame.Angles(0, 0, math.rad(90))
	grass.Anchored = true
	grass.Material = Enum.Material.Grass
	grass.Color = Color3.fromRGB(75, 151, 75)
	grass.Parent = island

	-- Underside glow ring - rectangular windows around perimeter
	for i = 0, 11 do
		local angle = math.rad(i * 30)
		local radius = 115
		local window = Instance.new("Part")
		window.Name = "GlowWindow_" .. i
		window.Size = Vector3.new(30, 10, 6)
		window.CFrame = CFrame.new(
			position + Vector3.new(math.cos(angle) * radius, -4, math.sin(angle) * radius)
		) * CFrame.Angles(0, angle + math.rad(90), 0)
		window.Anchored = true
		window.Material = Enum.Material.Neon
		window.Color = Color3.fromRGB(180, 255, 245)
		window.Parent = island
	end

	-- Underside taper (inverted cone)
	local underside = Instance.new("Part")
	underside.Name = "Underside"
	underside.Shape = Enum.PartType.Ball
	underside.Size = Vector3.new(180, 80, 180)
	underside.CFrame = CFrame.new(position + Vector3.new(0, -30, 0))
	underside.Anchored = true
	underside.Material = Enum.Material.SmoothPlastic
	underside.Color = Color3.fromRGB(55, 180, 165)
	underside.Parent = island

	-- Bottom rock point
	local rockPoint = Instance.new("Part")
	rockPoint.Name = "RockPoint"
	rockPoint.Size = Vector3.new(20, 40, 20)
	rockPoint.CFrame = CFrame.new(position + Vector3.new(0, -70, 0))
	rockPoint.Anchored = true
	rockPoint.Material = Enum.Material.Slate
	rockPoint.Color = Color3.fromRGB(140, 130, 90)
	rockPoint.Parent = island

	-- Glowing orb beneath island
	local orb = Instance.new("Part")
	orb.Name = "BottomOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(12, 12, 12)
	orb.CFrame = CFrame.new(position + Vector3.new(0, -100, 0))
	orb.Anchored = true
	orb.Material = Enum.Material.Neon
	orb.Color = Color3.fromRGB(0, 230, 255)
	orb.Parent = island

	local orbLight = Instance.new("PointLight")
	orbLight.Color = Color3.fromRGB(0, 230, 255)
	orbLight.Brightness = 3
	orbLight.Range = 40
	orbLight.Parent = orb

	-- Floating rock debris around island
	local rng = Random.new(42)
	for i = 1, 14 do
		local angle = rng:NextNumber(0, math.pi * 2)
		local dist = rng:NextNumber(140, 200)
		local yOff = rng:NextNumber(-60, -10)
		local rockSize = rng:NextNumber(6, 16)

		local rock = Instance.new("Part")
		rock.Name = "Debris_" .. i
		rock.Size = Vector3.new(rockSize, rockSize * 0.7, rockSize * 0.9)
		rock.CFrame = CFrame.new(
			position + Vector3.new(math.cos(angle) * dist, yOff, math.sin(angle) * dist)
		) * CFrame.Angles(rng:NextNumber(-0.5, 0.5), rng:NextNumber(0, 3), rng:NextNumber(-0.5, 0.5))
		rock.Anchored = true
		rock.Material = Enum.Material.Slate
		rock.Color = Color3.fromRGB(80, 70, 55)
		rock.Parent = island
	end

	-- Fence posts around island perimeter
	for i = 0, 23 do
		local angle = math.rad(i * 15)
		local radius = 120
		local post = Instance.new("Part")
		post.Name = "FencePost_" .. i
		post.Size = Vector3.new(4, 14, 4)
		post.CFrame = CFrame.new(
			position + Vector3.new(math.cos(angle) * radius, 15, math.sin(angle) * radius)
		)
		post.Anchored = true
		post.Material = Enum.Material.Slate
		post.Color = Color3.fromRGB(45, 40, 40)
		post.Parent = island

		-- Post top ornament
		local cap = Instance.new("Part")
		cap.Name = "PostCap_" .. i
		cap.Shape = Enum.PartType.Ball
		cap.Size = Vector3.new(5, 5, 5)
		cap.CFrame = CFrame.new(
			position + Vector3.new(math.cos(angle) * radius, 23, math.sin(angle) * radius)
		)
		cap.Anchored = true
		cap.Material = Enum.Material.Slate
		cap.Color = Color3.fromRGB(45, 40, 40)
		cap.Parent = island

		-- Fence rail between posts
		if i > 0 then
			local prevAngle = math.rad((i - 1) * 15)
			local p1 = Vector3.new(math.cos(prevAngle) * radius, 12, math.sin(prevAngle) * radius)
			local p2 = Vector3.new(math.cos(angle) * radius, 12, math.sin(angle) * radius)
			local mid = (p1 + p2) / 2
			local dist = (p2 - p1).Magnitude

			local rail = Instance.new("Part")
			rail.Name = "Rail_" .. i
			rail.Size = Vector3.new(dist, 2, 2)
			rail.CFrame = CFrame.lookAt(position + mid, position + p2) * CFrame.Angles(0, math.rad(90), 0)
			rail.Anchored = true
			rail.Material = Enum.Material.Slate
			rail.Color = Color3.fromRGB(50, 45, 42)
			rail.Parent = island
		end
	end

	-- Top crystal spire (on the mansion roof later, but place a beacon)
	local spire = Instance.new("Part")
	spire.Name = "CrystalSpire"
	spire.Size = Vector3.new(3, 18, 3)
	spire.CFrame = CFrame.new(position + Vector3.new(0, 95, 0))
	spire.Anchored = true
	spire.Material = Enum.Material.Neon
	spire.Color = Color3.fromRGB(0, 230, 255)
	spire.Parent = island

	local spireLight = Instance.new("PointLight")
	spireLight.Color = Color3.fromRGB(0, 230, 255)
	spireLight.Brightness = 2
	spireLight.Range = 30
	spireLight.Parent = spire

	island.Parent = parent
	return island, position
end

return FloatingIsland
