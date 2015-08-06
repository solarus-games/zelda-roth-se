local enemy = ...

-- A vulture that sleeps until the hero gets close.

local behavior = require("enemies/lib/waiting_for_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 1,
  damage = 2,
  normal_speed = 64,
  faster_speed = 64,
  waking_distance = 100,
}

behavior:create(enemy, properties)

-- Only the hammer can hurt this enemy.
enemy:set_invincible()
enemy:set_attack_consequence("sword", "protected")
enemy:set_attack_consequence("thrown_item", "protected")
enemy:set_attack_consequence("arrow", "protected")
enemy:set_attack_consequence("boomerang", "protected")
enemy:set_hammer_reaction("protected")
enemy:set_hookshot_reaction("protected")
enemy:set_hammer_reaction(1)
