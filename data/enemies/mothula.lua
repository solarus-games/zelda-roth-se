-- Mowathula boss.

local enemy = ...

function enemy:on_created()

  self:set_life(8)
  self:set_damage(2)
  self:create_sprite("enemies/mothula")
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(false)
  self:set_size(32, 32)
  self:set_origin(16, 16)
end

function enemy:on_restarted()

  local movement = sol.movement.create("target")
  movement:set_speed(64)
  movement:start(enemy)
end
