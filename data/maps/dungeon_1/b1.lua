local map = ...
local game = map:get_game()

local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

local fighting_boss = false

function map:on_started()

  if boss ~= nil then
    boss:set_enabled(false)
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
    hero:freeze()
    game:set_dungeon_finished()
    game:start_dialog("dungeon_1.crystal_why", function()
      sol.audio.play_music("victory")
      hero:set_direction(3)
      game:add_max_life(2)
      game:set_life(game:get_max_life())
      sol.timer.start(9000, function()
        hero:start_victory(function()
          game:start_dialog("dungeon_finished_save", function(answer)
            sol.audio.play_sound("danger")
            if answer == 2 then 
              game:save()
            end
            hero:unfreeze()
            map:open_doors("boss_door", true)
          end)
        end)
      end)
    end)
  end
end

