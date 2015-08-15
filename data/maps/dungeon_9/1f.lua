local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function map:on_started()

  if game:get_value("dungeon_9_1f_curtain") then
    curtain:remove()
  end
end

function map:on_opening_transition_finished(destination)

  if destination == from_outside then
    game:start_dialog("dungeon_9.welcome")
  end
end

function dont_go_without_zelda_sensor:on_activated()

  -- Trying to leave the floor wall when Zelda is far.
  if zelda:is_following_hero() and zelda:is_far_from_hero() then
    game:start_dialog("dungeon_9.zelda.should_wait_zelda", function()
      hero:walk("6")
    end)
  end
end

function dont_leave_castle_sensor:on_activated()

  -- Trying to leave the castle with Zelda.
  if zelda:is_following_hero() then
    game:start_dialog("dungeon_9.zelda.dont_leave_castle", function()
      hero:walk("2")
    end)
  end
end

function to_b1:on_activated()

  -- Leaving the floor when Zelda is far.
  if zelda:is_following_hero() and zelda:is_far_from_hero() then
    zelda:hero_gone()
  end
end

function curtain:on_cut()

  game:set_value("dungeon_9_1f_curtain", true)
end
