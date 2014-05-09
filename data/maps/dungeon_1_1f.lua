local map = ...
local game = map:get_game()

local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function map:on_opening_transition_finished(destination)

  if destination == from_outside_east
    or destination == from_outside_west then
    game:start_dialog("dungeon_1.welcome")
  end

end

function weak_wall_a:on_opened()

  sol.audio.play_sound("secret")

end

function weak_wall_b:on_opened()

  sol.audio.play_sound("secret")

end

