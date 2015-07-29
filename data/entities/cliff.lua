local cliff = ...

-- This entity changes the layer of projectiles like
-- arrows, the hookshot and the boomerang when they overlap it.
-- If the projectile has the same direction as the cliff,
-- it goes up one layer.
-- If the projectile has the opposite direction,
-- it goes down one layer.

local function cliff_collision(cliff, entity)

  local entity_types_allowed = {
    arrow = true,
    hookshot = true,
    boomerang = true,
    custom_entity = true,
  }

  local entity_type = entity:get_type()
  if not entity_types_allowed[entity_type] then
    return
  end

  if entity_type == "custom_entity" then
    -- The only custom entity allowed is the hookshot.
    local sprite = entity:get_sprite()
    if sprite == nil or sprite:get_animation_set() ~= "entities/hookshot" then
      return
    end
  end

  local movement = entity:get_movement()
  if movement == nil then
    -- Not moving.
    return
  end

  if entity.cliffs_traversed ~= nil and entity.cliffs_traversed[cliff] then
    -- This cliff was already applied.
    return
  end

  local cliff_direction4 = cliff:get_direction()
  local entity_direction4 = movement:get_direction4()
  local x, y, layer = entity:get_position()
  local _, _, cliff_layer = cliff:get_position()
  local done = false

  if entity_direction4 == cliff_direction4 then

    -- Same direction: go up one layer if possible.
    entity.cliff_count = entity.cliff_count or 0
    if entity.cliff_count == 0 then
      if layer < 2
        and layer == cliff_layer
        and not entity:test_obstacles(0, 0, layer + 1) then
        done = true
        entity.cliff_count = entity.cliff_count + 1
        entity:set_position(x, y, layer + 1)
      end
    else
      entity.cliff_count = entity.cliff_count + 1
      done = true
    end

  elseif entity_direction4 == (cliff_direction4 + 2) % 4 then

    -- Opposite direction: go down one layer if possible.
    if entity.cliff_count == 1 then
      if layer > 0
        and layer == cliff_layer + 1
        and not entity:test_obstacles(0, 0, cliff_layer) then
        done = true
        entity.cliff_count = entity.cliff_count - 1
        entity:set_position(x, y, cliff_layer)
      end
    else
      done = true
      entity.cliff_count = entity.cliff_count - 1
    end

  end

  -- Mark this cliff as traversed.
  if done then
    if entity.cliffs_traversed == nil then
      entity.cliffs_traversed = {}
    end
    entity.cliffs_traversed[cliff] = true
  end
end

cliff:set_layer_independent_collisions(true)
cliff:add_collision_test("overlapping", cliff_collision)
cliff:add_collision_test("facing", cliff_collision)

