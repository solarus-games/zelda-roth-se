-- Beam shot by Wizzrobe and that can bounce on the sword.

local enemy = ...

local bounced = false

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(4)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(16, 16)
  enemy:set_origin(8, 8)
  enemy:set_obstacle_behavior("flying")
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "custom")
  enemy:set_optimization_distance(0)
end

function enemy:on_obstacle_reached()

  enemy:remove()
end

function enemy:go(direction4)

  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)

  enemy:get_sprite():set_direction(direction4)
end

function enemy:on_custom_attack_received(attack, sprite)

  if attack == "sword" and not bounced then

    local sprite = enemy:get_sprite()
    local hero = enemy:get_map():get_hero()
    local direction = hero:get_direction()
    sprite:set_direction(direction)

    local movement = enemy:get_movement()
    local angle = direction * math.pi / 2
    movement:set_angle(angle)

    sol.audio.play_sound("enemy_hurt")

    bounced = true
  end
end

function enemy:on_collision_enemy(other_enemy)

  if bounced then
    if other_enemy.receive_bounced_projectile ~= nil then
      other_enemy:receive_bounced_projectile(enemy)
    end
  end
end
