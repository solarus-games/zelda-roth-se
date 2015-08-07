local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function map:on_started(destination)

  if destination == from_1f_n then
    map:set_doors_open("auto_door_a", true)
  end
end
