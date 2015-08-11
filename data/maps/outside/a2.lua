-- Outside A2: Castle

local map = ...
local game = map:get_game()

function map:on_started(destination)

  if destination == from_dungeon_9_1f_s then
    dungeon_9_door_s:set_enabled(false)
  elseif destination == from_dungeon_9_1f_ne then
    if zelda:is_following_hero() then
      zelda:get_sprite():set_direction(1)
    end
  end

  if game:get_value("dungeon_9_zelda_saved") then
    -- Open the final entrance.
    dungeon_9_door_n:set_enabled(false)
  end
end

function map:on_opening_transition_finished(destination)

  if destination == from_dungeon_9_1f_ne and zelda:is_following_hero() then

    game:start_dialog("dungeon_9.zelda.almost_there", function()
      local movement = sol.movement.create("path")
      movement:set_path({2,2,2,4,4,4,4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2})
      movement:set_speed(64)
      movement:set_ignore_obstacles(true)  -- Because of initial stairs.
      movement:start(zelda, function()
        -- Reached the door.
        if dungeon_9_door_n:is_enabled() then
          sol.audio.play_sound("door_open")
          dungeon_9_door_n:set_enabled(false)
        end
        movement:set_path({2,2})
        movement:start(zelda, function()
          zelda:set_enabled(false)
          game:set_value("dungeon_9_zelda_saved", true)
          hero:unfreeze()
        end)
      end)
    end)
  end
end

function crystals_required_sensor:on_activated()

  -- Check if the player has the 7 crystals.
  if not game:has_all_crystals() then
    sol.audio.play_sound("warp")
    hero:teleport(map:get_id(), "from_crystals_required")
  end
end

function dont_go_without_zelda_sensor_w:on_activated()

  -- Trying to enter the castle before Zelda.
  if zelda:is_enabled() and zelda:is_following_hero() then
    game:start_dialog("dungeon_9.zelda.should_wait_zelda", function()
      hero:walk("6")
    end)
  end
end
