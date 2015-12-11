-- This script handles global behavior of this quest,
-- that is, things not related to a particular savegame.
local quest_manager = {}

-- Initialize dynamic tile behavior specific to this quest.
local function initialize_dynamic_tile()

  local dynamic_tile_meta = sol.main.get_metatable("dynamic_tile")

  function dynamic_tile_meta:on_created()

    local name = self:get_name()
    if name == nil then
      return
    end

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
    if hero:get_state() == "sword spin attack" then
      -- And multiply this by 2 during a spin attack.
      life_lost = life_lost * 2
    end
    self:remove_life(life_lost)
  end

  -- When an enemy is killed, add it to the encyclopedia.
  function enemy_meta:on_removed()

    if self:get_life() <= 0 then
      local breed = self:get_breed()
      local game = self:get_game()
      game:get_item("monsters_encyclopedia"):add_monster_type_killed(breed)
    end
  end

  -- Helper function to inflict an explicit reaction from a scripted weapon.
  -- TODO this should be in the Solarus API one day
  function enemy_meta:receive_attack_consequence(attack, reaction)

    if type(reaction) == "number" then
      self:hurt(reaction)
    elseif reaction == "immobilized" then
      self:immobilize()
    elseif reaction == "protected" then
      sol.audio.play_sound("sword_tapping")
    elseif reaction == "custom" then
      if self.on_custom_attack_received ~= nil then
        self:on_custom_attack_received(attack)
      end
    end

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
      damage = math.floor(damage / defense)
      if damage <= 0 then
        damage = 1
      end
    end

    game:remove_life(damage)
  end

  -- Redefine what happens when drowning: we don't want to jump.
  function hero_meta:on_state_changed(state)

    if state == "jumping" then
      local x, y, layer = self:get_position()
      local map = self:get_map()
      if map:get_ground(x, y - 2, layer) == "deep_water" then
        -- Starting a jump from water: this is the built-in jump of the engine
        -- does not have the ability to swim.
        -- TODO this is a hack, improve this when the engine allows to customize drowning.
        sol.timer.start(map, 1, function()
          local movement = self:get_movement()
          movement:set_distance(1)
        end)
      end

    elseif state == "hurt" then
      local game = self:get_game()
      if game:is_rabbit() then
        game:stop_rabbit()
      end
    end
  end
end

-- Initialize NPC behavior specific to this quest.
local function initialize_npc()

  local npc_meta = sol.main.get_metatable("npc")

  -- Make signs hooks for the hookshot.
  function npc_meta:is_hookable()

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
    local map = self:get_map()
    local name = self:get_name()

    -- Sensors named "to_layer_X_sensor" move the hero on that layer.
    -- TODO use a custom entity or a wall to block enemies and thrown items?
    if name:match("^layer_up_sensor") then
      local x, y, layer = hero:get_position()
      if layer < map:get_max_layers() then
        hero:set_position(x, y, layer + 1)
      end
      return
    elseif name:match("^layer_down_sensor") then
      local x, y, layer = hero:get_position()
      if layer > map:get_min_layer() then
        hero:set_position(x, y, layer - 1)
      end
      return
    end

    -- Sensors prefixed by "save_solid_ground_sensor" are where the hero come back
    -- when falling into a hole or other bad ground.
    if name:match("^save_solid_ground_sensor") then
      hero:save_solid_ground()
      return
    end
 
    -- Sensors prefixed by "reset_solid_ground_sensor" clear any place for the hero
    -- to come back when falling into a hole or other bad ground.
    if name:match("^reset_solid_ground_sensor") then
      hero:reset_solid_ground()
      return
    end
 
    -- Sensors prefixed by "dungeon_room_N" save the exploration state of the
    -- room "N" of the current dungeon floor.
    local room = name:match("^dungeon_room_(%d+)")
    if room ~= nil then
      game:set_explored_dungeon_room(nil, nil, tonumber(room))
      self:remove()
      return
    end

    -- Sensors named "open_quiet_X_sensor" silently open doors prefixed with "X".
    local door_prefix = name:match("^open_quiet_([a-zA-X0-9_]+)_sensor")
    if door_prefix ~= nil then
      map:set_doors_open(door_prefix, true)
      return
    end

    -- Sensors named "close_quiet_X_sensor" silently close doors prefixed with "X".
    door_prefix = name:match("^close_quiet_([a-zA-X0-9_]+)_sensor")
    if door_prefix ~= nil then
      map:set_doors_open(door_prefix, false)
      return
    end

    -- Sensors named "open_loud_X_sensor" open doors prefixed with "X".
    local door_prefix = name:match("^open_loud_([a-zA-X0-9_]+)_sensor")
    if door_prefix ~= nil then
      map:open_doors(door_prefix)
      return
    end

    -- Sensors named "close_loud_X_sensor" close doors prefixed with "X".
    door_prefix = name:match("^close_loud_([a-zA-X0-9_]+)_sensor")
    if door_prefix ~= nil then
      map:close_doors(door_prefix)
      return
    end

    -- Sensors named "weak_floor_X_sensor" detect explosions on a weak floor dynamic tile called "weak_floor_x".
    local tile_name = name:match("^weak_floor_([a-zA-X0-9_]+)_sensor")
    if tile_name ~= nil then
      local tile map:get_entity(tile_name)
      if tile ~= nil then
        tile:remove()
      end
      return
    end

  end

  function sensor_meta:on_activated_repeat()

    local hero = self:get_map():get_hero()
    local game = self:get_game()
    local map = self:get_map()
    local name = self:get_name()

    -- Sensors called open_house_xxx_sensor automatically open an outside house door tile.
    local door_name = name:match("^open_house_([a-zA-X0-9_]+)_sensor")
    if door_name ~= nil then
      local door = map:get_entity(door_name)
      if door ~= nil then
        if hero:get_direction() == 1
	         and door:is_enabled() then
          door:set_enabled(false)
          sol.audio.play_sound("door_open")
        end
      end
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

-- Returns the id of the font and size to use in menus
-- depending on the current language.
function quest_manager:get_menu_font()

  -- This quest uses the "alttp" bitmap font (and therefore no size)
  -- no matter the current language.
  return "alttp", nil
end

return quest_manager

