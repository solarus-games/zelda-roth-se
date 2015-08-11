-- A bouncing beam that temporarily turns the hero into a rabbit.
local enemy = ...
local map = enemy:get_map()

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(0)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:create_sprite("enemies/" .. enemy:get_breed())
end

function enemy:on_restarted()

  local hero_x, hero_y = map:get_hero():get_center_position()
  local angle = enemy:get_angle(hero_x, hero_y)

  enemy:go(angle)
end

function enemy:go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)
end

function enemy:on_obstacle_reached()

  local movement = enemy:get_movement()
  local angle = movement:get_angle()
  local wall_right = enemy:test_obstacles(1, 0)
  local wall_top = enemy:test_obstacles(0, -1)
  local wall_left = enemy:test_obstacles(-1, 0)
  local wall_bottom = enemy:test_obstacles(0, 1)

  local wall_horizontal = wall_top or wall_bottom
  local wall_vertical = wall_right or wall_left

  if wall_horizontal and wall_vertical then
    -- Corner: go back.
    angle = angle + math.pi
  elseif wall_vertical then
    -- Bounce.
    angle = math.pi - angle
  elseif wall_horizontal then
    -- Bounce.
    angle = -angle
  else  -- No simple wall detected: just go back.
    angle = angle + math.pi
  end

  enemy:go(angle)
end

function enemy:on_attacking_hero(hero)

  -- Turn the hero into a rabbit until he gets hurt.
  local game = hero:get_game()
  if not game:is_rabbit() then
    sol.audio.play_sound("cane")
    game:start_rabbit()
  end
  enemy:remove()
end
