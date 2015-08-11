local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function to_b2:on_activated()

  -- Leaving the floor when Zelda is far.
  if zelda:is_following_hero() and zelda:is_far_from_hero() then
    zelda:hero_gone()
  end
end

function to_1f:on_activated()

  -- Leaving the floor when Zelda is far.
  if zelda:is_following_hero() and zelda:is_far_from_hero() then
    zelda:hero_gone()
  end
end
