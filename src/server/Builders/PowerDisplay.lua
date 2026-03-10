-- Places power orbs on pedestals and adds BillboardGui labels
local PowerDisplay = {}

function PowerDisplay.populate(hallwayModel, powerList)
	local pedestalsFolder = hallwayModel:FindFirstChild("Pedestals")
	if not pedestalsFolder then
		warn("[PowerDisplay] No Pedestals folder found in hallway")
		return
	end

	for i, powerData in ipairs(powerList) do
		local pedestal = pedestalsFolder:FindFirstChild("Pedestal_" .. i)
		if not pedestal then break end

		local cap = pedestal:FindFirstChild("Cap")
		if not cap then continue end

		-- Create the floating orb
		local orb = Instance.new("Part")
		orb.Name = "PowerOrb_" .. powerData.name
		orb.Shape = Enum.PartType.Ball
		orb.Size = Vector3.new(4, 4, 4)
		orb.CFrame = cap.CFrame * CFrame.new(0, 4, 0)
		orb.Anchored = true
		orb.CanCollide = false
		orb.Material = Enum.Material.Neon
		orb.Color = powerData.color or Color3.fromRGB(255, 255, 255)
		orb.Parent = pedestal

		-- Glow effect
		local light = Instance.new("PointLight")
		light.Color = orb.Color
		light.Brightness = 2
		light.Range = 16
		light.Parent = orb

		-- Tag for client-side float animation
		orb:SetAttribute("FloatingOrb", true)
		orb:SetAttribute("FloatOffset", i * 0.5) -- phase offset for variety

		-- BillboardGui label above orb
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "PowerLabel"
		billboard.Adornee = orb
		billboard.Size = UDim2.new(0, 200, 0, 60)
		billboard.StudsOffset = Vector3.new(0, 4, 0)
		billboard.AlwaysOnTop = false
		billboard.Parent = orb

		-- Hits requirement text
		local hitsLabel = Instance.new("TextLabel")
		hitsLabel.Name = "HitsLabel"
		hitsLabel.Size = UDim2.new(1, 0, 0.45, 0)
		hitsLabel.Position = UDim2.new(0, 0, 0, 0)
		hitsLabel.BackgroundTransparency = 1
		hitsLabel.Text = tostring(powerData.hitsRequired or 0) .. " Hits"
		hitsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		hitsLabel.TextStrokeTransparency = 0.5
		hitsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		hitsLabel.Font = Enum.Font.Fantasy
		hitsLabel.TextScaled = true
		hitsLabel.Parent = billboard

		-- Power name text
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, 0, 0.45, 0)
		nameLabel.Position = UDim2.new(0, 0, 0.5, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = powerData.name
		nameLabel.TextColor3 = powerData.labelColor or powerData.color or Color3.fromRGB(255, 200, 100)
		nameLabel.TextStrokeTransparency = 0.4
		nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		nameLabel.Font = Enum.Font.Fantasy
		nameLabel.TextScaled = true
		nameLabel.Parent = billboard
	end
end

return PowerDisplay
