local map = ...
local game = map:get_game()

function leader_npc:on_interaction()

  if not game:get_value("kakariko_leader_first_dialog") then
    game:start_dialog("kakariko.leader_house.first_time")
    game:set_value("kakariko_leader_first_dialog", true)

  elseif not game:has_item("bow") then
    game:start_dialog("kakariko.leader_house.go_bow")

  elseif not game:are_all_dungeons_finished() then
    game:start_dialog("kakariko.leader_house.go_crystals")

  elseif not game:get_value("castle.found_ganon") or  -- TODO set this variable one day
      game:get_item("sword"):get_variant() >= 3 then
    game:start_dialog("kakariko.leader_house.go_ganon")

  else
    game:start_dialog("kakariko.leader_house.go_excalibur", function()
      if game:get_item("glove"):get_variant() < 2 then
        game:start_dialog("kakariko.leader_house.go_glove")
      end
    end)

  end
end
