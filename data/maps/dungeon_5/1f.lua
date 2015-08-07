local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function map:on_opening_transition_finished(destination)

  if destination == from_outside_n or destination == from_outside_s then
    game:start_dialog("dungeon_5.welcome")
  end
end
