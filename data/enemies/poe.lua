local enemy = ...
local game = enemy:get_game()

-- A ghost that can traverse walls and only be killed with the third sword of the silver arrows.

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 10,
  damage = 3,
  normal_speed = 64,
  faster_speed = 64,
  detection_distance = 220,
  ignore_obstacles = true,
  obstacle_behavior = "flying",
}

behavior:create(enemy, properties)

enemy:set_layer_independent_collisions(true)
enemy:set_invincible(true)
enemy:set_attack_consequence("arrow", "custom")
enemy:set_attack_consequence("boomerang", "custom")
enemy:set_attack_consequence("sword", "custom")
enemy:set_attack_consequence("thrown_item", "custom")
enemy:set_fire_reaction("custom")
enemy:set_hammer_reaction("custom")
enemy:set_hookshot_reaction("custom")

if game:get_ability("sword") > 2 then
  enemy:set_attack_consequence("sword", 1)
end

if game:has_item("bow_silver") then
  enemy:set_arrow_reaction(10)
end

function enemy:on_custom_attack_received(attack)

  -- Custom reaction: don't get hurt but step back.
  sol.timer.stop_all(enemy)  -- Stop the towards_hero behavior.
  local hero = enemy:get_map():get_hero()
  local angle = hero:get_angle(enemy)
  local movement = sol.movement.create("straight")
  movement:set_speed(128)
  movement:set_ignore_obstacles(properties.ignore_obstacles)
  movement:set_angle(angle)
  movement:start(enemy)
  sol.timer.start(enemy, 400, function()
    enemy:restart()
  end)
end
