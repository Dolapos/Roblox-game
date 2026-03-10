-- Client-side controller that animates all floating power orbs
-- Orbs gently bob up and down and slowly rotate for a magical feel
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local FloatingOrbController = {}

local FLOAT_AMPLITUDE = 1.2  -- studs up/down
local FLOAT_SPEED = 1.8      -- cycles per second
local ROTATION_SPEED = 0.5   -- radians per second

local trackedOrbs = {} -- { part, baseY, phaseOffset }

local function scanForOrbs()
	-- Find all parts tagged with FloatingOrb attribute
	for _, desc in ipairs(workspace:GetDescendants()) do
		if desc:IsA("BasePart") and desc:GetAttribute("FloatingOrb") and not trackedOrbs[desc] then
			trackedOrbs[desc] = {
				baseY = desc.Position.Y,
				phase = desc:GetAttribute("FloatOffset") or 0,
			}
		end
	end
end

function FloatingOrbController.start()
	-- Initial scan
	scanForOrbs()

	-- Watch for new orbs being added
	workspace.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") and desc:GetAttribute("FloatingOrb") then
			trackedOrbs[desc] = {
				baseY = desc.Position.Y,
				phase = desc:GetAttribute("FloatOffset") or 0,
			}
		end
	end)

	-- Clean up removed orbs
	workspace.DescendantRemoving:Connect(function(desc)
		trackedOrbs[desc] = nil
	end)

	-- Animate every frame
	RunService.Heartbeat:Connect(function()
		local t = tick()
		for orb, data in pairs(trackedOrbs) do
			if orb.Parent then
				local yOffset = math.sin((t * FLOAT_SPEED + data.phase) * math.pi) * FLOAT_AMPLITUDE
				local rotation = t * ROTATION_SPEED + data.phase

				orb.CFrame = CFrame.new(orb.Position.X, data.baseY + yOffset, orb.Position.Z)
					* CFrame.Angles(0, rotation, 0)
			else
				trackedOrbs[orb] = nil
			end
		end
	end)
end

return FloatingOrbController
