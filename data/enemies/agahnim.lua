-- Agahnim boss.
-- Shoots 3 different magic projectiles.

local enemy = ...

local max_fireballs = 1
local remaining_fireballs = max_fireballs

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

local function shoot()

  local sprite = enemy:get_sprite()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 500, function() 
    sol.audio.play_sound("boss_charge")
    sol.timer.start(enemy, 1500, function() 
      sprite:set_animation("walking")

      enemy:create_enemy({
        breed = "fireball_red_big",
      })
      sol.audio.play_sound("boss_fireball")
    end)
  end)
  return remaining_fireballs > 0  -- Repeat the timer if more fireballs should be created.
end

function enemy:on_restarted()

  sol.timer.start(self, 4000, shoot)
end

-- Function called by the bounced fireball.
function enemy:receive_bounced_projectile(fireball)

  max_fireballs = max_fireballs + 1
  enemy:hurt(2)
end
