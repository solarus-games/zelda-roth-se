local enemy = ...

local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 10,
  damage = 9,
  normal_speed = 64,
  faster_speed = 64,
}

behavior:create(enemy, properties)
