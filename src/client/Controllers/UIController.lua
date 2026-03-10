--[[
    UIController.lua
    Manages all client-side UI: HUD, menus, notifications.
    Enhanced with progression bar, improved damage numbers, and better layout.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

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
    self._progressionBar = nil
    self._cooldownFrames = {}
    self._notificationQueue = {}
    self._currentCombo = 0
    self._comboResetThread = nil
    return self
end

function UIController:init()
    local player = Players.LocalPlayer
    self._playerGui = player:WaitForChild("PlayerGui")

    self._screenGui = Instance.new("ScreenGui")
    self._screenGui.Name = "GameHUD"
    self._screenGui.ResetOnSpawn = false
    self._screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self._screenGui.Parent = self._playerGui

    self:_createHealthBar()
    self:_createComboCounter()
    self:_createHitCounter()
    self:_createProgressionBar()
    self:_createPowerIndicator()
    self:_createCooldownDisplay()
    self:_createNotificationArea()
    self:_createZoneIndicator()

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
        self:_updateZoneIndicator(newZone)
    end)
end

----------------------------------------------
-- HEALTH BAR (top center)
----------------------------------------------
function UIController:_createHealthBar()
    local frame = Instance.new("Frame")
    frame.Name = "HealthBarFrame"
    frame.Size = UDim2.new(0, 320, 0, 32)
    frame.Position = UDim2.new(0.5, -160, 0, 15)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Parent = self._screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- Border stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Parent = frame

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, -4, 1, -4)
    fill.Position = UDim2.new(0, 2, 0, 2)
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
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = "100/100"
    label.ZIndex = 2
    label.Parent = frame

    self._healthBar = {frame = frame, fill = fill, label = label}

    -- Update health bar
    local player = Players.LocalPlayer
    task.spawn(function()
        while true do
            task.wait(0.1)
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local healthPct = humanoid.Health / humanoid.MaxHealth
                    fill.Size = UDim2.new(math.max(healthPct, 0) * (1 - 4/320), -2 + 4, 1, -4)
                    fill.Position = UDim2.new(0, 2, 0, 2)
                    label.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)

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

----------------------------------------------
-- COMBO COUNTER (above health bar)
----------------------------------------------
function UIController:_createComboCounter()
    local label = Instance.new("TextLabel")
    label.Name = "ComboCounter"
    label.Size = UDim2.new(0, 250, 0, 60)
    label.Position = UDim2.new(0.5, -125, 0, 55)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 200, 50)
    label.TextStrokeTransparency = 0.1
    label.TextStrokeColor3 = Color3.fromRGB(100, 50, 0)
    label.Font = Enum.Font.Fantasy
    label.TextSize = 36
    label.Text = ""
    label.Visible = false
    label.Parent = self._screenGui

    self._comboCounter = label
end

----------------------------------------------
-- HIT COUNTER (bottom right)
----------------------------------------------
function UIController:_createHitCounter()
    local frame = Instance.new("Frame")
    frame.Name = "HitCounterFrame"
    frame.Size = UDim2.new(0, 160, 0, 65)
    frame.Position = UDim2.new(1, -175, 1, -85)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = self._screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Parent = frame

    local hitsLabel = Instance.new("TextLabel")
    hitsLabel.Name = "HitsLabel"
    hitsLabel.Size = UDim2.new(1, 0, 0.35, 0)
    hitsLabel.BackgroundTransparency = 1
    hitsLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    hitsLabel.Font = Enum.Font.GothamBold
    hitsLabel.TextSize = 13
    hitsLabel.Text = "TOTAL HITS"
    hitsLabel.Parent = frame

    local countLabel = Instance.new("TextLabel")
    countLabel.Name = "CountLabel"
    countLabel.Size = UDim2.new(1, 0, 0.65, 0)
    countLabel.Position = UDim2.new(0, 0, 0.35, 0)
    countLabel.BackgroundTransparency = 1
    countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    countLabel.Font = Enum.Font.GothamBold
    countLabel.TextSize = 30
    countLabel.Text = "0"
    countLabel.Parent = frame

    self._hitCounter = {frame = frame, label = countLabel}
end

----------------------------------------------
-- PROGRESSION BAR (below hit counter)
----------------------------------------------
function UIController:_createProgressionBar()
    local frame = Instance.new("Frame")
    frame.Name = "ProgressionBarFrame"
    frame.Size = UDim2.new(0, 160, 0, 30)
    frame.Position = UDim2.new(1, -175, 1, -15)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = self._screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, -4)
    fill.Position = UDim2.new(0, 2, 0, 2)
    fill.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    fill.BorderSizePixel = 0
    fill.Parent = frame

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Text = "Next: ???"
    label.ZIndex = 2
    label.Parent = frame

    self._progressionBar = {frame = frame, fill = fill, label = label}
end

----------------------------------------------
-- POWER INDICATOR (bottom center, above cooldowns)
----------------------------------------------
function UIController:_createPowerIndicator()
    local frame = Instance.new("Frame")
    frame.Name = "PowerIndicator"
    frame.Size = UDim2.new(0, 220, 0, 36)
    frame.Position = UDim2.new(0.5, -110, 1, -50)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0.2
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
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.Fantasy
    label.TextSize = 22
    label.Text = "Fists"
    label.Parent = frame

    self._powerIndicator = {frame = frame, label = label}
end

----------------------------------------------
-- COOLDOWN DISPLAY (bottom center)
----------------------------------------------
function UIController:_createCooldownDisplay()
    local container = Instance.new("Frame")
    container.Name = "CooldownContainer"
    container.Size = UDim2.new(0, 360, 0, 55)
    container.Position = UDim2.new(0.5, -180, 1, -115)
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
        slotFrame.Size = UDim2.new(0, 52, 0, 52)
        slotFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        slotFrame.BackgroundTransparency = 0.2
        slotFrame.BorderSizePixel = 0
        slotFrame.Parent = container

        local slotCorner = Instance.new("UICorner")
        slotCorner.CornerRadius = UDim.new(0, 8)
        slotCorner.Parent = slotFrame

        local slotStroke = Instance.new("UIStroke")
        slotStroke.Color = Color3.fromRGB(70, 70, 80)
        slotStroke.Thickness = 1
        slotStroke.Parent = slotFrame

        local keyLabel = Instance.new("TextLabel")
        keyLabel.Name = "Key"
        keyLabel.Size = UDim2.new(1, 0, 0.35, 0)
        keyLabel.BackgroundTransparency = 1
        keyLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
        keyLabel.Font = Enum.Font.GothamBold
        keyLabel.TextSize = 13
        keyLabel.Text = slot
        keyLabel.Parent = slotFrame

        local moveLabel = Instance.new("TextLabel")
        moveLabel.Name = "MoveName"
        moveLabel.Size = UDim2.new(1, -4, 0.65, 0)
        moveLabel.Position = UDim2.new(0, 2, 0.35, 0)
        moveLabel.BackgroundTransparency = 1
        moveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        moveLabel.Font = Enum.Font.Gotham
        moveLabel.TextSize = 10
        moveLabel.TextScaled = true
        moveLabel.Text = ""
        moveLabel.Parent = slotFrame

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

----------------------------------------------
-- NOTIFICATION AREA (top center)
----------------------------------------------
function UIController:_createNotificationArea()
    local frame = Instance.new("Frame")
    frame.Name = "NotificationArea"
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Position = UDim2.new(0.5, -200, 0.12, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = self._screenGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = frame

    self._notificationArea = frame
end

----------------------------------------------
-- ZONE INDICATOR (top left)
----------------------------------------------
function UIController:_createZoneIndicator()
    local label = Instance.new("TextLabel")
    label.Name = "ZoneIndicator"
    label.Size = UDim2.new(0, 200, 0, 30)
    label.Position = UDim2.new(0, 15, 0, 15)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "Magic Hall"
    label.Parent = self._screenGui

    self._zoneIndicator = label
end

----------------------------------------------
-- PUBLIC METHODS
----------------------------------------------
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

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(math.random(-2, 2), 3 + math.random(), 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 80, 80)
    label.TextStrokeTransparency = 0.1
    label.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 22 + math.min(damage, 20)
    label.Text = "-" .. damage
    label.Parent = billboard

    -- Critical hit styling for big damage
    if damage >= 20 then
        label.TextColor3 = Color3.fromRGB(255, 200, 50)
        label.TextStrokeColor3 = Color3.fromRGB(150, 80, 0)
        label.TextSize = label.TextSize + 6
    end

    -- Float up and fade with scale effect
    task.spawn(function()
        for i = 1, 12 do
            task.wait(0.04)
            billboard.StudsOffset = billboard.StudsOffset + Vector3.new(0, 0.35, 0)
            local alpha = i / 12
            label.TextTransparency = alpha
            label.TextStrokeTransparency = 0.1 + alpha * 0.9
            -- Scale down toward end
            if i > 8 then
                label.TextSize = label.TextSize - 2
            end
        end
        billboard:Destroy()
    end)
end

function UIController:cameraShake(intensity)
    intensity = math.clamp(intensity, 0.1, 1)

    task.spawn(function()
        local camera = Workspace.CurrentCamera
        if not camera then return end

        for _ = 1, math.floor(6 * intensity) do
            local offset = CFrame.new(
                math.random(-10, 10) * intensity * 0.04,
                math.random(-10, 10) * intensity * 0.04,
                0
            )
            camera.CFrame = camera.CFrame * offset
            task.wait(0.025)
        end
    end)
end

function UIController:showNotification(message)
    if not self._notificationArea then return end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 36)
    label.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    label.BackgroundTransparency = 0.2
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.Fantasy
    label.TextSize = 18
    label.Text = message
    label.Parent = self._notificationArea

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = label

    -- Slide in effect
    label.Position = UDim2.new(-1, 0, 0, 0)
    TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()

    -- Fade and remove
    task.delay(3.5, function()
        TweenService:Create(label, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
            TextTransparency = 1,
            TextStrokeTransparency = 1,
        }):Play()
        task.delay(0.5, function()
            label:Destroy()
        end)
    end)
end

----------------------------------------------
-- EVENT HANDLERS
----------------------------------------------
function UIController:_onProgressionUpdate(data)
    if self._hitCounter then
        self._hitCounter.label.Text = tostring(data.totalHits)

        -- Flash the hit counter
        self._hitCounter.label.TextColor3 = Color3.fromRGB(255, 255, 100)
        task.delay(0.3, function()
            if self._hitCounter then
                self._hitCounter.label.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
    end

    -- Update progression bar
    if self._progressionBar and data.nextMilestone then
        local milestone = data.nextMilestone
        local progress = 1 - (milestone.hitsRemaining / milestone.hitsNeeded)
        progress = math.clamp(progress, 0, 1)

        self._progressionBar.fill.Size = UDim2.new(progress * (1 - 4/160), 0, 1, -4)
        self._progressionBar.label.Text = "Next: " .. milestone.hitsNeeded .. " hits"
    elseif self._progressionBar then
        self._progressionBar.fill.Size = UDim2.new(1, -4, 1, -4)
        self._progressionBar.label.Text = "All powers unlocked!"
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
    if self._hitCounter and data.totalHits then
        self._hitCounter.label.Text = tostring(data.totalHits)
    end

    if self._powerIndicator and data.equippedPower then
        self._powerIndicator.label.Text = data.equippedPower
    end
end

function UIController:_updateZoneIndicator(zoneName)
    if self._zoneIndicator then
        if zoneName == "Arena" then
            self._zoneIndicator.Text = "Arena"
            self._zoneIndicator.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif zoneName == "MagicHall" then
            self._zoneIndicator.Text = "Magic Hall"
            self._zoneIndicator.TextColor3 = Color3.fromRGB(180, 140, 255)
        else
            self._zoneIndicator.Text = zoneName
            self._zoneIndicator.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
    end

    self:showNotification("Entered: " .. zoneName)
end

return UIController
