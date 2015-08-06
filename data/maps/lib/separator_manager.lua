-- This script manages enemies when there are separators in a map.
-- Enemies that are prefixed by "auto_enemy" and destructibles that are prefixed
-- by "auto_destructible" are automatically
-- destroyed and recreated when taking separators prefixed by "auto_separator".

local separator_manager = {}

function separator_manager:manage_map(map)

  local enemy_places = {}
  local destructible_places = {}

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
        enemy:set_treasure(unpack(enemy_place.treasure))
        enemy_place.enemy = enemy
      end
    end
  end

  -- Function called when a separator is being taken.
  local function separator_on_activating(separator)

    local hero = map:get_hero()

    -- Enemies.
    if not map.used_separator then
      -- First separator: remove enemies from other regions like on_activated() does.
      -- Because on_activated() was not called when the map started.
      for _, enemy_place in ipairs(enemy_places) do
        local enemy = enemy_place.enemy
        if enemy:exists() and not enemy:is_in_same_region(hero) then
          enemy:remove()
        end
      end
    end

    -- Destructibles.
    for _, destructible_place in ipairs(destructible_places) do
      local destructible = destructible_place.destructible

      if not destructible:exists() then
        -- Re-create destructibles in all regions except the active one.
        if not destructible:is_in_same_region(hero) then
          local destructible = map:create_destructible({
            x = destructible_place.x,
            y = destructible_place.y,
            layer = destructible_place.layer,
            name = destructible_place.name,
            sprite = destructible_place.sprite,
            destruction_sound = destructible_place.destruction_sound,
            weight = destructible_place.weight,
            can_be_cut = destructible_place.can_be_cut,
            can_explode = destructible_place.can_explode,
            can_regenerate = destructible_place.can_regenerate,
            damage_on_enemies = destructible_place.damage_on_enemies,
            ground = destructible_place.ground,
          })
          -- We don't recreate the treasure.
          destructible_place.destructible = destructible
        end
      end
    end
  end

  for separator in map:get_entities("auto_separator") do
    separator.on_activating = separator_on_activating
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
      treasure = { enemy:get_treasure() },
      enemy = enemy,
    }
  end

  local function get_destructible_sprite_name(destructible)
    -- TODO the engine should have a destructible:get_sprite() method.
    -- As a temporary workaround we use the one of custom entity, fortunately
    -- it happens to work for all types of entities.
    local sprite = sol.main.get_metatable("custom_entity").get_sprite(destructible)
    return sprite ~= nil and sprite:get_animation_set() or ""
  end

  -- Store the position and properties of destructibles.
  for destructible in map:get_entities("auto_destructible") do
    local x, y, layer = destructible:get_position()
    destructible_places[#destructible_places + 1] = {
      x = x,
      y = y,
      layer = layer,
      name = destructible:get_name(),
      treasure = { destructible:get_treasure() },
      sprite = get_destructible_sprite_name(destructible),
      destruction_sound = destructible:get_destruction_sound(),
      weight = destructible:get_weight(),
      can_be_cut = destructible:get_can_be_cut(),
      can_explode = destructible:get_can_explode(),
      can_regenerate = destructible:get_can_regenerate(),
      damage_on_enemies = destructible:get_damage_on_enemies(),
      ground = destructible:get_modified_ground(),
      destructible = destructible,
    }
  end
end

return separator_manager

