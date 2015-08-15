-- Ganon: final boss.

local enemy = ...
local game = enemy:get_game()

function enemy:on_created()

  enemy:set_life(100)
  enemy:set_damage(20)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_hurt_style("boss")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  enemy:set_invincible()
  if game:get_item("sword"):get_variant() >= 3 then
    -- The force value is 5.
    enemy:set_attack_consequence("sword", 1)
  end
  if game:has_item("bow_silver") then
    enemy:set_arrow_reaction(5)
  end
end

function enemy:on_restarted()

  local movement = sol.movement.create("target")
  movement:set_speed(64)
  movement:start(enemy)
end
