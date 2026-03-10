local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local RunAnimationController = {}

-- Replace with your custom run animation asset ID
local RUN_ANIM_ID = "rbxassetid://616163682"
local MIN_SPEED = 0.5

local player = Players.LocalPlayer
local runTrack = nil
local isRunning = false

local function isForwardOnly()
	local forward = UserInputService:IsKeyDown(Enum.KeyCode.W)
	local back = UserInputService:IsKeyDown(Enum.KeyCode.S)
	local left = UserInputService:IsKeyDown(Enum.KeyCode.A)
	local right = UserInputService:IsKeyDown(Enum.KeyCode.D)

	return forward and not back and not left and not right
end

local function getHumanoid()
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function stopRun()
	if runTrack and isRunning then
		runTrack:Stop(0.2)
		isRunning = false
	end
end

local function startRun()
	if runTrack and not isRunning then
		runTrack:Play(0.2)
		isRunning = true
	end
end

local function setupRunTrack(humanoid)
	if runTrack then
		runTrack:Stop()
		runTrack:Destroy()
		runTrack = nil
		isRunning = false
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = humanoid:WaitForChild("Animator", 5)
	end
	if not animator then return end

	local runAnim = Instance.new("Animation")
	runAnim.AnimationId = RUN_ANIM_ID

	runTrack = animator:LoadAnimation(runAnim)
	runTrack.Priority = Enum.AnimationPriority.Action
	runTrack.Looped = true
end

function RunAnimationController.start()
	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not humanoid then return end

		-- Wait for animator to be ready
		task.wait(0.5)
		setupRunTrack(humanoid)
	end

	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)

	RunService.Heartbeat:Connect(function()
		local humanoid = getHumanoid()
		if not humanoid then
			stopRun()
			return
		end

		local moving = humanoid.MoveDirection.Magnitude > MIN_SPEED
		local shouldRun = moving and isForwardOnly()

		if shouldRun and not isRunning then
			startRun()
		elseif not shouldRun and isRunning then
			stopRun()
		end
	end)
end

return RunAnimationController
