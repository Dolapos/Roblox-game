--[[
    TableUtil.lua
    Common table utility functions.
]]

local TableUtil = {}

function TableUtil.deepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = TableUtil.deepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function TableUtil.merge(base, override)
    local result = TableUtil.deepCopy(base)
    for key, value in pairs(override) do
        if type(value) == "table" and type(result[key]) == "table" then
            result[key] = TableUtil.merge(result[key], value)
        else
            result[key] = value
        end
    end
    return result
end

function TableUtil.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function TableUtil.keys(tbl)
    local result = {}
    for key in pairs(tbl) do
        table.insert(result, key)
    end
    return result
end

function TableUtil.values(tbl)
    local result = {}
    for _, value in pairs(tbl) do
        table.insert(result, value)
    end
    return result
end

function TableUtil.filter(tbl, predicate)
    local result = {}
    for _, value in ipairs(tbl) do
        if predicate(value) then
            table.insert(result, value)
        end
    end
    return result
end

function TableUtil.map(tbl, transform)
    local result = {}
    for i, value in ipairs(tbl) do
        result[i] = transform(value, i)
    end
    return result
end

function TableUtil.count(tbl)
    local n = 0
    for _ in pairs(tbl) do
        n = n + 1
    end
    return n
end

return TableUtil
