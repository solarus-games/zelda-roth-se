local enemy = ...

-- Skeleton: goes in a random direction.

enemy:set_life(3)
enemy:set_damage(2)

local sprite = enemy:create_sprite("enemies/skeleton")

-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()

  local m = sol.movement.create("straight")
  m:set_speed(0)
  m:start(self)
  local direction4 = math.random(4) - 1
  self:go(direction4)
end

-- An obstacle is reached: stop for a while, looking to a next direction.
function enemy:on_obstacle_reached(movement)

  -- Look to the left or to the right.
  local animation = sprite:get_animation()
  if animation == "walking" then
    self:look_left_or_right()
  end
end

-- The movement is finished: stop for a while, looking to a next direction.
function enemy:on_movement_finished(movement)
  -- Same thing as when an obstacle is reached.
  self:on_obstacle_reached(movement)
end

-- Makes the enemy walk towards a direction.
function enemy:go(direction4)

  -- Set the sprite.
  sprite:set_animation("walking")
  sprite:set_direction(direction4)

  -- Set the movement.
  local m = self:get_movement()
  local max_distance = 40 + math.random(120)
  m:set_max_distance(max_distance)
  m:set_smooth(true)
  m:set_speed(40)
  m:set_angle(direction4 * math.pi / 2)
end

-- Makes the enemy look to its left or to its right (random choice).
function enemy:look_left_or_right()

  local direction = sprite:get_direction()
  if math.random(2) == 1 then
    sprite:set_animation("stopped_watching_left")
    sol.timer.start(enemy, 500, function()
      enemy:go((direction + 1) % 4)
    end)
  else
    sprite:set_animation("stopped_watching_right")
    sol.timer.start(enemy, 500, function()
      enemy:go((direction + 3) % 4)
    end)
  end
end
