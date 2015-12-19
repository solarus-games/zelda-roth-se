local item = ...
local game = item:get_game()

local monsters_manager = require("scripts/menus/pause_monsters")
local monsters_menu = monsters_manager:new(game)

function item:on_created()

  item:set_savegame_variable("possession_monsters_encyclopedia")
end

function item:add_monster_type_killed(breed)

  local savegame_variable = "monsters_encyclopedia_" .. breed
  game:set_value(savegame_variable, true)
end

function item:get_num_monster_types_killed()

  return monsters_menu:get_monster_count()
end

function item:get_max_monster_types()

  return monsters_menu:get_max_count()
end
