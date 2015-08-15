-- Main Lua script of the quest.

local game_manager = require("scripts/game_manager")
local debug = require("scripts/debug")
local quest_manager = require("scripts/quest_manager")

local language_menu = require("scripts/menus/language")
local solarus_logo = require("scripts/menus/solarus_logo")
local presentation_screen = require("scripts/menus/presentation_screen")
local title_screen = require("scripts/menus/title_screen")
local savegames_menu = require("scripts/menus/savegames")

function sol.main:on_started()

  math.randomseed(os.time())

  -- Make quest-specific initializations.
  quest_manager:initialize_quest()

  -- Load built-in settings (audio volume, video mode, etc.).
  sol.main.load_settings()

  -- If there is a file called "debug" in the write directory,
  -- enable debugging features.
  if sol.file.exists("debug") then
    sol.menu.start(self, debug)
  end

  -- Show the Solarus logo initially.
  sol.menu.start(self, solarus_logo)

  solarus_logo.on_finished = function()
    sol.menu.start(self, language_menu)
  end

  language_menu.on_finished = function()
    sol.menu.start(self, presentation_screen)
  end

  presentation_screen.on_finished = function()
    sol.menu.start(self, title_screen)
  end

  title_screen.on_finished = function()
    sol.menu.start(self, savegames_menu)
  end

end

-- Event called when the program stops.
function sol.main:on_finished()

  sol.main.save_settings()
end

-- Event called when the player pressed a keyboard key.
function sol.main:on_key_pressed(key, modifiers)

  local handled = false
  if key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    sol.video.set_fullscreen(not sol.video.is_fullscreen())
    handled = true
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "escape" and sol.main.game == nil then
    -- Escape in title screens: stop the program.
    sol.main.exit()
    handled = true
  end

  return handled
end

-- Starts a game.
function sol.main:start_savegame(game)

  -- Skip initial menus if any.
  sol.menu.stop(solarus_logo)
  sol.menu.stop(presentation_screen)
  sol.menu.stop(title_screen)
  sol.menu.stop(savegames_menu)

  sol.main.game = game
  game:start()
end

