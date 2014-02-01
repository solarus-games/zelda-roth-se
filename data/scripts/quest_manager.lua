-- This script handles global behavior of this quest,
-- that is, things not related to a particular savegame.
local quest_manager = {}

-- Initializes map entity related behaviors.
local function initialize_entities()

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

-- Performs global initializations specific to this quest.
function quest_manager:initialize_quest()

  initialize_entities()
end

-- Returns the id of the font to use for the dialog box
-- depending on the current language.
function quest_manager:get_dialog_font()

  -- This quest use the "alttp" bitmap font,
  -- no matter the current language.
  return "alttp"
end

return quest_manager

