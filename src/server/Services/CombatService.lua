--[[
    CombatService.lua
    Central combat orchestrator. Handles:
    - Receiving combat inputs from clients
    - Validating moves (zone, cooldown, state)
    - Executing hitbox detection
    - Applying damage and effects
    - Triggering ragdoll
    - Tracking combos
    - Notifying clients of combat events
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local CombatConfig = require(ReplicatedStorage.Shared.CombatConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local BalanceTable = require(ReplicatedStorage.Data.BalanceTable)

local CombatService = {}
CombatService.__index = CombatService

function CombatService.new(zoneManager, powerManager, ragdollService, progressionService, dataService)
    local self = setmetatable({}, CombatService)
    self._zoneManager = zoneManager
    self._powerManager = powerManager
    self._ragdollService = ragdollService
    self._progressionService = progressionService
    self._dataService = dataService

    -- Per-player state
    self._cooldowns = {} -- {[Player] = {[moveId] = endTime}}
    self._globalCooldowns = {} -- {[Player] = endTime}
    self._comboCounts = {} -- {[Player] = {target = Player, count = number, lastHitTime = number}}
    self._fistComboState = {} -- {[Player] = {index = 1-3, lastSwingTime = number}}
    self._combatStates = {} -- {[Player] = "Idle"|"Attacking"|"Casting"}
    self._lastDamageTaken = {} -- {[Player] = time}

    return self
end

function CombatService:init()
    -- Listen for move cast requests
    local castMoveRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.CastMove)
    if castMoveRemote then
        castMoveRemote.OnServerEvent:Connect(function(player, slot)
            self:_onCastMove(player, slot)
        end)
    end

    -- Listen for fist attacks (M1)
    local fistRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.FistAttack)
    if fistRemote then
        fistRemote.OnServerEvent:Connect(function(player)
            self:_onFistAttack(player)
        end)
    end

    -- Cleanup on player leave
    Players.PlayerRemoving:Connect(function(player)
        self._cooldowns[player] = nil
        self._globalCooldowns[player] = nil
        self._comboCounts[player] = nil
        self._fistComboState[player] = nil
        self._combatStates[player] = nil
        self._lastDamageTaken[player] = nil
    end)

    -- Health regen loop
    task.spawn(function()
        while true do
            task.wait(1)
            self:_healthRegenTick()
        end
    end)
end

function CombatService:_onCastMove(player, slot)
    -- Validate slot
    if not table.find(Constants.MOVE_SLOTS, slot) then return end

    -- Check if player is in arena
    if not self._zoneManager:canPlayerUsePowers(player) then return end

    -- Check if player is ragdolled or attacking
    if self._ragdollService:isRagdolled(player) then return end
    if self._combatStates[player] == "Attacking" or self._combatStates[player] == "Casting" then return end

    -- Check global cooldown
    if self:_isOnGlobalCooldown(player) then return end

    -- Get the move for this slot
    local moveDef = self._powerManager:getMoveForSlot(player, slot)
    if not moveDef then return end

    -- Check move-specific cooldown
    if self:_isOnCooldown(player, moveDef.id) then return end

    -- Execute the move
    self:_executePowerMove(player, moveDef)
end

function CombatService:_onFistAttack(player)
    -- Check if player is in arena
    if not self._zoneManager:canPlayerUsePowers(player) then return end

    -- Check if player is ragdolled
    if self._ragdollService:isRagdolled(player) then return end
    if self._combatStates[player] == "Attacking" then return end

    -- Check global cooldown
    if self:_isOnGlobalCooldown(player) then return end

    -- Get fist combo state
    local comboState = self._fistComboState[player]
    if not comboState then
        comboState = {index = 1, lastSwingTime = 0}
        self._fistComboState[player] = comboState
    end

    -- Check if combo has expired
    local now = tick()
    if (now - comboState.lastSwingTime) > CombatConfig.Fists.comboResetTime then
        comboState.index = 1
    end

    -- Check fist combo cooldown
    local cooldownTime = CombatConfig.Fists.comboCooldown
    if comboState.index > #CombatConfig.Fists.combo then
        -- Full combo completed, use longer cooldown
        cooldownTime = CombatConfig.Fists.fullComboCooldown
        comboState.index = 1
    end

    if (now - comboState.lastSwingTime) < cooldownTime then return end

    -- Get current combo hit data
    local hitData = CombatConfig.Fists.combo[comboState.index]
    if not hitData then
        comboState.index = 1
        hitData = CombatConfig.Fists.combo[1]
    end

    -- Execute the fist hit
    self:_executeFistHit(player, hitData, comboState.index)

    -- Advance combo
    comboState.index = comboState.index + 1
    comboState.lastSwingTime = now

    -- Apply global cooldown
    self:_setGlobalCooldown(player)
end

function CombatService:_executeFistHit(player, hitData, comboIndex)
    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    self._combatStates[player] = "Attacking"

    -- Get fist damage multiplier based on progression
    local totalHits = self._dataService:getTotalHits(player)
    local fistMultiplier = BalanceTable.getFistMultiplier(totalHits)

    -- Create hitbox in front of player
    local hitboxOrigin = rootPart.CFrame * CFrame.new(0, 0, -hitData.range / 2)
    local hitPlayers = self:_checkHitbox(player, hitboxOrigin.Position, hitData.hitboxSize)

    -- Fire combat event for animations/VFX
    local combatRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.CombatEvent)
    if combatRemote then
        combatRemote:FireAllClients({
            type = "FistAttack",
            caster = player,
            comboIndex = comboIndex,
            hitName = hitData.name,
            origin = rootPart.Position,
            direction = rootPart.CFrame.LookVector,
        })
    end

    -- Apply damage to hit players
    for _, targetPlayer in ipairs(hitPlayers) do
        local damage = math.floor(hitData.damage * fistMultiplier)
        damage = math.min(damage, BalanceTable.MAX_SINGLE_HIT_DAMAGE)

        local comboCount = self:_getComboCount(player, targetPlayer)

        self:_applyDamage(player, targetPlayer, damage)
        self:_registerHit(player, targetPlayer)

        -- Tiered stagger/ragdoll: light jabs stagger, uppercut launches
        local staggerType = hitData.staggerType or "Light"
        local knockbackDir = rootPart.CFrame.LookVector
        if hitData.name == "Uppercut" then
            knockbackDir = (rootPart.CFrame.LookVector + Vector3.new(0, 1, 0)).Unit
        end
        self._ragdollService:ragdoll(targetPlayer, comboCount, hitData.knockback, knockbackDir, staggerType)

        -- Notify clients of hit
        if combatRemote then
            combatRemote:FireAllClients({
                type = "Hit",
                caster = player,
                target = targetPlayer,
                damage = damage,
                comboCount = comboCount + 1,
                knockback = hitData.knockback,
            })
        end
    end

    -- Recovery time
    task.delay(hitData.duration or 0.25, function()
        if self._combatStates[player] == "Attacking" then
            self._combatStates[player] = "Idle"
        end
    end)
end

function CombatService:_executePowerMove(player, moveDef)
    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    self._combatStates[player] = "Casting"

    -- Start cooldown
    self:_setCooldown(player, moveDef.id, moveDef.cooldown)
    self:_setGlobalCooldown(player)

    -- Determine hitbox position
    local hitboxPos
    if moveDef.isGroundTarget then
        -- Ground target: hitbox at a point in front
        hitboxPos = rootPart.Position + rootPart.CFrame.LookVector * (moveDef.range * 0.6)
    elseif moveDef.isDash then
        -- Dash: move the player forward and check along the path
        hitboxPos = rootPart.Position + rootPart.CFrame.LookVector * (moveDef.dashDistance / 2)
    else
        -- Default: hitbox in front of player
        hitboxPos = rootPart.Position + rootPart.CFrame.LookVector * (moveDef.range / 2)
    end

    -- Get tier multiplier for damage
    local powerData = self._powerManager:getEquippedPowerData(player)
    local tierMult = CombatConfig.DamageScaling.tierMultiplier[powerData and powerData.tier or 0] or 1.0

    -- Fire combat event for animations/VFX (cast start)
    local combatRemote = ReplicatedStorage.Remotes:FindFirstChild(Remotes.CombatEvent)
    if combatRemote then
        combatRemote:FireAllClients({
            type = "MoveStart",
            caster = player,
            moveId = moveDef.id,
            moveName = moveDef.name,
            origin = rootPart.Position,
            direction = rootPart.CFrame.LookVector,
            slot = moveDef.slot,
        })
    end

    -- Cast time delay
    task.delay(moveDef.castTime, function()
        if not character.Parent then return end
        if self._ragdollService:isRagdolled(player) then
            self._combatStates[player] = "Idle"
            return
        end

        -- Handle dash movement
        if moveDef.isDash and rootPart.Parent then
            local dashTarget = rootPart.Position + rootPart.CFrame.LookVector * moveDef.dashDistance
            rootPart.CFrame = CFrame.new(dashTarget, dashTarget + rootPart.CFrame.LookVector)
        end

        -- Self-launch (e.g., blast jump)
        if moveDef.selfLaunch and rootPart.Parent then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, moveDef.launchForce or 40, 0)
            bodyVelocity.Parent = rootPart
            task.delay(0.2, function()
                if bodyVelocity.Parent then bodyVelocity:Destroy() end
            end)
        end

        -- Recalculate hitbox position after dash
        if moveDef.isDash and rootPart.Parent then
            hitboxPos = rootPart.Position
        end

        -- Check hitbox
        local hitPlayers = self:_checkHitbox(player, hitboxPos, moveDef.hitboxSize)

        -- Apply damage and effects
        for _, targetPlayer in ipairs(hitPlayers) do
            local damage = math.floor(moveDef.baseDamage * tierMult)
            local comboCount = self:_getComboCount(player, targetPlayer)

            -- Apply combo multiplier
            local comboMult = CombatConfig.DamageScaling.comboMultiplier[math.min(comboCount + 1, 5)]
                or CombatConfig.DamageScaling.maxComboMultiplier
            damage = math.floor(damage * comboMult)
            damage = math.min(damage, BalanceTable.MAX_SINGLE_HIT_DAMAGE)

            -- Life steal
            if moveDef.lifeSteal then
                local healAmount = math.floor(damage * moveDef.lifeSteal)
                local casterHumanoid = character:FindFirstChildOfClass("Humanoid")
                if casterHumanoid then
                    casterHumanoid.Health = math.min(casterHumanoid.Health + healAmount, casterHumanoid.MaxHealth)
                end
            end

            self:_applyDamage(player, targetPlayer, damage)
            self:_registerHit(player, targetPlayer)

            -- Ragdoll if move causes it (use move's staggerType for tiered system)
            if moveDef.causeRagdoll then
                local knockbackDir = moveDef.knockbackDirection or rootPart.CFrame.LookVector
                local hitType = moveDef.staggerType or "Heavy"
                self._ragdollService:ragdoll(targetPlayer, comboCount, moveDef.knockback, knockbackDir, hitType)
            elseif moveDef.staggerType == "Light" then
                local knockbackDir = moveDef.knockbackDirection or rootPart.CFrame.LookVector
                self._ragdollService:ragdoll(targetPlayer, comboCount, moveDef.knockback or 5, knockbackDir, "Light")
            end

            -- Hit event
            if combatRemote then
                combatRemote:FireAllClients({
                    type = "Hit",
                    caster = player,
                    target = targetPlayer,
                    damage = damage,
                    comboCount = comboCount + 1,
                    moveId = moveDef.id,
                    damageType = moveDef.damageType,
                })
            end
        end

        -- Fire move executed event
        if combatRemote then
            combatRemote:FireAllClients({
                type = "MoveExecuted",
                caster = player,
                moveId = moveDef.id,
                origin = hitboxPos,
                direction = rootPart.CFrame.LookVector,
            })
        end
    end)

    -- Recovery time
    task.delay(moveDef.castTime + moveDef.recoveryTime, function()
        if self._combatStates[player] == "Casting" then
            self._combatStates[player] = "Idle"
        end
    end)
end

function CombatService:_checkHitbox(caster, position, size)
    local hitPlayers = {}
    local halfSize = size / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= caster and self._zoneManager:canPlayerTakeDamage(player) then
            local targetCharacter = player.Character
            if targetCharacter then
                local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local diff = targetRoot.Position - position
                    if math.abs(diff.X) <= halfSize.X + 2
                        and math.abs(diff.Y) <= halfSize.Y + 2
                        and math.abs(diff.Z) <= halfSize.Z + 2 then
                        table.insert(hitPlayers, player)
                    end
                end
            end
        end
    end

    return hitPlayers
end

function CombatService:_applyDamage(attacker, target, damage)
    local targetChar = target.Character
    if not targetChar then return end

    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    humanoid:TakeDamage(damage)
    self._lastDamageTaken[target] = tick()
end

function CombatService:_registerHit(attacker, target)
    -- Update combo count
    local combo = self._comboCounts[attacker]
    local now = tick()

    if not combo or combo.target ~= target or (now - combo.lastHitTime) > Constants.COMBO_WINDOW then
        self._comboCounts[attacker] = {
            target = target,
            count = 1,
            lastHitTime = now,
        }
    else
        combo.count = math.min(combo.count + 1, Constants.MAX_COMBO_COUNT)
        combo.lastHitTime = now
    end

    -- Register progression hit
    self._progressionService:registerHit(attacker)
end

function CombatService:_getComboCount(attacker, target)
    local combo = self._comboCounts[attacker]
    if combo and combo.target == target and (tick() - combo.lastHitTime) <= Constants.COMBO_WINDOW then
        return combo.count
    end
    return 0
end

function CombatService:_isOnCooldown(player, moveId)
    local cooldowns = self._cooldowns[player]
    if not cooldowns then return false end
    local endTime = cooldowns[moveId]
    return endTime and tick() < endTime
end

function CombatService:_setCooldown(player, moveId, duration)
    if not self._cooldowns[player] then
        self._cooldowns[player] = {}
    end
    self._cooldowns[player][moveId] = tick() + duration
end

function CombatService:_isOnGlobalCooldown(player)
    local endTime = self._globalCooldowns[player]
    return endTime and tick() < endTime
end

function CombatService:_setGlobalCooldown(player)
    self._globalCooldowns[player] = tick() + Constants.GLOBAL_COOLDOWN
end

function CombatService:_healthRegenTick()
    local now = tick()
    for _, player in ipairs(Players:GetPlayers()) do
        if self._zoneManager:isPlayerInArena(player) then
            local lastDamage = self._lastDamageTaken[player] or 0
            if (now - lastDamage) >= BalanceTable.ARENA_REGEN_DELAY then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth then
                        humanoid.Health = math.min(humanoid.Health + BalanceTable.ARENA_REGEN_RATE, humanoid.MaxHealth)
                    end
                end
            end
        end
    end
end

return CombatService
