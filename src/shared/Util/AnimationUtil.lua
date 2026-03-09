--[[
    AnimationUtil.lua
    Utility for loading and playing animations on R6 characters.
]]

local AnimationUtil = {}

-- Cache for loaded animation tracks per humanoid
local animationCache = {}

function AnimationUtil.loadAnimation(humanoid, animationId)
    if not humanoid or not humanoid.Parent then return nil end

    local key = tostring(humanoid) .. "_" .. animationId
    if animationCache[key] then
        return animationCache[key]
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = animationId

    local success, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)

    if success and track then
        animationCache[key] = track
        return track
    end

    return nil
end

function AnimationUtil.playAnimation(humanoid, animationId, properties)
    local track = AnimationUtil.loadAnimation(humanoid, animationId)
    if not track then return nil end

    properties = properties or {}

    if properties.priority then
        track.Priority = properties.priority
    end

    if properties.speed then
        track:AdjustSpeed(properties.speed)
    end

    if properties.weight then
        track:AdjustWeight(properties.weight)
    end

    track.Looped = properties.looped or false
    track:Play(properties.fadeTime or 0.1)

    return track
end

function AnimationUtil.stopAnimation(humanoid, animationId, fadeTime)
    local key = tostring(humanoid) .. "_" .. animationId
    local track = animationCache[key]
    if track then
        track:Stop(fadeTime or 0.1)
    end
end

function AnimationUtil.stopAllAnimations(humanoid, fadeTime)
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:Stop(fadeTime or 0.1)
        end
    end
end

function AnimationUtil.clearCache(humanoid)
    local prefix = tostring(humanoid) .. "_"
    for key in pairs(animationCache) do
        if key:sub(1, #prefix) == prefix then
            animationCache[key] = nil
        end
    end
end

return AnimationUtil
