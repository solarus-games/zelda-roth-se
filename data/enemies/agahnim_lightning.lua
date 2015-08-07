-- A deadly thunderbolt sent by Agahnim.

local enemy = ...
local map = enemy:get_map()

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(6)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 0)
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:create_sprite("enemies/" .. enemy:get_breed())
end

function enemy:on_restarted()

  sol.timer.start(enemy, 1000, function()
    enemy:remove()
  end)
end
