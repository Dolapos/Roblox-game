--[[
    MathUtil.lua
    Common math utility functions.
]]

local MathUtil = {}

function MathUtil.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function MathUtil.lerp(a, b, t)
    return a + (b - a) * t
end

function MathUtil.inverseLerp(a, b, value)
    if a == b then return 0 end
    return (value - a) / (b - a)
end

function MathUtil.roundTo(value, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(value * mult + 0.5) / mult
end

function MathUtil.randomFloat(min, max)
    return min + math.random() * (max - min)
end

function MathUtil.randomVector3(minMagnitude, maxMagnitude)
    local direction = Vector3.new(
        math.random() - 0.5,
        math.random() - 0.5,
        math.random() - 0.5
    ).Unit
    local magnitude = MathUtil.randomFloat(minMagnitude, maxMagnitude)
    return direction * magnitude
end

function MathUtil.getDirectionBetween(from, to)
    local diff = to - from
    if diff.Magnitude < 0.001 then
        return Vector3.new(0, 0, -1)
    end
    return diff.Unit
end

function MathUtil.isWithinDistance(pos1, pos2, distance)
    return (pos1 - pos2).Magnitude <= distance
end

function MathUtil.flatDistance(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dz = pos1.Z - pos2.Z
    return math.sqrt(dx * dx + dz * dz)
end

return MathUtil
