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
  elseif other_model == "ice" then
    if torch:is_lit() then
      torch:set_lit(false)
    end
  end
end

torch:add_collision_test("sprite", on_collision)
torch:add_collision_test("touching", on_collision)

-- Initialize the metatable of appropriate entities to work with the fire.
local function initialize_meta()

  -- Add Lua fire properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_fire_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.fire_reaction = 2  -- 2 life points by default.
  function enemy_meta:get_fire_reaction(sprite)
    return self.fire_reaction
  end

  function enemy_meta:set_fire_reaction(reaction, sprite)
    -- TODO allow to set by sprite
    self.fire_reaction = reaction
  end

  -- Change enemy:set_invincible() to also
  -- take into account the fire.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_fire_reaction("ignored")
  end
end
initialize_meta()
