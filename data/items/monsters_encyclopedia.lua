local item = ...
local game = item:get_game()

local counter_savegame_variable = "monsters_encyclopedia_counter"

function item:on_created()

  item:set_savegame_variable("possession_monsters_encyclopedia")
end

function item:add_monster_type_killed(breed)

  local savegame_variable = "monsters_encyclopedia_" .. breed
  if game:get_value(savegame_variable) then
    -- Already known.
    return
  end

  game:set_value(savegame_variable, true)
  local num_monster_types = item:get_num_monster_types_killed()
  game:set_value(counter_savegame_variable, num_monster_types + 1)
end

function item:get_num_monster_types_killed()

  return game:get_value(counter_savegame_variable) or 0
end

function item:get_max_monster_types()

  return 46
end
