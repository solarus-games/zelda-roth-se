-- This script handles global behavior of this quest,
-- that is, things not related to a particular savegame.
local quest_manager = {}

-- Initialize hero behavior specific to this quest.
local function initialize_hero()

  -- Redefine how to calculate the damage received by the hero.
  local hero_meta = sol.main.get_metatable("hero")

  function hero_meta:on_taking_damage(damage)

    -- Here, self is the hero.
    local game = self:get_game()

    -- In the parameter, the damage unit is 1/4 of a heart.

    local defense = game:get_value("defense") or 0
    if defense == 0 then
      -- Multiply the damage by two if the hero has no defense at all.
      damage = damage * 2
    else
      damage = damage / defense
    end

    game:remove_life(damage)
  end
end

-- Initialize sensor behavior specific to this quest.
local function initialize_sensor()

  local sensor_meta = sol.main.get_metatable("sensor")

  function sensor_meta:on_activated()

    local hero = self:get_map():get_hero()
    local name = self:get_name()

    -- Sensors named "to_layer_X_sensor" move the hero on that layer.
    -- TODO a custom entity or a wall to block enemies and thrown items?
    local layer = name:match("^to_layer_([0-9])_sensor")
    if layer ~= nil then
      local x, y = hero:get_position()
      hero:set_position(x, y, layer)
    end
  end
end

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

-- Initializes map entity related behaviors.
local function initialize_entities()

  initialize_hero()
  initialize_sensor()
  initialize_dynamic_tile()
end

-- Performs global initializations specific to this quest.
function quest_manager:initialize_quest()

  initialize_entities()
end

-- Returns the id of the font to use for the dialog box
-- depending on the current language.
function quest_manager:get_dialog_font()

  -- This quest uses the "alttp" bitmap font,
  -- no matter the current language.
  return "alttp"
end

return quest_manager

