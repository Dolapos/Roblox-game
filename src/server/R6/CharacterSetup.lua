--[[
    CharacterSetup.lua
    Forces R6 body type for all players and sets up character properties.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)

local CharacterSetup = {}
CharacterSetup.__index = CharacterSetup

function CharacterSetup.new()
    local self = setmetatable({}, CharacterSetup)
    return self
end

function CharacterSetup:init()
    -- Force R6 for all players
    game:GetService("StarterPlayer").GameSettings.UserEmotesEnabled = false

    -- Setup each new player
    Players.PlayerAdded:Connect(function(player)
        self:_setupPlayer(player)
    end)

    -- Setup existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:_setupPlayer(player)
    end
end

function CharacterSetup:_setupPlayer(player)
    -- When character spawns
    player.CharacterAdded:Connect(function(character)
        self:_setupCharacter(player, character)
    end)

    -- If character already exists
    if player.Character then
        self:_setupCharacter(player, player.Character)
    end
end

function CharacterSetup:_setupCharacter(player, character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end

    -- Set R6 properties
    humanoid.MaxHealth = Constants.MAX_HEALTH
    humanoid.Health = Constants.MAX_HEALTH
    humanoid.WalkSpeed = Constants.BASE_WALK_SPEED

    -- Create a value to track equipped power (readable by client)
    local powerValue = character:FindFirstChild("EquippedPower")
    if not powerValue then
        powerValue = Instance.new("StringValue")
        powerValue.Name = "EquippedPower"
        powerValue.Value = "Fists"
        powerValue.Parent = character
    end

    -- Create hit counter display above head
    local billboard = character:FindFirstChild("HitCounterBillboard")
    if not billboard then
        local head = character:WaitForChild("Head", 5)
        if head then
            billboard = Instance.new("BillboardGui")
            billboard.Name = "HitCounterBillboard"
            billboard.Size = UDim2.new(0, 100, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = false
            billboard.Parent = head

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "PowerName"
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.Fantasy
            nameLabel.Text = "Fists"
            nameLabel.Parent = billboard
        end
    end
end

return CharacterSetup
