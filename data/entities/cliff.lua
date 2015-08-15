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
    enemy = true,
  }

  local entity_type = entity:get_type()
  if not entity_types_allowed[entity_type] then
    return false
  end

  if entity_type == "custom_entity" then
    -- Apply the layer to custom entities only if they are okay with that.
    if not entity.apply_cliffs then
      return
    end
  end

  if entity_type == "enemy" then
    -- Cross cliffs for flying enemies only.
    if entity:get_obstacle_behavior() ~= "flying" then
      return
    end
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

  if entity_direction4 == cliff_direction4 then

    -- Same direction: go up one layer if possible.

    entity.cliffs_traversed = entity.cliffs_traversed or {}
    entity.cliffs_traversed_back = entity.cliffs_traversed_back or {}

    if entity.cliffs_traversed[cliff] then
      -- This cliff was already applied.
      return
    end

    local done = false
    if #entity.cliffs_traversed == #entity.cliffs_traversed_back then
      if layer < 2
          and layer == cliff_layer
          and not entity:test_obstacles(0, 0, layer + 1) then
        entity:set_position(x, y, layer + 1)
        done = true
      end
    else
      done = true
    end

    -- Mark this cliff as traversed.
    if done then
      entity.cliffs_traversed[cliff] = true
    end

  elseif entity_direction4 == (cliff_direction4 + 2) % 4 then

    -- Opposite direction: go down one layer if possible.

    entity.cliffs_traversed = entity.cliffs_traversed or {}
    entity.cliffs_traversed_back = entity.cliffs_traversed_back or {}

    if entity.cliffs_traversed_back[cliff] then
      -- This cliff was already applied.
      return
    end

    local done = false
    if #entity.cliffs_traversed == 0 or #entity.cliffs_traversed_back == #entity.cliffs_traversed - 1 then
      if layer > 0
          and layer == cliff_layer + 1
          and not entity:test_obstacles(0, 0, cliff_layer) then
        entity:set_position(x, y, cliff_layer)
        done = true
      end
    else
      done = true
    end

    -- Mark this cliff as traversed back.
    if done then
      entity.cliffs_traversed_back = entity.cliffs_traversed_back or {}
      entity.cliffs_traversed_back[cliff] = true
    end

  end
end

cliff:set_layer_independent_collisions(true)
cliff:add_collision_test("overlapping", cliff_collision)
cliff:add_collision_test("facing", cliff_collision)

