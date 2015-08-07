-- Agahnim boss.
-- Shoots 3 different magic projectiles.

local enemy = ...

local should_shoot_rabbit_beam = false

function enemy:on_created()

  enemy:set_life(16)
  enemy:set_damage(4)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_hurt_style("boss")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_push_hero_on_sword(true)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("arrow", "protected")
  enemy:set_attack_consequence("boomerang", "protected")
  enemy:set_hammer_reaction("protected")
  enemy:set_hookshot_reaction("protected")
end

local function shoot_fireball()

  local sprite = enemy:get_sprite()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 500, function() 
    sprite:set_animation("walking")

    enemy:create_enemy({
      breed = "fireball_red_big",
    })
    sol.audio.play_sound("boss_fireball")
  end)

  return true
end

local function shoot_rabbit_beam()

  local sprite = enemy:get_sprite()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 300, function() 
    sprite:set_animation("walking")

    enemy:create_enemy({
      breed = "rabbit_beam",
    })
    sol.audio.play_sound("boss_fireball")
  end)

  should_shoot_rabbit_beam = false

  -- Shoot normal fireballs next.
  sol.timer.start(enemy, 1000, shoot_fireball)
end

function enemy:on_restarted()

  if should_shoot_rabbit_beam then
    sol.timer.start(enemy, 500, shoot_rabbit_beam)
  else
    -- Wait more the first time.
    sol.timer.start(enemy, 1000, function()
      sol.timer.start(enemy, 1000, shoot_fireball)
    end)
  end
end

-- Function called by the bounced fireball.
function enemy:receive_bounced_projectile(fireball)

  should_shoot_rabbit_beam = true
  fireball:remove()
  enemy:hurt(2)
end
