local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 15,
  damage = 8,
  normal_speed = 64,
  faster_speed = 64,
}

behavior:create(enemy, properties)
