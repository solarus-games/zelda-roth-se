-- A torch that can be lit by fire and unlit by ice.
-- The initial state depends on the direction: unlit if direction 0, lit otherwise.
local torch = ...
local sprite

function torch:on_created()

  torch:set_size(16, 16)
  torch:set_origin(8, 13)
  torch:set_traversable_by(false)
  if torch:get_sprite() == nil then
    torch:create_sprite("entities/torch")
  end
  sprite = torch:get_sprite()
  local lit = torch:get_direction() ~= 0
  sprite:set_direction(0)
  torch:set_lit(lit)
end

function torch:is_lit()
  return sprite:get_animation() == "lit"
end

function torch:set_lit(lit)

  if lit then
    sprite:set_animation("lit")
  else
    sprite:set_animation("unlit")
  end
end

local function on_collision(torch, other, torch_sprite, other_sprite)

  if other:get_type() ~= "custom_entity" then
    return
  end

  local other_model = other:get_model()
  if other_model == "fire" then
    if not torch:is_lit() then
      torch:set_lit(true)
    end
    other:remove()
  elseif other_model == "ice_beam" then
    if torch:is_lit() then
      torch:set_lit(false)
    end
    other:remove()
  end
end

torch:set_traversable_by("custom_entity", function(torch, other)
  return other:get_model() == "fire" or other:get_model() == "ice"
end)

torch:add_collision_test("sprite", on_collision)
torch:add_collision_test("overlapping", on_collision)
