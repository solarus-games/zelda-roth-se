local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

local fighting_boss = false

function map:on_started()

  if boss ~= nil then
    boss:set_enabled(false)
  end
  map:set_doors_open("boss_door", true)

  -- Weak floor.
  if map:get_game():get_value("dungeon_7_2f_weak_floor_a") then
    weak_floor_a:set_enabled(false)
    weak_floor_a_sensor:set_enabled(false)
  else
    weak_floor_a_teletransporter:set_enabled(false)
  end

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
    item:start_dungeon_finished_cutscene()
  end
end

function weak_floor_a_sensor:on_collision_explosion()

  if weak_floor_a:is_enabled() then

    weak_floor_a:set_enabled(false)
    weak_floor_a_sensor:set_enabled(false)
    weak_floor_a_teletransporter:set_enabled(true)
    sol.audio.play_sound("secret")
    map:get_game():set_value("dungeon_7_2f_weak_floor_a", true)
  end
end
