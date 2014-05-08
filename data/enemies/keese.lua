local enemy = ...

-- Keese: a bat that sleeps until the hero gets close.

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/keese",
  life = 1,
  damage = 1,
  normal_speed = 64,
  faster_speed = 64,
  ignore_obstacles = true,
  movement_create = function() end,  -- No movement.
}

behavior:create(enemy, properties)

