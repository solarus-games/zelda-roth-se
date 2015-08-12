-- Arrghus boss.

local enemy = ...

function enemy:on_created()

  enemy:set_life(7)
  enemy:set_damage(2)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_hurt_style("boss")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_obstacle_behavior("flying")
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  enemy:set_invincible()
  enemy:set_attack_consequence("sword", 1)
  enemy:set_attack_consequence("thrown_item", 1)
  enemy:set_arrow_reaction(1)
  enemy:set_hookshot_reaction(1)
end

function enemy:on_restarted()

  local movement = sol.movement.create("target")
  movement:set_speed(64)
  movement:start(enemy)
end
