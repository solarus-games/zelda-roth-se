local item = ...
local game = item:get_game()

local message_id = {
  "found_piece_of_heart.first",
  "found_piece_of_heart.second",
  "found_piece_of_heart.third",
  "found_piece_of_heart.fourth"
}
local icon_sprite
local icon_widget = {}

-- Returns the current number of pieces of heart between 0 and 3.
function item:get_num_pieces_of_heart()

  return game:get_value("num_pieces_of_heart") or 0
end

-- Returns the total number of pieces of hearts already found.
function item:get_total_pieces_of_heart()

  return game:get_value("total_pieces_of_heart") or 0
end

-- Returns the number of pieces of hearts existing in the game.
function item:get_max_pieces_of_heart()

  return 36
end

function item:on_created()

  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished("piece_of_heart")
end

function item:on_obtaining(variant)

  -- Show the piece of heart icon in the dialog about to start.
  sol.menu.start(game, icon_widget)
end

function item:on_obtained(variant)

  -- The dialog has just finished, stop showing the piece of heart icon.
  sol.menu.stop(icon_widget)

  -- Show another dialog indicating the number of pieces of heart
  -- remaining to get a new heart container.
  local num_pieces_of_heart = item:get_num_pieces_of_heart()
  game:start_dialog(message_id[num_pieces_of_heart + 1], function()

    game:set_value("num_pieces_of_heart", (num_pieces_of_heart + 1) % 4)
    game:set_value("total_pieces_of_heart", item:get_total_pieces_of_heart() + 1)
    if num_pieces_of_heart == 3 then
      game:add_max_life(2)
    end
    game:set_life(game:get_max_life())
  end)
end

function icon_widget:on_started()

  if icon_sprite == nil then
    icon_sprite = sol.sprite.create("hud/piece_of_heart_icon")
  end
  icon_sprite:set_direction(item:get_num_pieces_of_heart() + 1)

  local dialog_x, dialog_y, dialog_width, dialog_height = game:get_dialog_box():get_bounding_box()
  icon_sprite:set_xy(dialog_x + dialog_width / 2 - 8, dialog_y + dialog_height / 2)
end

function icon_widget:on_draw(dst_surface)
  icon_sprite:draw(dst_surface)
end

--[[
Pieces of heart location:

x6 outside A1
x2 outside A2
x3 outside A3
x3 outside B1
x2 outside B3
x4 outside C1
x4 outside C2
x1 outside C3
x1 gerudo chest game
x1 shadow village chest game
x1 kakariko chest game
x1 kakariko tavern
x1 lake cave
x6 monster house
--]]