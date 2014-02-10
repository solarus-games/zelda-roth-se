local cliff = ...

local function cliff_collision(cliff, entity)

  if entity:get_type() ~= "arrow" then
    return
  end

  local x, y, layer = entity:get_position()
  entity:set_position(x, y, layer + 1)
end

cliff:add_collision_test("overlapping", cliff_collision)
cliff:add_collision_test("facing", cliff_collision)

