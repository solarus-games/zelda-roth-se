-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/solarus/documentation/

-- This is just an example of quest that shows the Solarus logo
-- and then does nothing.
-- Feel free to change this!

local game_manager = require("scripts/game_manager")

function sol.main:on_started()

  -- Setting a language is useful to display text and dialogs.
  sol.language.set_language("fr")

  local solarus_logo = require("menus/solarus_logo")
  local presentation_screen = require("menus/presentation_screen")
  local title_screen = require("menus/title_screen")

  -- Show the Solarus logo initially.
  sol.menu.start(self, solarus_logo)
  solarus_logo.on_finished = function()
    sol.menu.start(self, presentation_screen)
  end

  presentation_screen.on_finished = function()
    sol.menu.start(self, title_screen)
  end

  title_screen.on_finished = function()
    local game = game_manager:create("save1.dat")
    game:start()
  end

end

