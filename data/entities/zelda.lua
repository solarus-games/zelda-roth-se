local zelda = ...

local game = zelda:get_game()
local map = game:get_map()
local sprite = zelda:get_sprite()
local hero = game:get_hero()
local movement

zelda:set_optimization_distance(0)
zelda:set_traversable_by(true)
zelda:set_can_traverse("enemy", true)
zelda:set_can_traverse("hero", true)
zelda:set_can_traverse("npc", true)
zelda:set_can_traverse("sensor", true)
zelda:set_can_traverse("separator", true)
zelda:set_can_traverse("stairs", true)
zelda:set_can_traverse("teletransporter", true)

-- TODO make this available to other scripts.
local function follow_hero()

  movement = sol.movement.create("target")
  movement:set_speed(64)
  movement:start(zelda)
  game.zelda_following = true
  sprite:set_animation("walking")
end

-- Stops for now because too close or too far.
local function stop_following_hero()

  zelda:stop_movement()
  movement = nil
  sprite:set_animation("stopped")
end

function zelda:on_created()

  if game.zelda_following then

    zelda:set_position(hero:get_position())
    follow_hero()
    movement:set_ignore_obstacles(true)
  elseif map:get_id() ~= "dungeon_9/b2" then
    zelda:remove()
  end
end

function zelda:on_interaction()

  if not game:get_value("dungeon_9_found_zelda") then
    game:start_dialog("dungeon_9.zelda.hello")
    game:set_value("dungeon_9_found_zelda", true)
    follow_hero()
  elseif not game.zelda_following then
    game:start_dialog("dungeon_9.zelda.angry")
    follow_hero()
  end
end

function zelda:on_movement_changed()

  if movement:get_speed() > 0 then
    sprite:set_direction(movement:get_direction4())
    if sprite:get_animation() ~= "walking" then
      sprite:set_animation("walking")
    end
  end
end

function zelda:on_position_changed()

  local distance = zelda:get_distance(hero)
  if game.zelda_following and zelda:is_very_close_to_hero() then
    -- Close enough to the hero: stop.
    stop_following_hero()
  end

end

function zelda:on_obstacle_reached()

  sprite:set_animation("stopped")
end

function zelda:on_movement_finished()

  sprite:set_animation("stopped")
end

function zelda:is_very_close_to_hero()

  local distance = zelda:get_distance(hero)
  return distance < 32
end

function zelda:is_far_from_hero()

  local distance = zelda:get_distance(hero)
  return distance >= 100
end

sol.timer.start(zelda, 50, function()

  if game.zelda_following then
    if movement == nil and not zelda:is_very_close_to_hero() and not zelda:is_far_from_hero() then
      -- Restart.
      follow_hero()
    elseif movement ~= nil and zelda:is_far_from_hero() then
      -- Too far: stop.
      stop_following_hero()
    end
  end

  if hero:get_state() == "stairs" then
    zelda:set_position(hero:get_position())
  end

  return true
end)
