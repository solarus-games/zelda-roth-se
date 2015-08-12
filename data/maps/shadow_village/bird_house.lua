local map = ...
local game = map:get_game()

function bird:on_interaction()

  if not game:has_item("mudora_book") then
    game:start_dialog("shadow_village.non_understandable")
  else
    game:start_dialog("shadow_village.bird_house.bird")
  end
end
