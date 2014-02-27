-- Script that creates a pause menu for a game.

-- Usage:
-- local pause_manager = require("scripts/menus/pause")
-- local pause_menu = pause_manager:create(game)

local inventory_builder = require("scripts/menus/pause_inventory")

local pause_manager = {}

-- Creates a pause menu for the specified game.
function pause_manager:create(game)

  local pause_menu = {}
  local pause_submenus

  function pause_menu:on_started()

    -- Define the available submenus.

    pause_submenus = {  -- Array of submenus (inventory, map, etc.).
      inventory_builder:new(game),
      -- For now there is only the inventory submenu.
      -- TODO Add other pause submenus here:
      -- - monsters
      -- - help
      -- - map
      -- - options
    }

    -- Select the submenu that was saved if any.
    local submenu_index = game:get_value("pause_last_submenu") or 1
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

  return pause_menu
end

return pause_manager


