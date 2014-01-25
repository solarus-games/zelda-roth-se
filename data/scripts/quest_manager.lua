-- This script handles global behavior of this quest,
-- that is, things not related to a particular savegame.
local quest_manager = {}

-- Initializes map entity related behaviors.
local function initialize_entities()

  -- Nothing to do in this quest.
  -- Destructibles don't show dialogs when the hero fails to lift or cut them.
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

