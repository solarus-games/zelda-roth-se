local enemy = ...
local map = enemy:get_map()

local bounced = false

-- A bouncing triple fireball, usually shot by another enemy.

local sprites = {}

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 8)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "custom")

  for i = 0, 2 do
    sprites[#sprites + 1] = enemy:create_sprite("enemies/" .. enemy:get_breed())
  end
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
  movement:set_max_distance(400)
  movement:start(enemy)

  local x = -math.cos(angle) * 12
  local y = math.sin(angle) * 12
  sprites[2]:set_xy(x, y)
  sprites[3]:set_xy(2 * x, 2 * y)
  sprites[2]:set_animation("following_1")
  sprites[3]:set_animation("following_2")
end

function enemy:on_obstacle_reached()

  enemy:remove()
end

function enemy:on_custom_attack_received(attack, sprite)

  if attack == "sword" and sprite == sprites[1] then
    local hero = map:get_hero()
    local movement = enemy:get_movement()
    if movement == nil then
      return
    end

    local old_angle = movement:get_angle()
    local angle
    local hero_direction = hero:get_direction()
    if hero_direction == 0 or hero_direction == 2 then
      angle = math.pi - old_angle
    else
      angle = 2 * math.pi - old_angle
    end

    enemy:go(angle)
    sol.audio.play_sound("enemy_hurt")
    bounced = true

    -- The trailing fireballs are now on the hero: don't attack temporarily
    enemy:set_can_attack(false)
    sol.timer.start(enemy, 500, function()
      enemy:set_can_attack(true)
    end)
  end
end

function enemy:on_collision_enemy(other_enemy)

  if bounced then
    if other_enemy.receive_bounced_projectile ~= nil then
      other_enemy:receive_bounced_projectile(enemy)
    end
  end
end
