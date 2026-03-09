--[[
    Signal.lua
    Lightweight event/signal utility for internal module communication.
]]

local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    self._nextId = 1
    return self
end

function Signal:Connect(callback)
    local id = self._nextId
    self._nextId = id + 1
    self._connections[id] = callback

    return {
        Disconnect = function()
            self._connections[id] = nil
        end
    }
end

function Signal:Fire(...)
    for _, callback in pairs(self._connections) do
        task.spawn(callback, ...)
    end
end

function Signal:Once(callback)
    local connection
    connection = self:Connect(function(...)
        connection.Disconnect()
        callback(...)
    end)
    return connection
end

function Signal:Wait()
    local thread = coroutine.running()
    self:Once(function(...)
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

function Signal:Destroy()
    self._connections = {}
end

return Signal
