--[[
    ZoneConfig.lua
    Defines zone boundaries and rules for each area.
]]

local ZoneConfig = {}

ZoneConfig.Zones = {
    MagicHall = {
        canUsePowers = false,
        canTakeDamage = false,
        canEquipPowers = true,
        canUseFists = false,
        -- Bounding box (center, size)
        center = Vector3.new(0, 25, 0),
        size = Vector3.new(200, 50, 200),
        spawnPoint = CFrame.new(0, 5, 0),
        description = "The Magic Hall - Select your powers here",
    },
    Arena = {
        canUsePowers = true,
        canTakeDamage = true,
        canEquipPowers = false,
        canUseFists = true,
        -- Bounding box (center, size)
        center = Vector3.new(0, 5, 500),
        size = Vector3.new(500, 50, 500),
        spawnPoint = CFrame.new(0, 5, 420),
        description = "The Arena - Fight other players!",
    },
}

-- Check if a position is within a zone
function ZoneConfig.getZoneAtPosition(position)
    for zoneName, zone in pairs(ZoneConfig.Zones) do
        local halfSize = zone.size / 2
        local min = zone.center - halfSize
        local max = zone.center + halfSize
        if position.X >= min.X and position.X <= max.X
            and position.Y >= min.Y and position.Y <= max.Y
            and position.Z >= min.Z and position.Z <= max.Z then
            return zoneName
        end
    end
    return "Unknown"
end

return ZoneConfig
