local enemy = ...

-- Rope: a snake that follows the hero.

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/rope",
  life = 1,
  damage = 1,
  normal_speed = 64,
  faster_speed = 64,
}

behavior:create(enemy, properties)
