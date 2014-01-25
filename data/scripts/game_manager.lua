-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()

local game_manager = {}

-- Creates a game ready to be played.
function game_manager:create(file)

  -- Create the game (but do not start it).
  local exists = sol.game.exists(file)
  local game = sol.game.load(file)
  if not exists then
    -- This is a new savegame file.
    game:set_starting_location("outside_c1", "from_link_house")
    game:set_max_money(100)  -- TODO check this
    game:set_max_life(12)
    game:set_life(game:get_max_life())
  end
 
  local dialog_box_manager = require("scripts/dialog_box")
  local dialog_box

  -- Function called when the player runs this game.
  function game:on_started()

    -- Prepare the dialog box menu.
    dialog_box = dialog_box_manager:create(game)

    -- Initialize the hero.
    game:get_hero():set_walking_speed(96)
  end

  -- Function called when the game stops.
  function game:on_finished()

    -- Clean the dialog box.
    dialog_box:quit()
    dialog_box = nil
  end

  function game:get_dialog_box()
    return dialog_box
  end

  return game
end

return game_manager

