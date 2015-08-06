-- A mummy that can only be killed by fire.
local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 1,
  damage = 2,
  normal_speed = 48,
  faster_speed = 48,
}

behavior:create(enemy, properties)

enemy:set_invincible()
enemy:set_attack_consequence("fire", 1)
