local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function map:on_opening_transition_finished(destination)

  if destination == from_outside then
    game:start_dialog("dungeon_8.welcome")
  end
end

function map:on_obtaining_treasure(item, variant, savegame_variable)

  if item:get_name() == "sword" then
    -- Also give an additional heart container.
    game:add_max_life(2)
    game:set_life(game:get_max_life())
  end
end
