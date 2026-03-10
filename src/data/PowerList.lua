-- Master list of powers displayed on pedestals in the Magic Hallway.
-- Add new entries here and they will automatically appear on the next pedestal.
-- Fields:
--   name           (string)  Display name
--   hitsRequired   (number)  Hits needed to unlock
--   color          (Color3)  Orb glow color
--   labelColor     (Color3?) Optional label text color (defaults to orb color)

local PowerList = {
	{ name = "Quickstep",   hitsRequired = 0,   color = Color3.fromRGB(230, 230, 240) },
	{ name = "Splash",      hitsRequired = 50,  color = Color3.fromRGB(200, 220, 255) },
	{ name = "Ember",       hitsRequired = 100, color = Color3.fromRGB(255, 120, 40),  labelColor = Color3.fromRGB(255, 80, 30) },
	{ name = "Chain",       hitsRequired = 150, color = Color3.fromRGB(60, 60, 60) },
	{ name = "Immolation",  hitsRequired = 200, color = Color3.fromRGB(255, 200, 50) },
	{ name = "Breeze",      hitsRequired = 250, color = Color3.fromRGB(150, 220, 255) },
	{ name = "Sprout",      hitsRequired = 300, color = Color3.fromRGB(100, 200, 100) },
	{ name = "Rust",        hitsRequired = 350, color = Color3.fromRGB(140, 100, 70) },
}

return PowerList
