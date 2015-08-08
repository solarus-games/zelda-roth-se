local item = ...
local game = item:get_game()

local magic_needed = 4  -- Number of magic points required.

function item:on_created()

  item:set_savegame_variable("possession_fire_rod")
  item:set_assignable(true)
end

-- Shoots some fire on the map.
function item:shoot()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()

  local x, y, layer = hero:get_position()
  local fire = map:create_custom_entity({
    model = "fire",
    x = x,
    y = y,
    layer = layer,
    direction = direction,
  })

  local fire_sprite = fire:get_sprite()
  fire_sprite:set_animation("flying")

  local angle = direction * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(fire)
end

function item:on_using()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
  hero:set_animation("rod")

  local x, y, layer = hero:get_position()
  local fire_rod = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    direction = direction,
    sprite = "hero/fire_rod",
  })

  if game:get_magic() >= magic_needed then
    sol.audio.play_sound("lamp")
    game:remove_magic(magic_needed)
    item:shoot()
  end

  sol.timer.start(hero, 300, function()
    fire_rod:remove()
    item:set_finished()
  end)
end
