--[[
    LightingSetup.lua
    Configures Lighting post-processing effects for a bright, vibrant atmosphere.
    Called once during server bootstrap.
]]

local Lighting = game:GetService("Lighting")

local LightingSetup = {}

function LightingSetup.apply()
    -- Atmosphere (sky haze, depth)
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmo then
        atmo = Instance.new("Atmosphere")
        atmo.Parent = Lighting
    end
    atmo.Density = 0.3
    atmo.Offset = 0.25
    atmo.Color = Color3.fromRGB(200, 210, 230)
    atmo.Decay = Color3.fromRGB(130, 150, 180)
    atmo.Glare = 0
    atmo.Haze = 1.5

    -- Bloom (bright glow on neon/lights)
    local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
    if not bloom then
        bloom = Instance.new("BloomEffect")
        bloom.Parent = Lighting
    end
    bloom.Intensity = 0.4
    bloom.Size = 24
    bloom.Threshold = 1.2

    -- Color Correction (vibrant colors)
    local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Parent = Lighting
    end
    cc.Brightness = 0.05
    cc.Contrast = 0.1
    cc.Saturation = 0.2
    cc.TintColor = Color3.fromRGB(255, 255, 255)

    -- Sun Rays
    local rays = Lighting:FindFirstChildOfClass("SunRaysEffect")
    if not rays then
        rays = Instance.new("SunRaysEffect")
        rays.Parent = Lighting
    end
    rays.Intensity = 0.06
    rays.Spread = 0.8

    -- Sky
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    sky.CelestialBodiesShown = true
    sky.StarCount = 0
    sky.SunAngularSize = 15
    sky.MoonAngularSize = 8
end

return LightingSetup
