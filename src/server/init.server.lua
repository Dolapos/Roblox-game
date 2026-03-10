--[[
    Server Bootstrap
    Initializes all server-side services and creates RemoteEvents.
    This is the main server script that runs on game start.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for shared modules to be available
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Data = ReplicatedStorage:WaitForChild("Data")

local Remotes = require(Shared.Remotes)

----------------------------------------------
-- 1. Create all RemoteEvents/RemoteFunctions
----------------------------------------------
print("[Server] Creating RemoteEvents...")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

for _, remoteName in pairs(Remotes) do
    if not remotesFolder:FindFirstChild(remoteName) then
        local remote = Instance.new("RemoteEvent")
        remote.Name = remoteName
        remote.Parent = remotesFolder
    end
end

print("[Server] RemoteEvents created.")

----------------------------------------------
-- 2. Lighting & Atmosphere
----------------------------------------------
print("[Server] Applying lighting...")

local LightingSetup = require(script.LightingSetup)
LightingSetup.apply()

----------------------------------------------
-- 3. Build the Map
----------------------------------------------
print("[Server] Building map...")

local MapBuilder = require(script.MapBuilder)
MapBuilder.buildMagicHall()
MapBuilder.buildArena()
MapBuilder.buildPedestalDisplay()

print("[Server] Map built.")

----------------------------------------------
-- 3. Initialize R6 Character Setup
----------------------------------------------
print("[Server] Setting up R6 characters...")

local CharacterSetup = require(script.R6.CharacterSetup)
local characterSetup = CharacterSetup.new()
characterSetup:init()

----------------------------------------------
-- 4. Initialize Services
----------------------------------------------
print("[Server] Initializing services...")

-- Data Service (must be first - other services depend on it)
local DataService = require(script.Services.DataService)
local dataService = DataService.new()
dataService:init()

-- Zone Manager
local ZoneManager = require(script.Services.ZoneManager)
local zoneManager = ZoneManager.new()
zoneManager:init()

-- Power Manager
local PowerManager = require(script.Services.PowerManager)
local powerManager = PowerManager.new(dataService, zoneManager)
powerManager:init()

-- Ragdoll Service
local RagdollService = require(script.Services.RagdollService)
local ragdollService = RagdollService.new()
ragdollService:init()

-- Progression Service
local ProgressionService = require(script.Services.ProgressionService)
local progressionService = ProgressionService.new(dataService)
progressionService:init()

-- Combat Service (depends on all above)
local CombatService = require(script.Services.CombatService)
local combatService = CombatService.new(zoneManager, powerManager, ragdollService, progressionService, dataService)
combatService:init()

-- Teleport Service
local TeleportService = require(script.Services.TeleportService)
local teleportService = TeleportService.new()
teleportService:init()

-- Power Visuals Service (character cosmetics based on equipped power)
local PowerVisualsService = require(script.Services.PowerVisualsService)
local powerVisualsService = PowerVisualsService.new()
powerVisualsService:init()

-- NPC Boss Service (boss spawns, orb drops, world events)
local NPCBossService = require(script.Services.NPCBossService)
local npcBossService = NPCBossService.new(dataService, progressionService)
npcBossService:init()

----------------------------------------------
-- 5. Handle Player Data Sync
----------------------------------------------
local playerDataRemote = remotesFolder:FindFirstChild(Remotes.PlayerDataLoaded)
local requestProgressionRemote = remotesFolder:FindFirstChild(Remotes.RequestProgression)

-- When player requests their progression data
if requestProgressionRemote then
    requestProgressionRemote.OnServerEvent:Connect(function(player)
        local progression = progressionService:getPlayerProgression(player)
        if playerDataRemote then
            playerDataRemote:FireClient(player, progression)
        end
    end)
end

-- Send data to player on join
Players.PlayerAdded:Connect(function(player)
    -- Wait a moment for data to load
    task.wait(1)
    local progression = progressionService:getPlayerProgression(player)
    if playerDataRemote then
        playerDataRemote:FireClient(player, progression)
    end
end)

-- Cleanup on player leave
Players.PlayerRemoving:Connect(function(player)
    powerManager:onPlayerRemoved(player)
end)

----------------------------------------------
-- 6. Admin Commands (dev only)
----------------------------------------------
local ADMIN_IDS = {} -- Add your Roblox UserId(s) here, e.g. {123456789}

local function isAdmin(player)
    if #ADMIN_IDS == 0 then
        -- No IDs set: allow all in Studio, block in live server
        return game:GetService("RunService"):IsStudio()
    end
    for _, id in ipairs(ADMIN_IDS) do
        if player.UserId == id then return true end
    end
    return false
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        if not isAdmin(player) then return end

        local amount = tonumber(msg:match("^/givehits%s+(%d+)$"))
        if amount then
            progressionService:setHits(player, amount)
            print(("[Admin] Set %s hits to %d"):format(player.Name, amount))
        end
    end)
end)

print("[Server] All services initialized. Game is ready!")
