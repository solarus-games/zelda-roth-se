-- Main Lua script of the quest.

local game_manager = require("scripts/game_manager")
local debug = require("scripts/debug")
local quest_manager = require("quest_manager")

function sol.main:on_started()

  -- Make quest-specific initializations.
  quest_manager:initialize_quest()

  -- If there is a file called "debug" in the write directory,
  -- enable debugging features.
  if sol.file.exists("debug") then
    sol.menu.start(self, debug)
  end

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
    sol.main:start_savegame(game_manager:create("save1.dat"))
  end

end

-- Starts a game.
function sol.main:start_savegame(game)

  sol.main.game = game
  game_manager:play_game(game)
end

