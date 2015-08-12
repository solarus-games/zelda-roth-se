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
enemy:set_attack_consequence("boomerang", "protected")
enemy:set_attack_consequence("sword", "protected")
enemy:set_attack_consequence("thrown_item", "protected")
enemy:set_arrow_reaction("protected")
enemy:set_hammer_reaction("protected")
enemy:set_hookshot_reaction("protected")
enemy:set_fire_reaction(1)
