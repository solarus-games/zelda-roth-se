local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 2,
  damage = 2,
  normal_speed = 48,
  faster_speed = 48,
  obstacle_behavior = "swimming",  -- Allow to traverse water.
}

behavior:create(enemy, properties)
