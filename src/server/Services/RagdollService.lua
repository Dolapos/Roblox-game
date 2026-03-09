--[[
    RagdollService.lua
    Server-side ragdoll system for R6 characters.

    RAGDOLL TIMING (0.8s sweet spot):
    - Light hit stagger: 0.15-0.25s
    - Launcher / slam / heavy hit ragdoll: 0.75-0.9s
    - Special move hard knockdown: 1.0s max
    - Air slam / wall smash: 0.9s

    ANTI-ABUSE:
    - 0.35s get-up protection after recovery
    - Diminishing returns within 2s window:
      * 1st ragdoll: full duration (0.8s)
      * 2nd ragdoll within 2s: reduced (0.5s)
      * 3rd ragdoll within 2s: stagger only, no full ragdoll
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local CombatConfig = require(ReplicatedStorage.Shared.CombatConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RagdollService = {}
RagdollService.__index = RagdollService

function RagdollService.new()
    local self = setmetatable({}, RagdollService)
    self._ragdolledPlayers = {}
    self._immunePlayers = {}
    self._ragdollHistory = {} -- {[Player] = {timestamps}} for diminishing returns
    return self
end

function RagdollService:init()
    game:GetService("Players").PlayerRemoving:Connect(function(player)
        self._ragdolledPlayers[player] = nil
        self._immunePlayers[player] = nil
        self._ragdollHistory[player] = nil
    end)

    task.spawn(function()
        while true do
            task.wait(0.1)
            self:_checkRecoveries()
        end
    end)
end

-- Main ragdoll function with tiered hit types
-- hitType: "Light", "Medium", "Heavy", "Launcher", "Slam", "Special"
function RagdollService:ragdoll(player, comboCount, knockbackForce, knockbackDirection, hitType)
    hitType = hitType or "Heavy"

    if self:isImmune(player) then return false end
    if self._ragdolledPlayers[player] then return false end

    local character = player.Character
    if not character then return false end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    -- Look up hit type config
    local hitConfig = CombatConfig.Ragdoll.hitTypes[hitType]
    if not hitConfig then
        hitConfig = CombatConfig.Ragdoll.hitTypes.Heavy
    end

    local duration = hitConfig.duration

    -- Apply diminishing returns for repeat ragdolls
    local recentCount = self:_getRecentRagdollCount(player)
    local reduction = CombatConfig.Ragdoll.diminishingReductions[recentCount + 1]
    if reduction then
        if reduction <= 0 then
            -- 3rd+ ragdoll within window: stagger only
            self:_applyStagger(player, character, 0.2, knockbackForce, knockbackDirection)
            return true
        end
        duration = duration * reduction
    end

    -- For light staggers, don't do full ragdoll physics
    if hitConfig.isStagger then
        self:_applyStagger(player, character, duration, knockbackForce, knockbackDirection)
        return true
    end

    -- Full ragdoll
    local originalJoints = self:_applyRagdoll(character)
    if not originalJoints then return false end

    if knockbackForce and knockbackDirection then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = knockbackDirection * knockbackForce
            bodyVelocity.Parent = rootPart
            task.delay(0.15, function()
                if bodyVelocity.Parent then bodyVelocity:Destroy() end
            end)
        end
    end

    humanoid.PlatformStand = true

    self._ragdolledPlayers[player] = {
        endTime = tick() + duration,
        originalJoints = originalJoints,
    }

    self:_recordRagdoll(player)

    local ragdollRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.Ragdoll)
    if ragdollRemote then
        ragdollRemote:FireAllClients(player, duration, hitType)
    end

    return true
end

function RagdollService:_applyStagger(player, character, duration, knockbackForce, knockbackDirection)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local originalWalkSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = 0

    if knockbackForce and knockbackDirection then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = knockbackDirection * (knockbackForce * 0.3)
            bodyVelocity.Parent = rootPart
            task.delay(0.1, function()
                if bodyVelocity.Parent then bodyVelocity:Destroy() end
            end)
        end
    end

    local ragdollRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.Ragdoll)
    if ragdollRemote then
        ragdollRemote:FireAllClients(player, duration, "Stagger")
    end

    task.delay(duration, function()
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end)
end

function RagdollService:_getRecentRagdollCount(player)
    local history = self._ragdollHistory[player]
    if not history then return 0 end

    local now = tick()
    local window = CombatConfig.Ragdoll.diminishingWindow
    local count = 0
    for _, timestamp in ipairs(history) do
        if (now - timestamp) <= window then
            count = count + 1
        end
    end
    return count
end

function RagdollService:_recordRagdoll(player)
    if not self._ragdollHistory[player] then
        self._ragdollHistory[player] = {}
    end
    table.insert(self._ragdollHistory[player], tick())

    -- Clean old entries
    local now = tick()
    local window = CombatConfig.Ragdoll.diminishingWindow
    local cleaned = {}
    for _, t in ipairs(self._ragdollHistory[player]) do
        if (now - t) <= window * 2 then
            table.insert(cleaned, t)
        end
    end
    self._ragdollHistory[player] = cleaned
end

function RagdollService:_applyRagdoll(character)
    local originalJoints = {}
    local jointNames = {"Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip", "Neck"}

    for _, jointName in ipairs(jointNames) do
        local joint = character:FindFirstChild(jointName, true)
        if joint and joint:IsA("Motor6D") then
            table.insert(originalJoints, {
                name = jointName, joint = joint, parent = joint.Parent,
                part0 = joint.Part0, part1 = joint.Part1,
                c0 = joint.C0, c1 = joint.C1,
            })

            if joint.Part0 and joint.Part1 then
                local a0 = Instance.new("Attachment")
                a0.Name = "RagdollAttachment0"
                a0.CFrame = joint.C0
                a0.Parent = joint.Part0

                local a1 = Instance.new("Attachment")
                a1.Name = "RagdollAttachment1"
                a1.CFrame = joint.C1
                a1.Parent = joint.Part1

                local bs = Instance.new("BallSocketConstraint")
                bs.Name = "RagdollConstraint"
                bs.Attachment0 = a0
                bs.Attachment1 = a1
                bs.LimitsEnabled = true
                bs.UpperAngle = 45
                bs.Parent = joint.Parent
            end

            joint.Enabled = false
        end
    end

    return #originalJoints > 0 and originalJoints or nil
end

function RagdollService:_removeRagdoll(player)
    local ragdollData = self._ragdolledPlayers[player]
    if not ragdollData then return end

    local character = player.Character
    if not character then
        self._ragdolledPlayers[player] = nil
        return
    end

    for _, jd in ipairs(ragdollData.originalJoints) do
        if jd.joint and jd.joint.Parent then jd.joint.Enabled = true end
        if jd.part0 then
            for _, c in ipairs(jd.part0:GetChildren()) do
                if c.Name == "RagdollAttachment0" then c:Destroy() end
            end
        end
        if jd.part1 then
            for _, c in ipairs(jd.part1:GetChildren()) do
                if c.Name == "RagdollAttachment1" then c:Destroy() end
            end
        end
        if jd.parent then
            for _, c in ipairs(jd.parent:GetChildren()) do
                if c.Name == "RagdollConstraint" then c:Destroy() end
            end
        end
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = false end

    -- Get-up protection (0.35s)
    self._immunePlayers[player] = tick() + CombatConfig.Ragdoll.getUpProtection

    local ragdollEndRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.RagdollEnd)
    if ragdollEndRemote then ragdollEndRemote:FireAllClients(player) end

    self._ragdolledPlayers[player] = nil
end

function RagdollService:_checkRecoveries()
    local now = tick()
    for player, data in pairs(self._ragdolledPlayers) do
        if now >= data.endTime then self:_removeRagdoll(player) end
    end
    for player, endTime in pairs(self._immunePlayers) do
        if now >= endTime then self._immunePlayers[player] = nil end
    end
end

function RagdollService:isRagdolled(player)
    return self._ragdolledPlayers[player] ~= nil
end

function RagdollService:isImmune(player)
    local endTime = self._immunePlayers[player]
    return endTime and tick() < endTime
end

return RagdollService
