local map = ...
local game = map:get_game()

function fairy:on_interaction()

  if game:get_max_magic() > 32 then
    game:start_dialog("fairy_cave_already_done")
  else
    game:start_dialog("fairy_cave_ruins.reward", function()
      sol.audio.play_sound("treasure")
      hero:freeze()
      hero:set_animation("brandish")
      game:set_max_magic(64)
      game:start_dialog("fairy_cave_ruins.treasure", function()
        hero:unfreeze()
      end)
    end)
  end
end
