local zelda = ...

local game = zelda:get_game()
local map = game:get_map()
local sprite = zelda:get_sprite()
local hero = game:get_hero()
local movement

zelda:set_optimization_distance(0)
zelda:set_drawn_in_y_order(true)

zelda:set_traversable_by(true)
zelda:set_traversable_by("hero", false)

zelda:set_can_traverse("enemy", true)
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

  zelda:set_can_traverse("hero", true)
  zelda:set_traversable_by("hero", true)
end

-- Stops for now because too close or too far.
local function stop_walking()

  zelda:stop_movement()
  movement = nil
  sprite:set_animation("stopped")
end

function zelda:on_created()

  if zelda:is_following_hero() then
    zelda:set_position(hero:get_position())
    zelda:get_sprite():set_direction(hero:get_direction())
    follow_hero()
    return
  end

  local enable_zelda = false
  if map:get_id() == "dungeon_9/b2" and not game:get_value("dungeon_9_zelda_saved") then
    enable_zelda = true
  elseif map:get_id() == "dungeon_9/2f" and game:get_value("dungeon_9_zelda_saved") then
    enable_zelda = true
  end
  zelda:set_enabled(enable_zelda)
end

function zelda:on_interaction()

  if not game:get_value("dungeon_9_zelda_saved") then
    if not zelda:is_following_hero() then
      game:start_dialog("dungeon_9.zelda.hello")
      game:set_value("dungeon_9_found_zelda", true)
      follow_hero()
    elseif map:get_id() ~= "outside/a2" then
      game:start_dialog("dungeon_9.zelda.secret_wall")
    else
      game:start_dialog("dungeon_9.zelda.almost_there")
    end
  elseif game:get_item("sword"):get_variant() < 2 and not game:has_item("bow_silver") then
    game:start_dialog("dungeon_9.zelda.go_kakariko")
  else
    game:start_dialog("dungeon_9.zelda.go_ganon", function()
      game:set_life(game:get_max_life())
    end)
  end
end

function zelda:on_movement_changed()

  local movement = zelda:get_movement()
  if movement:get_speed() > 0 then
    if hero:get_state() ~= "stairs" or map:get_id() == "outside/a2" then
      sprite:set_direction(movement:get_direction4())
    end
    if sprite:get_animation() ~= "walking" then
      sprite:set_animation("walking")
    end
  end
end

function zelda:on_position_changed()

  if map:get_id() == "outside/a2" then
    -- Special Zelda movement on that map.
    return false
  end

  local distance = zelda:get_distance(hero)
  if zelda:is_following_hero() and zelda:is_very_close_to_hero() then
    -- Close enough to the hero: stop.
    stop_walking()
  end

end

function zelda:on_obstacle_reached()

  sprite:set_animation("stopped")
end

function zelda:on_movement_finished()

  sprite:set_animation("stopped")
end

-- Returns whether Zelda is currently following the hero.
-- This is true even if she is temporarily stopped because too far
-- or to close.
function zelda:is_following_hero()
  -- This is stored on the game because it persists accross maps,
  -- but this is not saved.
  return game.zelda_following and not game:get_value("dungeon_9_zelda_saved")
end

function zelda:is_very_close_to_hero()

  local distance = zelda:get_distance(hero)
  return distance < 32
end

function zelda:is_far_from_hero()

  local distance = zelda:get_distance(hero)
  return distance >= 100
end

-- Called when the hero leaves a map without Zelda when he was supposed to wait for her.
function zelda:hero_gone()

  -- Zelda will be back to the prison cell.
  game.zelda_following = false
end

sol.timer.start(zelda, 50, function()

  if map:get_id() == "outside/a2" then
    -- Special Zelda movement on that map.
    return false
  end

  if zelda:is_following_hero() then
    if movement == nil and not zelda:is_very_close_to_hero() and not zelda:is_far_from_hero() then
      -- Restart.
      follow_hero()
    elseif movement ~= nil and zelda:is_far_from_hero() then
      -- Too far: stop.
      stop_walking()
    end
  end

  if hero:get_state() == "stairs" and zelda:is_following_hero() and not zelda:is_far_from_hero() then
    zelda:set_position(hero:get_position())
    if hero:get_movement() ~= nil then
      sprite:set_direction(hero:get_movement():get_direction4())
    end
  end

  return true
end)
