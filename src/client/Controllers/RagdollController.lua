--[[
    RagdollController.lua
    Client-side ragdoll visual assists.
    Works with server-side RagdollService for physics.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RagdollController = {}
RagdollController.__index = RagdollController

function RagdollController.new()
    local self = setmetatable({}, RagdollController)
    self._isRagdolled = false
    return self
end

function RagdollController:init()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

    local ragdollRemote = remotesFolder:WaitForChild(Remotes.Ragdoll)
    ragdollRemote.OnClientEvent:Connect(function(targetPlayer, duration)
        self:_onRagdoll(targetPlayer, duration)
    end)

    local ragdollEndRemote = remotesFolder:WaitForChild(Remotes.RagdollEnd)
    ragdollEndRemote.OnClientEvent:Connect(function(targetPlayer)
        self:_onRagdollEnd(targetPlayer)
    end)
end

function RagdollController:_onRagdoll(targetPlayer, duration)
    local localPlayer = Players.LocalPlayer
    if targetPlayer == localPlayer then
        self._isRagdolled = true
        -- Client-side camera effects during ragdoll
        self:_ragdollCameraEffect(duration)
    end
end

function RagdollController:_onRagdollEnd(targetPlayer)
    local localPlayer = Players.LocalPlayer
    if targetPlayer == localPlayer then
        self._isRagdolled = false
    end
end

function RagdollController:_ragdollCameraEffect(duration)
    -- Slight camera wobble during ragdoll
    local camera = Workspace.CurrentCamera
    if not camera then return end

    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < duration and self._isRagdolled do
            local offset = CFrame.Angles(
                math.rad(math.random(-2, 2)),
                math.rad(math.random(-2, 2)),
                math.rad(math.random(-1, 1))
            )
            -- Gentle camera offset
            task.wait(0.05)
        end
    end)
end

function RagdollController:isRagdolled()
    return self._isRagdolled
end

return RagdollController
