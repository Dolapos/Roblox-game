-- Server entry point
-- Builds the floating island, mansion, and magic hallway

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FloatingIsland = require(script:WaitForChild("Builders"):WaitForChild("FloatingIsland"))
local Mansion = require(script:WaitForChild("Builders"):WaitForChild("Mansion"))
local MagicHallway = require(script:WaitForChild("Builders"):WaitForChild("MagicHallway"))
local PowerDisplay = require(script:WaitForChild("Builders"):WaitForChild("PowerDisplay"))

local PowerList = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("PowerList"))

-- Build at world origin, elevated in the sky
local ISLAND_POSITION = Vector3.new(0, 300, 0)

local worldFolder = Instance.new("Folder")
worldFolder.Name = "World"
worldFolder.Parent = workspace

-- 1. Floating island
local island = FloatingIsland.build(worldFolder, ISLAND_POSITION)

-- 2. Mansion on top
local mansion = Mansion.build(worldFolder, ISLAND_POSITION)

-- 3. Magic hallway (built inside the mansion)
local hallway = MagicHallway.build(worldFolder, ISLAND_POSITION)

-- 4. Place power orbs on pedestals
PowerDisplay.populate(hallway, PowerList)

print("[Server] Floating island world built successfully")
