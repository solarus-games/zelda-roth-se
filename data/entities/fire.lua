-- A flame that can hurt enemies.
-- It is meant to by created by the lamp and the fire rod.
local fire = ...
local sprite

local enemies_touched = { }

function fire:on_created()

  fire:set_size(16, 16)
  fire:set_origin(8, 13)
  sprite = fire:create_sprite("entities/fire")

  -- Remove the sprite if the animation finishes.
  -- Use animation "flying" if you want it to persist.
  function sprite:on_animation_finished()
    fire:remove()
  end
end

-- Hurt enemies.
fire:add_collision_test("sprite", function(fire, entity)

  if entity:get_type() ~= "enemy" then
    return
  end

  local enemy = entity
  if enemies_touched[enemy] then
    -- If protected we don't want to play the sound repeatedly.
    return
  end
  enemies_touched[enemy] = true
  local reaction = enemy:get_fire_reaction(enemy_sprite)
  enemy:receive_attack_consequence("fire", reaction)
end)
