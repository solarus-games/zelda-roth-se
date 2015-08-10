local map = ...
local game = map:get_game()

function fairy:on_interaction()

  if game:has_item("nayru_medallion") then
    game:start_dialog("fairy_cave_already_done")
  else
    game:start_dialog("fairy_cave_lake.reward", function()
      hero:start_treasure("nayru_medallion")
    end)
  end
end
