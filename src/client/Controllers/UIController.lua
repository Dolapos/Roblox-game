--[[
    UIController.lua
    Manages all client-side UI: HUD, menus, notifications.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Constants = require(ReplicatedStorage.Shared.Constants)

local UIController = {}
UIController.__index = UIController

function UIController.new()
    local self = setmetatable({}, UIController)
    self._playerGui = nil
    self._screenGui = nil
    self._healthBar = nil
    self._comboCounter = nil
    self._hitCounter = nil
    self._powerIndicator = nil
    self._cooldownFrames = {}
    self._notificationQueue = {}
    self._currentCombo = 0
    self._comboResetThread = nil
    return self
end

function UIController:init()
    local player = Players.LocalPlayer
    self._playerGui = player:WaitForChild("PlayerGui")

    -- Create main ScreenGui
    self._screenGui = Instance.new("ScreenGui")
    self._screenGui.Name = "GameHUD"
    self._screenGui.ResetOnSpawn = false
    self._screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self._screenGui.Parent = self._playerGui

    self:_createHealthBar()
    self:_createComboCounter()
    self:_createHitCounter()
    self:_createPowerIndicator()
    self:_createCooldownDisplay()
    self:_createNotificationArea()

    -- Listen for server events
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

    local progressionRemote = remotesFolder:WaitForChild(Remotes.ProgressionUpdate)
    progressionRemote.OnClientEvent:Connect(function(data)
        self:_onProgressionUpdate(data)
    end)

    local notifyRemote = remotesFolder:WaitForChild(Remotes.NotifyPlayer)
    notifyRemote.OnClientEvent:Connect(function(data)
        self:showNotification(data.message)
    end)

    local powerEquippedRemote = remotesFolder:WaitForChild(Remotes.PowerEquipped)
    powerEquippedRemote.OnClientEvent:Connect(function(powerId, powerData)
        self:_onPowerEquipped(powerId, powerData)
    end)

    local playerDataRemote = remotesFolder:WaitForChild(Remotes.PlayerDataLoaded)
    playerDataRemote.OnClientEvent:Connect(function(data)
        self:_onDataLoaded(data)
    end)

    local zoneChangedRemote = remotesFolder:WaitForChild(Remotes.ZoneChanged)
    zoneChangedRemote.OnClientEvent:Connect(function(newZone, oldZone)
        self:showNotification("Entered: " .. newZone)
    end)
end

function UIController:_createHealthBar()
    local frame = Instance.new("Frame")
    frame.Name = "HealthBarFrame"
    frame.Size = UDim2.new(0, 300, 0, 30)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = self._screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
    fill.BorderSizePixel = 0
    fill.Parent = frame

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill

    local label = Instance.new("TextLabel")
    label.Name = "HealthText"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = "100/100"
    label.ZIndex = 2
    label.Parent = frame

    self._healthBar = {frame = frame, fill = fill, label = label}

    -- Update health bar on heartbeat
    local player = Players.LocalPlayer
    task.spawn(function()
        while true do
            task.wait(0.1)
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local healthPct = humanoid.Health / humanoid.MaxHealth
                    fill.Size = UDim2.new(healthPct, 0, 1, 0)
                    label.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)

                    -- Color gradient based on health
                    if healthPct > 0.6 then
                        fill.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
                    elseif healthPct > 0.3 then
                        fill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                    else
                        fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    end
                end
            end
        end
    end)
end

function UIController:_createComboCounter()
    local label = Instance.new("TextLabel")
    label.Name = "ComboCounter"
    label.Size = UDim2.new(0, 200, 0, 60)
    label.Position = UDim2.new(0.5, -100, 0, 60)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 200, 50)
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.Fantasy
    label.TextSize = 36
    label.Text = ""
    label.Visible = false
    label.Parent = self._screenGui

    self._comboCounter = label
end

function UIController:_createHitCounter()
    local frame = Instance.new("Frame")
    frame.Name = "HitCounterFrame"
    frame.Size = UDim2.new(0, 150, 0, 60)
    frame.Position = UDim2.new(1, -170, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = self._screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local hitsLabel = Instance.new("TextLabel")
    hitsLabel.Name = "HitsLabel"
    hitsLabel.Size = UDim2.new(1, 0, 0.4, 0)
    hitsLabel.BackgroundTransparency = 1
    hitsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hitsLabel.Font = Enum.Font.GothamBold
    hitsLabel.TextSize = 14
    hitsLabel.Text = "Hits:"
    hitsLabel.Parent = frame

    local countLabel = Instance.new("TextLabel")
    countLabel.Name = "CountLabel"
    countLabel.Size = UDim2.new(1, 0, 0.6, 0)
    countLabel.Position = UDim2.new(0, 0, 0.4, 0)
    countLabel.BackgroundTransparency = 1
    countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    countLabel.Font = Enum.Font.GothamBold
    countLabel.TextSize = 28
    countLabel.Text = "0"
    countLabel.Parent = frame

    self._hitCounter = {frame = frame, label = countLabel}
end

function UIController:_createPowerIndicator()
    local frame = Instance.new("Frame")
    frame.Name = "PowerIndicator"
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(0.5, -100, 1, -50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = self._screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "PowerName"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.Fantasy
    label.TextSize = 22
    label.Text = "Fists"
    label.Parent = frame

    self._powerIndicator = {frame = frame, label = label}
end

function UIController:_createCooldownDisplay()
    local container = Instance.new("Frame")
    container.Name = "CooldownContainer"
    container.Size = UDim2.new(0, 360, 0, 50)
    container.Position = UDim2.new(0.5, -180, 1, -110)
    container.BackgroundTransparency = 1
    container.Parent = self._screenGui

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container

    local slots = {"Q", "E", "R", "T", "Y", "G"}
    for _, slot in ipairs(slots) do
        local slotFrame = Instance.new("Frame")
        slotFrame.Name = "Slot_" .. slot
        slotFrame.Size = UDim2.new(0, 50, 0, 50)
        slotFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        slotFrame.BackgroundTransparency = 0.3
        slotFrame.BorderSizePixel = 0
        slotFrame.Parent = container

        local slotCorner = Instance.new("UICorner")
        slotCorner.CornerRadius = UDim.new(0, 6)
        slotCorner.Parent = slotFrame

        local keyLabel = Instance.new("TextLabel")
        keyLabel.Name = "Key"
        keyLabel.Size = UDim2.new(1, 0, 0.4, 0)
        keyLabel.BackgroundTransparency = 1
        keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        keyLabel.Font = Enum.Font.GothamBold
        keyLabel.TextSize = 12
        keyLabel.Text = slot
        keyLabel.Parent = slotFrame

        local moveLabel = Instance.new("TextLabel")
        moveLabel.Name = "MoveName"
        moveLabel.Size = UDim2.new(1, 0, 0.6, 0)
        moveLabel.Position = UDim2.new(0, 0, 0.4, 0)
        moveLabel.BackgroundTransparency = 1
        moveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        moveLabel.Font = Enum.Font.Gotham
        moveLabel.TextSize = 10
        moveLabel.TextScaled = true
        moveLabel.Text = ""
        moveLabel.Parent = slotFrame

        -- Cooldown overlay
        local cooldownOverlay = Instance.new("Frame")
        cooldownOverlay.Name = "CooldownOverlay"
        cooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
        cooldownOverlay.Position = UDim2.new(0, 0, 1, 0)
        cooldownOverlay.AnchorPoint = Vector2.new(0, 1)
        cooldownOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        cooldownOverlay.BackgroundTransparency = 0.4
        cooldownOverlay.BorderSizePixel = 0
        cooldownOverlay.ZIndex = 2
        cooldownOverlay.Parent = slotFrame

        self._cooldownFrames[slot] = {frame = slotFrame, overlay = cooldownOverlay, moveLabel = moveLabel}
    end
end

function UIController:_createNotificationArea()
    local frame = Instance.new("Frame")
    frame.Name = "NotificationArea"
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Position = UDim2.new(0.5, -200, 0.15, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = self._screenGui

    self._notificationArea = frame
end

function UIController:updateComboCounter(comboCount)
    self._currentCombo = comboCount

    if comboCount > 1 then
        self._comboCounter.Text = comboCount .. " COMBO!"
        self._comboCounter.Visible = true
        self._comboCounter.TextSize = math.min(36 + comboCount * 2, 60)

        -- Flash effect
        self._comboCounter.TextColor3 = Color3.fromRGB(255, 255, 100)
        task.delay(0.1, function()
            if self._comboCounter then
                self._comboCounter.TextColor3 = Color3.fromRGB(255, 200, 50)
            end
        end)
    else
        self._comboCounter.Visible = false
    end

    -- Auto-hide after a delay
    if self._comboResetThread then
        task.cancel(self._comboResetThread)
    end
    self._comboResetThread = task.delay(Constants.COMBO_RESET_TIME, function()
        self._comboCounter.Visible = false
        self._currentCombo = 0
    end)
end

function UIController:showDamageNumber(damage, target)
    if not target or not target.Character then return end

    local head = target.Character:FindFirstChild("Head")
    if not head then return end

    -- Create a BillboardGui damage number
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 80, 0, 40)
    billboard.StudsOffset = Vector3.new(math.random(-2, 2), 3 + math.random(), 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 80, 80)
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20 + math.min(damage, 20)
    label.Text = "-" .. damage
    label.Parent = billboard

    -- Float up and fade
    task.spawn(function()
        for i = 1, 10 do
            task.wait(0.05)
            billboard.StudsOffset = billboard.StudsOffset + Vector3.new(0, 0.3, 0)
            label.TextTransparency = i / 10
            label.TextStrokeTransparency = 0.3 + (i / 10) * 0.7
        end
        billboard:Destroy()
    end)
end

function UIController:cameraShake(intensity)
    intensity = math.clamp(intensity, 0.1, 1)

    task.spawn(function()
        local camera = Workspace.CurrentCamera
        if not camera then return end

        for _ = 1, math.floor(5 * intensity) do
            local offset = CFrame.new(
                math.random(-10, 10) * intensity * 0.05,
                math.random(-10, 10) * intensity * 0.05,
                0
            )
            camera.CFrame = camera.CFrame * offset
            task.wait(0.03)
        end
    end)
end

function UIController:showNotification(message)
    if not self._notificationArea then return end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 40)
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    label.BackgroundTransparency = 0.3
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.Fantasy
    label.TextSize = 20
    label.Text = message
    label.Parent = self._notificationArea

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = label

    -- Fade and remove after a few seconds
    task.delay(3, function()
        local tween = TweenService:Create(label, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
            TextTransparency = 1,
            TextStrokeTransparency = 1,
        })
        tween:Play()
        task.delay(0.5, function()
            label:Destroy()
        end)
    end)
end

function UIController:_onProgressionUpdate(data)
    -- Update hit counter
    if self._hitCounter then
        self._hitCounter.label.Text = tostring(data.totalHits)
    end

    -- Show unlock notifications
    if data.newUnlocks and #data.newUnlocks > 0 then
        for _, powerId in ipairs(data.newUnlocks) do
            self:showNotification("NEW POWER UNLOCKED: " .. powerId)
        end
    end
end

function UIController:_onPowerEquipped(powerId, powerData)
    if self._powerIndicator then
        self._powerIndicator.label.Text = powerData and powerData.name or powerId
        if powerData and powerData.displayColor then
            self._powerIndicator.label.TextColor3 = powerData.displayColor
        end
    end
end

function UIController:_onDataLoaded(data)
    -- Update hit counter
    if self._hitCounter and data.totalHits then
        self._hitCounter.label.Text = tostring(data.totalHits)
    end

    -- Update power indicator
    if self._powerIndicator and data.equippedPower then
        self._powerIndicator.label.Text = data.equippedPower
    end
end

return UIController
