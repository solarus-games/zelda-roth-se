-- Script of the Lamp.
local item = ...
local game = item:get_game()

local magic_needed = 2  -- Number of magic points required.

function item:on_created()

  item:set_savegame_variable("possession_lamp")
  item:set_assignable(true)
end

-- Called when the hero uses the Lamp.
function item:on_using()

  if game:get_magic() >= magic_needed then
    sol.audio.play_sound("lamp")
    game:remove_magic(magic_needed)
    item:create_fire()
  else
    sol.audio.play_sound("wrong")
  end
  item:set_finished()
end

-- Creates some fire on the map.
function item:create_fire()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
  local dx, dy
  if direction == 0 then
    dx, dy = 18, -4
  elseif direction == 1 then
    dx, dy = 0, -24
  elseif direction == 2 then
    dx, dy = -20, -4
  else
    dx, dy = 0, 16
  end

  local x, y, layer = hero:get_position()
  map:create_custom_entity{
    model = "fire",
    x = x + dx,
    y = y + dy,
    layer = layer,
    width = 16,
    height = 16,
    direction = 0,
  }
end

-- Called when the player obtains the Lamp.
function item:on_obtained(variant, savegame_variable)

  -- Give the magic bar if necessary.
  local magic_bar = self:get_game():get_item("magic_bar")
  if not magic_bar:has_variant() then
    magic_bar:set_variant(1)
  end
end

