-- Script that creates a pause menu for a game.

-- Usage:
-- local pause_manager = require("scripts/menus/pause")
-- local pause_menu = pause_manager:create(game)

local inventory_builder = require("scripts/menus/pause_inventory")
local help_builder = require("scripts/menus/pause_help")

local pause_manager = {}

-- Creates a pause menu for the specified game.
function pause_manager:create(game)

  local pause_menu = {}
  local pause_submenus
  local submenu_index

  function pause_menu:on_started()

    -- Define the available submenus.

    pause_submenus = {  -- Array of submenus (inventory, map, etc.).
      inventory_builder:new(game),
      help_builder:new(game),
      -- For now there is only the inventory submenu.
      -- TODO Add other pause submenus here:
      -- - monsters
      -- - map
      -- - options
    }

    -- Select the submenu that was saved if any.
    submenu_index = game:get_value("pause_last_submenu") or 1
    if submenu_index <= 0
        or submenu_index > #pause_submenus then
      submenu_index = 1
    end
    game:set_value("pause_last_submenu", submenu_index)

    -- Play the sound of pausing the game.
    sol.audio.play_sound("pause_open")

    -- Start the selected submenu.
    sol.menu.start(pause_menu, pause_submenus[submenu_index])
  end

  function pause_menu:on_finished()
    pause_submenus = nil
  end

  function pause_menu:next_submenu()

    sol.audio.play_sound("pause_closed")
    sol.menu.stop(pause_submenus[submenu_index])
    submenu_index = (submenu_index % #pause_submenus) + 1
    game:set_value("pause_last_submenu", submenu_index)
    sol.menu.start(pause_menu, pause_submenus[submenu_index], false)
  end

  function pause_menu:previous_submenu()

    sol.audio.play_sound("pause_closed")
    sol.menu.stop(pause_submenus[submenu_index])
    submenu_index = (submenu_index + 2) % #pause_submenus + 1
    game:set_value("pause_last_submenu", submenu_index)
    sol.menu.start(pause_menu, pause_submenus[submenu_index], false)
  end

  function pause_menu:on_command_pressed(command)

    local handled = false
    if command == "left" then
      pause_menu:previous_submenu()
    elseif command == "right" then
      pause_menu:next_submenu()
    end
    return handled
  end

  return pause_menu
end

return pause_manager
