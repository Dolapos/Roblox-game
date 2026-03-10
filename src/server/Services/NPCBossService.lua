--[[
    NPCBossService.lua
    Manages boss spawns, world events, and NPC interactions in the arena.
    - Boss spawns every 25 minutes in the center arena
    - Orb drops that grant bonus hits
    - Players earn hits by damaging bosses
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local NPCBossService = {}
NPCBossService.__index = NPCBossService

-- Boss configuration
local BOSS_CONFIG = {
    spawnInterval = 25 * 60, -- 25 minutes in seconds
    spawnPosition = Vector3.new(0, 5, 500), -- Arena center
    bossHealth = 1000,
    bossSize = Vector3.new(8, 12, 8),
    bossDamage = 15,
    bossAttackRange = 15,
    bossAttackCooldown = 2,
    hitsPerDamage = 2, -- bonus hits per damage dealt to boss
    killReward = 50, -- bonus hits for killing blow
    participationReward = 10, -- bonus hits for any participant
}

-- Orb drop configuration
local ORB_CONFIG = {
    spawnInterval = 180, -- 3 minutes
    hitsReward = 5,
    lifetime = 30, -- seconds before despawn
    spawnRadius = 200,
    arenaCenter = Vector3.new(0, 3, 500),
}

function NPCBossService.new(dataService, progressionService)
    local self = setmetatable({}, NPCBossService)
    self._dataService = dataService
    self._progressionService = progressionService
    self._currentBoss = nil
    self._bossHealth = 0
    self._bossDamageTracker = {} -- {[Player] = totalDamage}
    self._lastBossAttack = 0
    self._notifyRemote = nil
    return self
end

function NPCBossService:init()
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if remotesFolder then
        self._notifyRemote = remotesFolder:FindFirstChild(Remotes.NotifyPlayer)
    end

    -- Start boss spawn loop
    task.spawn(function()
        -- Wait a bit before first spawn
        task.wait(60)
        while true do
            self:_spawnBoss()
            task.wait(BOSS_CONFIG.spawnInterval)
        end
    end)

    -- Start orb drop loop
    task.spawn(function()
        task.wait(30)
        while true do
            self:_spawnOrb()
            task.wait(ORB_CONFIG.spawnInterval)
        end
    end)

    -- Cleanup on player leave
    Players.PlayerRemoving:Connect(function(player)
        self._bossDamageTracker[player] = nil
    end)
end

----------------------------------------------
-- BOSS SYSTEM
----------------------------------------------
function NPCBossService:_spawnBoss()
    if self._currentBoss then return end

    -- Notify all players
    self:_notifyAll("A BOSS has appeared in the Arena center!")

    local bossFolder = Instance.new("Folder")
    bossFolder.Name = "Boss"
    bossFolder.Parent = Workspace

    -- Boss body
    local body = Instance.new("Part")
    body.Name = "BossBody"
    body.Size = BOSS_CONFIG.bossSize
    body.Position = BOSS_CONFIG.spawnPosition
    body.Anchored = true
    body.CanCollide = true
    body.Color = Color3.fromRGB(80, 20, 20)
    body.Material = Enum.Material.Neon
    body.Parent = bossFolder

    -- Boss glow
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 50, 50)
    light.Brightness = 4
    light.Range = 30
    light.Parent = body

    -- Boss particles
    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50), Color3.fromRGB(200, 0, 0))
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    particles.Lifetime = NumberRange.new(0.5, 1.5)
    particles.Rate = 40
    particles.Speed = NumberRange.new(3, 8)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.LightEmission = 1
    particles.Parent = body

    -- Health bar billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 8, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = body

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Font = Enum.Font.Fantasy
    nameLabel.TextSize = 18
    nameLabel.Text = "ARENA BOSS"
    nameLabel.Parent = billboard

    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBg"
    healthBg.Size = UDim2.new(1, 0, 0.3, 0)
    healthBg.Position = UDim2.new(0, 0, 0.5, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = billboard

    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg

    self._currentBoss = bossFolder
    self._bossHealth = BOSS_CONFIG.bossHealth
    self._bossDamageTracker = {}

    -- Boss hitbox detection loop
    task.spawn(function()
        self:_bossAILoop(body, healthFill)
    end)
end

function NPCBossService:_bossAILoop(body, healthFill)
    while self._currentBoss and self._bossHealth > 0 do
        task.wait(0.5)

        if not body.Parent then break end

        -- Check nearby players and deal damage
        local now = tick()
        if (now - self._lastBossAttack) >= BOSS_CONFIG.bossAttackCooldown then
            for _, player in ipairs(Players:GetPlayers()) do
                local character = player.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 then
                        local dist = (rootPart.Position - body.Position).Magnitude
                        if dist <= BOSS_CONFIG.bossAttackRange then
                            humanoid:TakeDamage(BOSS_CONFIG.bossDamage)
                            self._lastBossAttack = now

                            -- Knockback
                            local dir = (rootPart.Position - body.Position).Unit
                            local bv = Instance.new("BodyVelocity")
                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bv.Velocity = dir * 30 + Vector3.new(0, 15, 0)
                            bv.Parent = rootPart
                            task.delay(0.15, function()
                                if bv.Parent then bv:Destroy() end
                            end)
                        end
                    end
                end
            end
        end

        -- Check if players are hitting the boss (proximity-based damage from fists/abilities)
        -- This is simplified - real implementation would hook into CombatService
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local dist = (rootPart.Position - body.Position).Magnitude
                    if dist <= 8 then
                        -- Player is close enough to be attacking
                        -- Boss takes damage proportional to proximity (simplified)
                    end
                end
            end
        end

        -- Update health bar
        if healthFill and healthFill.Parent then
            healthFill.Size = UDim2.new(self._bossHealth / BOSS_CONFIG.bossHealth, 0, 1, 0)
        end
    end
end

function NPCBossService:damageBoss(player, damage)
    if not self._currentBoss or self._bossHealth <= 0 then return end

    self._bossHealth = self._bossHealth - damage
    self._bossDamageTracker[player] = (self._bossDamageTracker[player] or 0) + damage

    -- Award hits for damaging boss
    local bonusHits = math.floor(damage / 10) * BOSS_CONFIG.hitsPerDamage
    if bonusHits > 0 then
        self._progressionService:setHits(
            player,
            self._dataService:getTotalHits(player) + bonusHits
        )
    end

    if self._bossHealth <= 0 then
        self:_onBossDefeated(player)
    end
end

function NPCBossService:_onBossDefeated(killer)
    self:_notifyAll("The BOSS has been defeated by " .. killer.Name .. "!")

    -- Award kill reward
    self._progressionService:setHits(
        killer,
        self._dataService:getTotalHits(killer) + BOSS_CONFIG.killReward
    )

    -- Award participation reward
    for player, _ in pairs(self._bossDamageTracker) do
        if player ~= killer and player.Parent then
            self._progressionService:setHits(
                player,
                self._dataService:getTotalHits(player) + BOSS_CONFIG.participationReward
            )
        end
    end

    -- Cleanup
    if self._currentBoss then
        self._currentBoss:Destroy()
        self._currentBoss = nil
    end
    self._bossDamageTracker = {}
end

----------------------------------------------
-- ORB DROP SYSTEM
----------------------------------------------
function NPCBossService:_spawnOrb()
    local angle = math.random() * math.pi * 2
    local dist = math.random(20, ORB_CONFIG.spawnRadius)
    local x = math.cos(angle) * dist
    local z = math.sin(angle) * dist

    local orbPos = ORB_CONFIG.arenaCenter + Vector3.new(x, 3, z)

    local orb = Instance.new("Part")
    orb.Name = "HitOrb"
    orb.Size = Vector3.new(3, 3, 3)
    orb.Position = orbPos
    orb.Shape = Enum.PartType.Ball
    orb.Anchored = true
    orb.CanCollide = false
    orb.Color = Color3.fromRGB(255, 220, 50)
    orb.Material = Enum.Material.Neon
    orb.Parent = Workspace

    local orbLight = Instance.new("PointLight")
    orbLight.Color = Color3.fromRGB(255, 220, 50)
    orbLight.Brightness = 3
    orbLight.Range = 15
    orbLight.Parent = orb

    local orbParticles = Instance.new("ParticleEmitter")
    orbParticles.Color = ColorSequence.new(Color3.fromRGB(255, 220, 50), Color3.fromRGB(255, 180, 0))
    orbParticles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    orbParticles.Lifetime = NumberRange.new(0.5, 1)
    orbParticles.Rate = 15
    orbParticles.Speed = NumberRange.new(1, 3)
    orbParticles.SpreadAngle = Vector2.new(180, 180)
    orbParticles.LightEmission = 1
    orbParticles.Parent = orb

    -- Billboard
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = orb

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 220, 50)
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = "+" .. ORB_CONFIG.hitsReward .. " Hits"
    label.Parent = bb

    -- Touch detection
    orb.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player and orb.Parent then
            -- Award hits
            self._progressionService:setHits(
                player,
                self._dataService:getTotalHits(player) + ORB_CONFIG.hitsReward
            )

            -- Notify
            if self._notifyRemote then
                self._notifyRemote:FireClient(player, {
                    type = "OrbCollected",
                    message = "+" .. ORB_CONFIG.hitsReward .. " Hits!",
                })
            end

            orb:Destroy()
        end
    end)

    -- Auto-despawn
    task.delay(ORB_CONFIG.lifetime, function()
        if orb.Parent then
            orb:Destroy()
        end
    end)

    self:_notifyAll("A Hit Orb has appeared in the Arena!")
end

----------------------------------------------
-- HELPERS
----------------------------------------------
function NPCBossService:_notifyAll(message)
    if not self._notifyRemote then return end
    for _, player in ipairs(Players:GetPlayers()) do
        self._notifyRemote:FireClient(player, {
            type = "WorldEvent",
            message = message,
        })
    end
end

return NPCBossService
