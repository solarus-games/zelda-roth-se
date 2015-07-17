-- Script that creates a pause menu for a game.

-- Usage:
-- local pause_manager = require("scripts/menus/pause")
-- local pause_menu = pause_manager:create(game)

local inventory_builder = require("scripts/menus/pause_inventory")
local help_builder = require("scripts/menus/pause_help")

local pause_manager = {}

-- Name of pause submenu in their order.
local submenus_order = {
  inventory = 1,
  help = 2,
}

-- Creates a pause menu for the specified game.
function pause_manager:create(game)

  local pause_menu = {}
  local pause_submenus
  local submenu_index

  local function set_submenu_index(index)

    if pause_submenus[submenu_index] ~= nil then
      sol.menu.stop(pause_submenus[submenu_index])
    end
    submenu_index = index
    game:set_value("pause_last_submenu", index)
    sol.menu.start(pause_menu, pause_submenus[index], false)
  end

  function pause_menu:on_started()

    -- Define the available submenus.

    -- Array of submenus (inventory, map, etc.).
    pause_submenus = {}
    pause_submenus[submenus_order.inventory] = inventory_builder:new(game)
    pause_submenus[submenus_order.help] = help_builder:new(game)
    -- TODO Add other pause submenus here:
    -- - monsters
    -- - map

    -- Play the sound of pausing the game.
    sol.audio.play_sound("pause_open")

    -- Show the inventory initially.
    set_submenu_index(submenus_order.inventory)
  end

  function pause_menu:on_finished()
    pause_submenus = nil
  end

  function pause_menu:next_submenu()

    sol.audio.play_sound("pause_closed")
    set_submenu_index((submenu_index % #pause_submenus) + 1)
  end

  function pause_menu:previous_submenu()

    sol.audio.play_sound("pause_closed")
    set_submenu_index((submenu_index + 2) % #pause_submenus + 1)
  end

  function pause_menu:switch_submenu(submenu_name)

    local index = submenus_order[submenu_name]
    if index == nil then
      return
    end
    if game:is_paused() and submenu_index == index then
      -- Already the active one: close it.
        sol.audio.play_sound("pause_closed")
        game:set_paused(false)
    else
      -- Open the specified submenu.
      if not game:is_paused() then
        game:set_paused(true)
      else
        sol.audio.play_sound("pause_closed")
      end
      if submenu_index ~= index then
        set_submenu_index(index)
      end
    end
  end

  function pause_menu:close()
    sol.menu.stop(pause_menu)
  end

  function pause_menu:on_command_pressed(command)

    local handled = false
    if command == "left" then
      pause_menu:previous_submenu()
      handled = true
    elseif command == "right" then
      pause_menu:next_submenu()
      handled = true
    elseif command == "pause" then
      sol.audio.play_sound("pause_closed")
      game:set_paused(false)
      handled = true
    end
    return handled
  end

  return pause_menu
end

return pause_manager
