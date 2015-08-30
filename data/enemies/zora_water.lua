-- A water enemy who shoots fireballs.

local enemy = ...
local sprite

local children = {}

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("swimming")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  function sprite:on_animation_finished(animation)
    if animation == "shooting" then
      sprite:set_animation("walking")
    end
  end
end

function enemy:on_restarted()

  local sprite = enemy:get_sprite()
  local hero = enemy:get_map():get_hero()
  sol.timer.start(enemy, 3000, function()
    if enemy:get_distance(hero) < 300 and enemy:is_in_same_region(hero)  then
      sol.audio.play_sound("zora")
      sprite:set_animation("shooting")
      children[#children + 1] = enemy:create_enemy({
        breed = "fireball_red_small",
      })
    end
    return true  -- Repeat the timer.
  end)
end

local previous_on_removed = enemy.on_removed
function enemy:on_removed()

  if previous_on_removed then
    previous_on_removed(enemy)
  end

  for _, child in ipairs(children) do
    child:remove()
  end
end
