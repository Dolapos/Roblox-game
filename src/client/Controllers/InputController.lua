--[[
    InputController.lua
    Handles player input and fires combat/power remotes.
    Binds Q, E, R, T, Y, G for power moves and M1 for fist attacks.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Constants = require(ReplicatedStorage.Shared.Constants)

local InputController = {}
InputController.__index = InputController

function InputController.new()
    local self = setmetatable({}, InputController)
    self._castMoveRemote = nil
    self._fistAttackRemote = nil
    self._enabled = true
    self._keybinds = {
        [Enum.KeyCode.Q] = "Q",
        [Enum.KeyCode.E] = "E",
        [Enum.KeyCode.R] = "R",
        [Enum.KeyCode.T] = "T",
        [Enum.KeyCode.Y] = "Y",
        [Enum.KeyCode.G] = "G",
    }
    return self
end

function InputController:init()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    self._castMoveRemote = remotesFolder:WaitForChild(Remotes.CastMove)
    self._fistAttackRemote = remotesFolder:WaitForChild(Remotes.FistAttack)

    -- Keyboard input for power moves
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not self._enabled then return end

        local slot = self._keybinds[input.KeyCode]
        if slot then
            self:_castMove(slot)
        end
    end)

    -- Mouse click for fist attacks
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not self._enabled then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:_fistAttack()
        end
    end)
end

function InputController:_castMove(slot)
    if self._castMoveRemote then
        self._castMoveRemote:FireServer(slot)
    end
end

function InputController:_fistAttack()
    if self._fistAttackRemote then
        self._fistAttackRemote:FireServer()
    end
end

function InputController:setEnabled(enabled)
    self._enabled = enabled
end

return InputController
