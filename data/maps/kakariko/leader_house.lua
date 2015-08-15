local map = ...
local game = map:get_game()

local can_beat_ganon = game:get_item("sword"):get_variant() >= 3 or game:has_item("bow_silver")

function leader_npc:on_interaction()

  if not game:get_value("kakariko_leader_first_dialog") then
    game:start_dialog("kakariko.leader_house.first_time")
    game:set_value("kakariko_leader_first_dialog", true)

  elseif not game:has_item("bow") then
    game:start_dialog("kakariko.leader_house.go_bow")

  elseif not game:has_all_crystals() then
    game:start_dialog("kakariko.leader_house.go_crystals")

  elseif not game:get_value("dungeon_9_zelda_saved") then
    game:start_dialog("kakariko.leader_house.go_castle")

  elseif not can_beat_ganon then
    game:start_dialog("kakariko.leader_house.go_excalibur", function()
      if game:get_item("glove"):get_variant() < 2 then
        game:start_dialog("kakariko.leader_house.go_glove")
      end
    end)

  else
    game:start_dialog("kakariko.leader_house.go_ganon")
  end
end
