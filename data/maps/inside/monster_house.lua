local map = ...
local game = map:get_game()

function monster_npc:on_interaction()

  if not game:has_item("monsters_encyclopedia") then
    game:get_item("monsters_encyclopedia"):set_variant(1)
    game:start_dialog("monster_house.welcome")
  else
    -- TODO
  end
end
