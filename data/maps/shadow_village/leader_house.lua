local map = ...
local game = map:get_game()

function leader:on_interaction()

  if not game:has_item("mudora_book") then
    game:start_dialog("shadow_village.non_understandable")
  elseif not game:get_value("shadow_village_can_go_cemetary") then
    game:start_dialog("shadow_village.leader_house.about_village", function()
      if game:get_num_crystals() >= 4 then
        game:set_value("shadow_village_can_go_cemetary", true)
        game:start_dialog("shadow_village.leader_house.enough_crystals")
      end
    end)
  elseif not game:get_value("shadow_village_cemetary_watcher_moved") then
    game:start_dialog("shadow_village.leader_house.go_cemetary")
  elseif not game:get_value("dungeon_9_zelda_saved") then
    game:start_dialog("shadow_village.leader_house.still_alive")
  elseif game:get_item("sword"):get_variant() < 3 then
    game:start_dialog("shadow_village.leader_house.sword_hint")
  else
    game:start_dialog("shadow_village.leader_house.sword_found")
  end
end
