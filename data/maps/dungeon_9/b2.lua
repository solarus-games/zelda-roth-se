local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function map:on_obtained_treasure(item)

  if item:get_name() == "boss_key" then
    sol.audio.play_sound("secret")
    map:open_doors("door_d")
  end
end

function weak_wall_a:on_opened()

  sol.audio.play_sound("secret")
end
