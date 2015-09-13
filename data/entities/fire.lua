-- A flame that can hurt enemies.
-- It is meant to by created by the lamp and the fire rod.
local fire = ...
local sprite

local enemies_touched = { }

function fire:on_created()

  fire:set_size(8, 8)
  fire:set_origin(4, 5)
  sprite = fire:create_sprite("entities/fire")
  sprite:set_direction(fire:get_direction())

  -- Remove the sprite if the animation finishes.
  -- Use animation "flying" if you want it to persist.
  function sprite:on_animation_finished()
    fire:remove()
  end
end

-- Returns the sprite of a destrucible.
-- TODO remove this when the engine provides a function destructible:get_sprite()
local function get_destructible_sprite(destructible)

  return fire.get_sprite(destructible)
end

-- Returns whether a destructible is a bush.
local function is_bush(destructible)

  local sprite = get_destructible_sprite(destructible)
  if sprite == nil then
    return false
  end

  local sprite_id = sprite:get_animation_set()
  return sprite_id == "entities/bush" or sprite_id:match("^entities/bush_")
end

-- Traversable rules.
fire:set_can_traverse("crystal", true)
fire:set_can_traverse("crystal_block", true)
fire:set_can_traverse("hero", true)
fire:set_can_traverse("jumper", true)
fire:set_can_traverse("stairs", false)
fire:set_can_traverse("stream", true)
fire:set_can_traverse("switch", true)
fire:set_can_traverse("teletransporter", true)
fire:set_can_traverse_ground("deep_water", true)
fire:set_can_traverse_ground("shallow_water", true)
fire:set_can_traverse_ground("hole", true)
fire:set_can_traverse_ground("lava", true)
fire:set_can_traverse_ground("prickles", true)
fire:set_can_traverse_ground("low_wall", true)
fire:set_can_traverse("destructible", function(fire, destructible)
  return is_bush(destructible)
end)
fire.apply_cliffs = true

-- Burn bushes.
fire:add_collision_test("touching", function(fire, entity)

  local map = fire:get_map()

  if entity:get_type() == "destructible" then
    if not is_bush(entity) then
      return
    end
    local bush = entity
    
    local bush_sprite = get_destructible_sprite(bush)
    if bush_sprite:get_animation() ~= "on_ground" then
      -- Possibly already being destroyed.
      return
    end

    fire:stop_movement()
    sprite:set_animation("stopped")
    sol.audio.play_sound("lamp")

    -- TODO remove this when the engine provides a function destructible:destroy()
    local bush_sprite_id = bush_sprite:get_animation_set()
    local bush_x, bush_y, bush_layer = bush:get_position()
    local treasure = { bush:get_treasure() }
    if treasure ~= nil then
      local pickable = map:create_pickable({
        x = bush_x,
        y = bush_y,
        layer = bush_layer,
        treasure_name = treasure[1],
        treasure_variant = treasure[2],
        treasure_savegame_variable = treasure[3],
      })
    end

    sol.audio.play_sound(bush:get_destruction_sound())
    bush:remove()

    local bush_destroyed_sprite = fire:create_sprite(bush_sprite_id)
    local x, y = fire :get_position()
    bush_destroyed_sprite:set_xy(bush_x - x, bush_y - y)
    bush_destroyed_sprite:set_animation("destroy")
  end
end)

-- Hurt enemies.
fire:add_collision_test("sprite", function(fire, entity)

  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_fire_reaction(enemy_sprite)
    enemy:receive_attack_consequence("fire", reaction)

    sol.timer.start(fire, 200, function()
      fire:remove()
    end)
  end
end)

function fire:on_obstacle_reached()

  fire:remove()
end
