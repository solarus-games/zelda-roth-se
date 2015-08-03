-- This script handles global behavior of this quest,
-- that is, things not related to a particular savegame.
local quest_manager = {}

-- Initialize dynamic tile behavior specific to this quest.
local function initialize_dynamic_tile()

  local dynamic_tile_meta = sol.main.get_metatable("dynamic_tile")

  function dynamic_tile_meta:on_created()

    local name = self:get_name()

    if name:match("^invisible_tile") then
      self:set_visible(false)
    end
  end
end

-- Initialize enemy behavior specific to this quest.
local function initialize_enemy()

  local enemy_meta = sol.main.get_metatable("enemy")

  -- Redefine how to calculate the damage inflicted by the sword.
  function enemy_meta:on_hurt_by_sword(hero, enemy_sprite)

    local force = hero:get_game():get_value("force")
    local reaction = self:get_attack_consequence_sprite(enemy_sprite, "sword")
    -- Multiply the sword consequence by the force of the hero.
    local life_lost = reaction * force
    if hero:get_state() == "spin_attack" then
      -- And multiply this by 2 during a spin attack.
      life_lost = life_lost * 2
    end
    self:remove_life(life_lost)
  end

  -- When an enemy is killed, add it to the encyclopedia.
  function enemy_meta:on_dying()

    local breed = self:get_breed()
    local game = self:get_game()
    game:get_item("monsters_encyclopedia"):add_monster_type_killed(breed)
  end

end

-- Initialize hero behavior specific to this quest.
local function initialize_hero()

  -- Redefine how to calculate the damage received by the hero.
  local hero_meta = sol.main.get_metatable("hero")

  function hero_meta:on_taking_damage(damage)

    -- Here, self is the hero.
    local game = self:get_game()

    -- In the parameter, the damage unit is 1/2 of a heart.

    local defense = game:get_value("defense")
    if defense == 0 then
      -- Multiply the damage by two if the hero has no defense at all.
      damage = damage * 2
    else
      damage = damage / defense
    end

    game:remove_life(damage)
  end
end

-- Initialize NPC behavior specific to this quest.
local function initialize_npc()

  local npc_meta = sol.main.get_metatable("npc")

  -- Make signs hooks for the hookshot.
  function npc_meta:is_hook()

    local sprite = self:get_sprite()
    if sprite == nil then
      return false
    end

    return sprite:get_animation_set() == "entities/sign"
  end
end

-- Initialize sensor behavior specific to this quest.
local function initialize_sensor()

  local sensor_meta = sol.main.get_metatable("sensor")

  function sensor_meta:on_activated()

    local hero = self:get_map():get_hero()
    local game = self:get_game()
    local name = self:get_name()

    -- Sensors named "to_layer_X_sensor" move the hero on that layer.
    -- TODO use a custom entity or a wall to block enemies and thrown items?
    if name:match("^layer_up_sensor") then
      local x, y, layer = hero:get_position()
      if layer < 2 then
        hero:set_position(x, y, layer + 1)
      end
    elseif name:match("^layer_down_sensor") then
      local x, y, layer = hero:get_position()
      if layer > 0 then
        hero:set_position(x, y, layer - 1)
      end
    end

    -- Sensors prefixed by "dungeon_room_N" save the exploration state of the
    -- room "N" of the current dungeon floor.
    local room = name:match("^dungeon_room_(%d+)")
    if room ~= nil then
      game:set_explored_dungeon_room(nil, nil, tonumber(room))
      self:remove()
    end
  end
end

-- Initializes map entity related behaviors.
local function initialize_entities()

  initialize_dynamic_tile()
  initialize_enemy()
  initialize_hero()
  initialize_npc()
  initialize_sensor()
end

-- Performs global initializations specific to this quest.
function quest_manager:initialize_quest()

  initialize_entities()
end

-- Returns the id of the font and size to use for the dialog box
-- depending on the current language.
function quest_manager:get_dialog_font()

  -- This quest uses the "alttp" bitmap font (and therefore no size)
  -- no matter the current language.
  return "alttp", nil
end

return quest_manager

