-- Agahnim boss.
-- Shoots 3 different magic projectiles.

local enemy = ...

local should_shoot_rabbit_beam = false
local remaining_lightnings = 0
local last_lightnings_total = 0
local projectile_prefix = enemy:get_name() .. "_projectile"

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
  enemy:set_attack_consequence("boomerang", "protected")
  enemy:set_hammer_reaction("protected")
  enemy:set_hookshot_reaction("protected")
end

-- Shoots a normal fireball that the hero can send back.
local function shoot_fireball()

  local sprite = enemy:get_sprite()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 300, function() 
    sprite:set_animation("walking")

    enemy:create_enemy({
      breed = "fireball_red_big",
      name = projectile_prefix,
    })
    sol.audio.play_sound("boss_fireball")
  end)

  return true  -- Repeat the timer until hurt.
end

-- Shoots a deadly thunderbold.
local function shoot_lightning()

  if remaining_lightnings == 0 then
    return false
  end

  local sprite = enemy:get_sprite()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 300, function() 
    sprite:set_animation("walking")

    enemy:create_enemy({
      breed = "agahnim_lightning",
      name = projectile_prefix,
    })
    sol.audio.play_sound("lightning")
  end)

  remaining_lightnings = remaining_lightnings - 1
  if remaining_lightnings > 0 then
    return true  -- Repeat the timer.
  end

  -- Shoot normal fireballs next.
  sol.timer.start(enemy, 3000, function()
    shoot_fireball()
    sol.timer.start(enemy, 1500, shoot_fireball)
  end)
  return false
end

-- Shoots a bouncing beam that turns the hero into a rabbit.
local function shoot_rabbit_beam()

  local sprite = enemy:get_sprite()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 300, function() 
    sprite:set_animation("walking")

    enemy:create_enemy({
      breed = "rabbit_beam",
      name = projectile_prefix,
    })
    sol.audio.play_sound("boss_fireball")
  end)

  should_shoot_rabbit_beam = false

  -- Shoot lightnings next.
  last_lightnings_total = last_lightnings_total + 1
  remaining_lightnings = last_lightnings_total
  sol.timer.start(enemy, 3000, shoot_lightning)
end

function enemy:on_restarted()

  if should_shoot_rabbit_beam then
    sol.timer.start(enemy, 500, shoot_rabbit_beam)
  else
    -- Wait more the first time.
    sol.timer.start(enemy, 1000, function()
      sol.timer.start(enemy, 1500, shoot_fireball)
    end)
  end
end

-- Function called by the fireball when colliding.
function enemy:receive_bounced_projectile(fireball)

  should_shoot_rabbit_beam = true
  fireball:remove()
  enemy:hurt(2)
end

function enemy:on_dying()

  local map = enemy:get_map()
  map:remove_entities(projectile_prefix)
end
