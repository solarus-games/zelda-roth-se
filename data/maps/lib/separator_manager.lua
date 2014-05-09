-- This script manages enemies when there are separators in a map.
-- Enemies that are prefixed by "auto_enemy" are automatically
-- destroyed and recreated when taking separators prefixed by "auto_separator".

local separator_manager = {}

function separator_manager:manage_map(map)

  local enemy_places = {}

  -- Function called when a separator was just taken.
  local function separator_on_activated(separator)

    local hero = map:get_hero()
    for _, enemy_place in ipairs(enemy_places) do
      local enemy = enemy_place.enemy

      -- First remove any enemy.
      if enemy:exists() then
        enemy:remove()
      end

      -- Re-create enemies in the new active region.
      if enemy:is_in_same_region(hero) then
        local enemy = map:create_enemy({
          x = enemy_place.x,
          y = enemy_place.y,
          layer = enemy_place.layer,
          breed = enemy_place.breed,
          direction = enemy_place.direction,
          name = enemy_place.name,
        })
        enemy_place.enemy = enemy
      end

    end

  end

  for separator in map:get_entities("auto_separator") do
    separator.on_activated = separator_on_activated
  end

  -- Store the position and properties of enemies.
  for enemy in map:get_entities("auto_enemy") do
    local x, y, layer = enemy:get_position()
    enemy_places[#enemy_places + 1] = {
      x = x,
      y = y,
      layer = layer,
      breed = enemy:get_breed(),
      direction = enemy:get_sprite():get_direction(),
      name = enemy:get_name(),
      enemy = enemy,
      -- TODO treasure
    }
  end
end

return separator_manager

