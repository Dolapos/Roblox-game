--[[
    Remotes.lua
    Single source of truth for all RemoteEvent/RemoteFunction names.
    Server creates these at startup; both client and server import this.
]]

local Remotes = {
    -- Combat
    CastMove = "CastMove",               -- Client -> Server: request to cast a move
    FistAttack = "FistAttack",            -- Client -> Server: fist combo input
    CombatEvent = "CombatEvent",          -- Server -> All Clients: hit/damage/VFX events

    -- Power Management
    EquipPower = "EquipPower",            -- Client -> Server: request to equip a power
    PowerEquipped = "PowerEquipped",      -- Server -> Client: confirm power equipped
    UnequipPower = "UnequipPower",        -- Client -> Server: request to unequip

    -- Progression
    ProgressionUpdate = "ProgressionUpdate", -- Server -> Client: hit count / unlock updates
    RequestProgression = "RequestProgression", -- Client -> Server: request current progression

    -- Zone
    ZoneChanged = "ZoneChanged",          -- Server -> Client: player entered new zone

    -- Ragdoll
    Ragdoll = "Ragdoll",                  -- Server -> Client: start ragdoll
    RagdollEnd = "RagdollEnd",            -- Server -> Client: end ragdoll

    -- UI
    ShowPowerSelect = "ShowPowerSelect",  -- Server -> Client: open power selection UI
    NotifyPlayer = "NotifyPlayer",        -- Server -> Client: show notification message

    -- Data
    PlayerDataLoaded = "PlayerDataLoaded", -- Server -> Client: initial data sync
}

return Remotes
