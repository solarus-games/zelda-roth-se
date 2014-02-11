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
  }

  if not entity_types_allowed[entity:get_type()] then
    return
  end

  local movement = entity:get_movement()
  if movement == nil then
    -- Not moving.
    return
  end

  local cliff_direction4 = cliff:get_direction()
  local entity_direction4 = movement:get_direction4()
  local x, y, layer = entity:get_position()
  local _, _, cliff_layer = cliff:get_position()

  if entity_direction4 == cliff_direction4
    and layer == cliff_layer
    and not entity:test_obstacles(0, 0, layer + 1) then
    -- Same direction: go up one layer if possible.
    if layer < 2 then
      entity:set_position(x, y, layer + 1)
    end

  elseif entity_direction4 == (cliff_direction4 + 2) % 4
    and layer == cliff_layer + 1
    and not entity:test_obstacles(0, 0, cliff_layer) then
    -- Opposite direction: go down one layer if possible.
    if layer > 0 then
      entity:set_position(x, y, cliff_layer)
    end
  end
end

cliff:set_layer_independent_collisions(true)
cliff:add_collision_test("overlapping", cliff_collision)
cliff:add_collision_test("facing", cliff_collision)

