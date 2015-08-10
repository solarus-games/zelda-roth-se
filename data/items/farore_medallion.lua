local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_farore_medallion")
end

function item:on_obtaining(variant)

  -- Obtaining this increases the defense level of 1 point.
  local game = item:get_game()
  local defense = game:get_value("defense")
  defense = defense + 1
  game:set_value("defense", defense)
end
