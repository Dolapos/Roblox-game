--[[
    PowerSelectController.lua
    Handles the power selection UI when interacting with pedestals in the Magic Hall.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PowerRegistry = require(ReplicatedStorage.Data.PowerRegistry)

local PowerSelectController = {}
PowerSelectController.__index = PowerSelectController

function PowerSelectController.new()
    local self = setmetatable({}, PowerSelectController)
    self._screenGui = nil
    self._selectFrame = nil
    self._isOpen = false
    self._playerData = nil
    return self
end

function PowerSelectController:init()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- Create the power select screen gui
    self._screenGui = Instance.new("ScreenGui")
    self._screenGui.Name = "PowerSelectUI"
    self._screenGui.ResetOnSpawn = false
    self._screenGui.Enabled = false
    self._screenGui.Parent = playerGui

    self:_buildUI()

    -- Listen for show/hide events
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

    local showPowerSelect = remotesFolder:WaitForChild(Remotes.ShowPowerSelect)
    showPowerSelect.OnClientEvent:Connect(function(powerId, powerData)
        self:_showPowerDetail(powerId, powerData)
    end)

    -- Listen for player data to know what's unlocked
    local playerDataRemote = remotesFolder:WaitForChild(Remotes.PlayerDataLoaded)
    playerDataRemote.OnClientEvent:Connect(function(data)
        self._playerData = data
    end)

    local progressionRemote = remotesFolder:WaitForChild(Remotes.ProgressionUpdate)
    progressionRemote.OnClientEvent:Connect(function(data)
        if self._playerData then
            self._playerData.totalHits = data.totalHits
        end
    end)
end

function PowerSelectController:_buildUI()
    -- Background overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.Parent = self._screenGui

    -- Main panel
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 400, 0, 500)
    panel.Position = UDim2.new(0.5, -200, 0.5, -250)
    panel.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    panel.BorderSizePixel = 0
    panel.Parent = self._screenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = panel

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.Fantasy
    title.TextSize = 28
    title.Text = "Select Power"
    title.Parent = panel

    -- Power name
    local powerName = Instance.new("TextLabel")
    powerName.Name = "PowerName"
    powerName.Size = UDim2.new(1, 0, 0, 40)
    powerName.Position = UDim2.new(0, 0, 0, 50)
    powerName.BackgroundTransparency = 1
    powerName.TextColor3 = Color3.fromRGB(200, 150, 255)
    powerName.Font = Enum.Font.Fantasy
    powerName.TextSize = 24
    powerName.Text = ""
    powerName.Parent = panel

    -- Description
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(0.9, 0, 0, 80)
    description.Position = UDim2.new(0.05, 0, 0, 100)
    description.BackgroundTransparency = 1
    description.TextColor3 = Color3.fromRGB(200, 200, 200)
    description.Font = Enum.Font.Gotham
    description.TextSize = 14
    description.TextWrapped = true
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.Text = ""
    description.Parent = panel

    -- Moves list
    local movesFrame = Instance.new("Frame")
    movesFrame.Name = "MovesFrame"
    movesFrame.Size = UDim2.new(0.9, 0, 0, 180)
    movesFrame.Position = UDim2.new(0.05, 0, 0, 190)
    movesFrame.BackgroundTransparency = 1
    movesFrame.Parent = panel

    local movesLayout = Instance.new("UIListLayout")
    movesLayout.Padding = UDim.new(0, 5)
    movesLayout.Parent = movesFrame

    -- Equip button
    local equipButton = Instance.new("TextButton")
    equipButton.Name = "EquipButton"
    equipButton.Size = UDim2.new(0.6, 0, 0, 45)
    equipButton.Position = UDim2.new(0.2, 0, 0, 390)
    equipButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    equipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    equipButton.Font = Enum.Font.GothamBold
    equipButton.TextSize = 20
    equipButton.Text = "EQUIP"
    equipButton.Parent = panel

    local equipCorner = Instance.new("UICorner")
    equipCorner.CornerRadius = UDim.new(0, 8)
    equipCorner.Parent = equipButton

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.6, 0, 0, 35)
    closeButton.Position = UDim2.new(0.2, 0, 0, 445)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Text = "Close"
    closeButton.Parent = panel

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        self:_close()
    end)

    self._selectFrame = {
        panel = panel,
        title = title,
        powerName = powerName,
        description = description,
        movesFrame = movesFrame,
        equipButton = equipButton,
        closeButton = closeButton,
    }
end

function PowerSelectController:_showPowerDetail(powerId, powerData)
    if not powerData then
        powerData = PowerRegistry.getPower(powerId)
    end
    if not powerData then return end

    local ui = self._selectFrame

    ui.powerName.Text = powerData.name
    ui.powerName.TextColor3 = powerData.displayColor
    ui.description.Text = powerData.description

    -- Clear old moves
    for _, child in ipairs(ui.movesFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    -- Show moves
    local moveDefinitions = self:_getMoveDefinitions(powerData.category)
    if moveDefinitions then
        for i, moveId in ipairs(powerData.moves) do
            local moveDef = moveDefinitions[moveId]
            if moveDef then
                local moveFrame = Instance.new("Frame")
                moveFrame.Size = UDim2.new(1, 0, 0, 55)
                moveFrame.BackgroundColor3 = Color3.fromRGB(40, 35, 50)
                moveFrame.BorderSizePixel = 0
                moveFrame.Parent = ui.movesFrame

                local moveCorner = Instance.new("UICorner")
                moveCorner.CornerRadius = UDim.new(0, 6)
                moveCorner.Parent = moveFrame

                local slotLabel = Instance.new("TextLabel")
                slotLabel.Size = UDim2.new(0, 30, 1, 0)
                slotLabel.BackgroundTransparency = 1
                slotLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                slotLabel.Font = Enum.Font.GothamBold
                slotLabel.TextSize = 16
                slotLabel.Text = moveDef.slot
                slotLabel.Parent = moveFrame

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.5, -30, 0, 25)
                nameLabel.Position = UDim2.new(0, 35, 0, 2)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14
                nameLabel.Text = moveDef.name
                nameLabel.Parent = moveFrame

                local descLabel = Instance.new("TextLabel")
                descLabel.Size = UDim2.new(1, -40, 0, 25)
                descLabel.Position = UDim2.new(0, 35, 0, 27)
                descLabel.BackgroundTransparency = 1
                descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.Font = Enum.Font.Gotham
                descLabel.TextSize = 11
                descLabel.TextTruncate = Enum.TextTruncate.AtEnd
                descLabel.Text = moveDef.description
                descLabel.Parent = moveFrame

                local statsLabel = Instance.new("TextLabel")
                statsLabel.Size = UDim2.new(0.4, 0, 0, 25)
                statsLabel.Position = UDim2.new(0.6, 0, 0, 2)
                statsLabel.BackgroundTransparency = 1
                statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                statsLabel.TextXAlignment = Enum.TextXAlignment.Right
                statsLabel.Font = Enum.Font.Gotham
                statsLabel.TextSize = 11
                statsLabel.Text = "DMG:" .. moveDef.baseDamage .. " CD:" .. moveDef.cooldown .. "s"
                statsLabel.Parent = moveFrame
            end
        end
    end

    -- Setup equip button
    local isUnlocked = self:_isPowerUnlocked(powerId)
    if isUnlocked then
        ui.equipButton.Text = "EQUIP"
        ui.equipButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    else
        ui.equipButton.Text = "LOCKED (" .. powerData.hitsRequired .. " hits needed)"
        ui.equipButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end

    -- Disconnect old connections
    for _, conn in ipairs(ui.equipButton:GetChildren()) do
        if conn:IsA("BindableEvent") then conn:Destroy() end
    end

    ui.equipButton.MouseButton1Click:Connect(function()
        if isUnlocked then
            local equipRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.EquipPower)
            if equipRemote then
                equipRemote:FireServer(powerId)
            end
            self:_close()
        end
    end)

    -- Show the UI
    self._screenGui.Enabled = true
    self._isOpen = true
end

function PowerSelectController:_close()
    self._screenGui.Enabled = false
    self._isOpen = false
end

function PowerSelectController:_isPowerUnlocked(powerId)
    if self._playerData and self._playerData.unlockedPowers then
        for _, id in ipairs(self._playerData.unlockedPowers) do
            if id == powerId then return true end
        end
    end

    -- Check by hit count
    local powerData = PowerRegistry.getPower(powerId)
    if powerData and self._playerData then
        return (self._playerData.totalHits or 0) >= powerData.hitsRequired
    end

    return powerId == "Fists" or powerId == "Quickstep"
end

function PowerSelectController:_getMoveDefinitions(category)
    local success, definitions = pcall(function()
        return require(ReplicatedStorage.Data.MoveDefinitions[category])
    end)
    if success then return definitions end
    return nil
end

return PowerSelectController
