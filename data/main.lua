-- Main Lua script of the quest.

local game_manager = require("scripts/game_manager")
local debug = require("scripts/debug")
local quest_manager = require("scripts/quest_manager")

local initial_menus  -- Menus before starting a game.

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
  initial_menus = {
    solarus_logo,
    presentation_screen,
    title_screen
  }

  -- Show the Solarus logo initially.
  local current_menu = initial_menus[1]
  sol.menu.start(self, current_menu)
  for i, menu in ipairs(initial_menus) do
    if i ~= 1 then
      current_menu.on_finished = function()
        sol.menu.start(self, menu)
      end
      current_menu = menu
    end
  end

  initial_menus[#initial_menus].on_finished = function()
    sol.main:start_savegame(game_manager:create("save1.dat"))
  end

end

-- Starts a game.
function sol.main:start_savegame(game)

  for _, menu in ipairs(initial_menus) do
    sol.menu.stop(menu)
  end

  sol.main.game = game
  game:start()
end

