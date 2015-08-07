-- Falling hand that teleports the hero back to the entrance.
local enemy = ...
local map = enemy:get_map()

local sprite

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(0)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end

function enemy:on_restarted()

  sprite:set_animation("sleeping")
  sol.timer.start(enemy, 5000, function()

    local hero = map:get_hero()
    local hero_x, hero_y = hero:get_position()
    enemy:set_position(hero_x, hero_y - 240)

    sprite:set_animation("walking")
  end)
end

function enemy:on_attacking_hero(hero)

  -- Teleport the hero.
  -- TODO check if this works when teleporting to the same map.
  local game = hero:get_game()
  hero:teleport(game:get_starting_position())
end