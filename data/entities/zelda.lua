local zelda = ...

local game = zelda:get_game()
local sprite = zelda:get_sprite()
local hero = game:get_hero()
local following = false
local movement

zelda:set_optimization_distance(0)
zelda:set_traversable_by(true)
zelda:set_can_traverse("hero", true)
zelda:set_can_traverse("separator", true)

-- TODO make this available to other scripts.
local function follow_hero()

  movement = sol.movement.create("target")
  movement:set_speed(64)
  movement:start(zelda)
  following = true
  sprite:set_animation("walking")

end

-- Stops for now because too close or too far.
local function stop_following_hero()

  zelda:stop_movement()
  movement = nil
  sprite:set_animation("stopped")
end

function zelda:on_interaction()

  if not game:get_value("dungeon_9_found_zelda") then
    game:start_dialog("dungeon_9.zelda.hello")
    game:set_value("dungeon_9_found_zelda", true)
    follow_hero()
  elseif not following then
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
  if following and distance < 32 then
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

sol.timer.start(zelda, 200, function()

  local distance = zelda:get_distance(hero)
  if following then
    if movement == nil and distance >= 32 and distance < 100 then
      -- Restart.
      follow_hero()
    elseif movement ~= nil and distance >= 100 then
      -- Too far: stop.
      stop_following_hero()
    end
  end

  return true
end)
