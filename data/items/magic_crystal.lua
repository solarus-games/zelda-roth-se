local item = ...
local game = item:get_game()

function item:on_created()

  item:set_sound_when_picked(nil)
end

local function victory_cutscene()

  local map = game:get_map()
  local hero = map:get_hero()

  sol.audio.play_music("victory")
  hero:set_direction(3)
  game:add_max_life(2)
  game:set_life(game:get_max_life())
  sol.timer.start(9000, function()
    hero:start_victory(function()
      game:start_dialog("dungeon_finished_save", function(answer)
        sol.audio.play_sound("danger")
        if answer == 3 then
          game:save()
        end
        hero:unfreeze()
        map:open_doors("boss_door")
      end)
    end)
  end)

end

function item:start_dungeon_finished_cutscene()

  local map = game:get_map()
  local hero = map:get_hero()
  hero:freeze()
  game:set_dungeon_finished()

  local num_crystals = game:get_num_crystals()
  if num_crystals == 1 or num_crystals == 5 or num_crystals == 6 or num_crystals == 7 then
    game:start_dialog("crystal." .. num_crystals, victory_cutscene)
  else
    game:start_dialog("crystal.remaining", 7 - num_crystals, victory_cutscene)
  end
end
