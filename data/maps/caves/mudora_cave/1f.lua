local map = ...
local game = map:get_game()

local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function close_door_a_sensor:on_activated()

  if door_a:is_open() then
    map:close_doors("door_a")
  end
end
