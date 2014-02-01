local behavior = {}

-- Behavior of an enemy that goes towards the
-- the hero if he sees him, and randomly walks otherwise.
-- The enemy has only one sprite.

-- Example of use from an enemy script:

-- local enemy = ...
-- local behavior = require("enemies/lib/towards_hero")
-- local properties = {
--   sprite = "enemies/globul",
--   life = 1,
--   damage = 2,
--   normal_speed = 32,
--   faster_speed = 32,
--   hurt_style = "normal",
--   push_hero_on_sword = false,
--   pushed_when_hurt = true,
--   movement_create = function()
--     local m = sol.movement.create("random_path")
--     return m
--   end
-- }
-- behavior:create(enemy, properties)

-- The properties parameter is a table.
-- All its values are optional except the sprite.

function behavior:create(enemy, properties)

  local going_hero = false

  -- Set default properties.
  if properties.life == nil then
    properties.life = 2
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 48
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.pushed_when_hurt == nil then
    properties.pushed_when_hurt = true
  end
  if properties.push_hero_on_sword == nil then
    properties.push_hero_on_sword = false
  end
  if properties.movement_create == nil then
    properties.movement_create = function()
      local m = sol.movement.create("random_path")
      return m
    end
  end

  function enemy:on_created()

    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self:create_sprite(properties.sprite)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_size(16, 16)
    self:set_origin(8, 13)
  end

  function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end

  function enemy:on_obstacle_reached(movement)

    if not going_hero then
      self:go_random()
      self:check_hero()
    end
  end

  function enemy:on_restarted()
    self:go_random()
    self:check_hero()
  end

  function enemy:check_hero()

    local hero = self:get_map():get_entity("hero")
    local _, _, layer = self:get_position()
    local _, _, hero_layer = hero:get_position()
    local near_hero = layer == hero_layer
      and self:get_distance(hero) < 100

    if near_hero and not going_hero then
      self:go_hero()
    elseif not near_hero and going_hero then
      self:go_random()
    end

    sol.timer.stop_all(self)
    sol.timer.start(self, 100, function() self:check_hero() end)
  end

  function enemy:go_random()
    local m = properties.movement_create()
    m:set_speed(properties.normal_speed)
    m:start(self)
    going_hero = false
  end

  function enemy:go_hero()
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:start(self)
    going_hero = true
  end
end

return behavior

