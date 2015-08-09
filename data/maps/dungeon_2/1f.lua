local map = ...
local game = map:get_game()

local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function map:on_opening_transition_finished(destination)

  if destination == from_outside then
    game:start_dialog("dungeon_2.welcome")
  end
end

local fighting_boss = false

function map:on_started()

  if boss ~= nil then
    boss:set_enabled(false)
  elseif not game:get_value("dungeon_2_crystal") then
    crystal_platform:set_enabled(true)
  end
  map:set_doors_open("boss_door", true)
end

function start_boss_sensor:on_activated()

  if boss ~= nil and not fighting_boss then
    hero:freeze()
    map:close_doors("boss_door")
    sol.audio.stop_music()
    sol.timer.start(1000, function()
      boss:set_enabled(true)
      hero:unfreeze()
      sol.audio.play_music("boss")
      fighting_boss = true
    end)
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)

  if item:get_name() == "magic_crystal" then
    crystal_platform:set_enabled(false)
    item:start_dungeon_finished_cutscene()
  end
end

if boss ~= nil then
  function boss:on_dying()
    -- Create an invisible walkable platform where the crystal will appear,
    -- to make sure it does not sink in water.
    crystal_platform:set_enabled(true)
    local x, y = boss:get_position()
    local origin_x, origin_y = boss:get_origin()
    x, y = x - origin_x, y - origin_y
    crystal_platform:set_position(x, y)
  end
end
