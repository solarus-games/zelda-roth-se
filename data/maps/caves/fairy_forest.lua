local map = ...
local game = map:get_game()

function fairy:on_interaction()

  if game:has_item("farore_medallion") then
    game:start_dialog("fairy_cave_already_done")
  else
    game:start_dialog("fairy_cave_forest.reward", function()
      hero:start_treasure("farore_medallion")
    end)
  end
end
