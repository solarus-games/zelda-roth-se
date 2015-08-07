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

  -- Bounce.
  local movement = enemy:get_movement()
  local angle = movement:get_angle()
  if enemy:test_obstacles(1, 0) then  -- Wall on the right.
    angle = math.pi - angle
  elseif enemy:test_obstacles(0, -1) then  -- Wall on the top.
    angle = -angle
  elseif enemy:test_obstacles(-1, 0) then  -- Wall on the left.
    angle = math.pi - angle
  elseif enemy:test_obstacles(0, 1) then  -- Wall on the bottom.
    angle = -angle
  else  -- No simple obstacle detected: just go back.
    angle = angle + math.pi
  end

  enemy:go(angle)
end

function enemy:on_attacking_hero(hero)

  -- Turn the hero into a rabbit until he gets hurt.
  if not hero:is_rabbit() then
    sol.audio.play_sound("cane")
    hero:start_rabbit()
    enemy:remove()
  end
end