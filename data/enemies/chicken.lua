local enemy = ...
local map = enemy:get_map()

local angry = false
local num_times_hurt = 0

function enemy:on_created()

  enemy:set_life(100)
  enemy:set_damage(1)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_obstacle_reached(movement)

  if not angry then
    enemy:go_random()
  else
    enemy:go_angry()
  end
end

function enemy:on_restarted()

  if angry then
    enemy:go_angry()
  else
    enemy:go_random()  
    sol.timer.start(enemy, 100, function()
      if map.angry_chickens and not angry then
        enemy:go_angry()
        return false
      end
      return true  -- Repeat the timer.
    end)
  end
end

function enemy:go_random()

  angry = false
  local movement = sol.movement.create("random")
  movement:set_speed(32)
  movement:start(enemy)
  enemy:set_can_attack(false)
end

function enemy:go_angry()

  angry = true
  map.angry_chickens = true
  going_hero = true
  local movement = sol.movement.create("target")
  movement:set_speed(96)
  movement:start(enemy)
  enemy:get_sprite():set_animation("angry")
  enemy:set_can_attack(true)
end

function enemy:on_hurt()

  num_times_hurt = num_times_hurt + 1
  if num_times_hurt == 3 and not map.angry_chickens then
    -- Make all chickens of the map attack the hero.
    map.angry_chickens = true
  end
end
