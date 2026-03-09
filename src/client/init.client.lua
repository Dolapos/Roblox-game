--[[
    init.client.lua
    Client bootstrap script – initializes all client controllers in the correct order.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for essential replicated folders
ReplicatedStorage:WaitForChild("Shared")
ReplicatedStorage:WaitForChild("Data")

-- Wait for remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Controller modules
local Controllers = script.Controllers

-- Phase 1: Require all controller modules
local VFXController       = require(Controllers.VFXController)
local UIController        = require(Controllers.UIController)
local RagdollController   = require(Controllers.RagdollController)
local CombatRenderer      = require(Controllers.CombatRenderer)
local InputController     = require(Controllers.InputController)
local PowerSelectController = require(Controllers.PowerSelectController)

-- Phase 2: Create instances
local vfx         = VFXController.new()
local ui          = UIController.new()
local ragdoll     = RagdollController.new()
local combat      = CombatRenderer.new(vfx, ui)   -- depends on VFX + UI
local input       = InputController.new()
local powerSelect = PowerSelectController.new()

-- Phase 3: Initialize in dependency order
-- a. Controllers with no dependencies
vfx:init()
ui:init()
ragdoll:init()

-- b. Controllers that depend on the above
combat:init()

-- c. Remaining independent controllers
input:init()
powerSelect:init()

-- Phase 4: Request initial progression data from server
local RequestProgression = Remotes:WaitForChild("RequestProgression")
RequestProgression:FireServer()

print("[Client] All controllers initialized.")
