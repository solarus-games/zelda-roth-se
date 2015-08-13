-- Dungeon 9 B2.

local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function map:on_obtained_treasure(item)

  if item:get_name() == "boss_key" then
    sol.audio.play_sound("secret")
    map:open_doors("door_d")
  end
end

function weak_wall_a:on_opened()

  sol.audio.play_sound("secret")
end

function dont_go_without_zelda_sensor:on_activated()

  -- Trying to traverse the weak wall before talking to Zelda.
  if not game:get_value("dungeon_9_zelda_saved") and not zelda:is_following_hero() then
    game:start_dialog("dungeon_9.zelda.weak_wall_ignored_zelda", function()
      hero:walk("4")
    end)
  end
end

function to_b1:on_activated()

  -- Leaving the floor when Zelda is far.
  if zelda:is_following_hero() and zelda:is_far_from_hero() then
    zelda:hero_gone()
  end
end
