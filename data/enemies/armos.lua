local enemy = ...

-- Armos: a statue that sleeps until the hero gets close.

local behavior = require("enemies/lib/waiting_for_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 5,
  damage = 2,
  normal_speed = 64,
  faster_speed = 64,
  waking_distance = 72,
}

behavior:create(enemy, properties)
