local item = ...

local message_id = {
  "found_piece_of_heart.first",
  "found_piece_of_heart.second",
  "found_piece_of_heart.third",
  "found_piece_of_heart.fourth"
}

function item:on_created()

  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished("piece_of_heart")
end

function item:on_obtained(variant)

  local game = self:get_game()
  local num_pieces_of_heart = game:get_value("num_pieces_of_heart") or 0
  game:start_dialog(message_id[num_pieces_of_heart + 1], function()

    game:set_value("num_pieces_of_heart", (num_pieces_of_heart + 1) % 4)
    if num_pieces_of_heart == 3 then
      game:add_max_life(2)
    end
    game:set_life(game:get_max_life())
  end)
end

