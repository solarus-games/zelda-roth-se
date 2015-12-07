local item = ...

-- When it is created, this item creates another item randomly chosen
-- and then destroys itself.
-- The random item is often some weapons.

-- Probability of each item between 0 and 1000.
local probabilities = {
  [{ "bomb", 1 }]       = 150,  -- 1 bomb.
  [{ "bomb", 2 }]       = 75,   -- 3 bombs.
  [{ "bomb", 3 }]       = 25,   -- 8 bombs.
  [{ "arrow", 1 }]      = 150,  -- 1 arrow.
  [{ "arrow", 2 }]      = 75,   -- 5 arrows.
  [{ "arrow", 3 }]      = 25,   -- 10 arrows.
  [{ "rupee", 1 }]      = 100,  -- 1 rupee.
  [{ "rupee", 2 }]      = 50,   -- 5 rupees.
  [{ "rupee", 3 }]      = 25,   -- 20 rupees.
  [{ "magic_flask", 1}] = 25,   -- Small magic jar.
  [{ "magic_flask", 2}] = 8,    -- Big magic jar.
  [{ "heart", 1}]       = 5,    -- Heart.
}

function item:on_pickable_created(pickable)

  local treasure_name, treasure_variant = self:choose_random_item()
  if treasure_name ~= nil then
    local map = pickable:get_map()
    local x, y, layer = pickable:get_position()
    map:create_pickable{
      layer = layer,
      x = x,
      y = y,
      treasure_name = treasure_name,
      treasure_variant = treasure_variant,
    }
  end
  pickable:remove()
end

-- Returns an item name and variant.
function item:choose_random_item()

  local random = math.random(1000)
  local sum = 0

  for key, probability in pairs(probabilities) do
    sum = sum + probability
    if random < sum then
      return key[1], key[2]
    end
  end

  return nil
end

