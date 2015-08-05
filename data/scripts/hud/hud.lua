-- Script that creates a head-up display for a game.

-- Usage:
-- local hud_manager = require("scripts/hud/hud")
-- local hud = hud_manager:create(game)

local hud_manager = {}

-- Creates and runs a HUD for the specified game.
function hud_manager:create(game)

  -- Set up the HUD.
  local hud = {
    enabled = false,
    elements = {},
  }

  -- Create each element of the HUD.
  local hearts_builder = require("scripts/hud/hearts")
  local rupees_builder = require("scripts/hud/rupees")
  local bombs_builder = require("scripts/hud/bombs")
  local arrows_builder = require("scripts/hud/arrows")
  local item_builder = require("scripts/hud/item")
  local magic_bar_builder = require("scripts/hud/magic_bar")
  local small_keys_builder = require("scripts/hud/small_keys")
  local boss_life_builder = require("scripts/hud/boss_life")

  local hearts = hearts_builder:new(game)
  hearts:set_dst_position(-88, 0)
  hud.elements[#hud.elements + 1] = hearts

  local rupees = rupees_builder:new(game)
  rupees:set_dst_position(121, 10)
  hud.elements[#hud.elements + 1] = rupees

  local bombs = bombs_builder:new(game)
  bombs:set_dst_position(153, 10)
  hud.elements[#hud.elements + 1] = bombs

  local arrows = arrows_builder:new(game)
  arrows:set_dst_position(178, 10)
  hud.elements[#hud.elements + 1] = arrows

  local item = item_builder:new(game, 1)
  item:set_dst_position(27, 15)
  hud.elements[#hud.elements + 1] = item

  local magic_bar = magic_bar_builder:new(game, 1)
  magic_bar:set_dst_position(10, 8)
  hud.elements[#hud.elements + 1] = magic_bar

  local small_keys = small_keys_builder:new(game)
  small_keys:set_dst_position(88, 10)
  hud.elements[#hud.elements + 1] = small_keys

  local boss_life = boss_life_builder:new(game)
  boss_life:set_dst_position(110, 220)
  hud.elements[#hud.elements + 1] = boss_life

  -- Destroys the HUD.
  function hud:quit()

    if hud:is_enabled() then
      -- Stop all HUD elements.
      hud:set_enabled(false)
    end
  end

  -- Call this function to notify the HUD that the current map has changed.
  function hud:on_map_changed(map)

    if hud:is_enabled() then
      for _, menu in ipairs(hud.elements) do
        if menu.on_map_changed ~= nil then
          menu:on_map_changed(map)
        end
      end
    end
  end

  -- Call this function to notify the HUD that the game was just paused.
  function hud:on_paused()

    if hud:is_enabled() then
      for _, menu in ipairs(hud.elements) do
        if menu.on_paused ~= nil then
          menu:on_paused()
        end
      end
    end
  end

  -- Call this function to notify the HUD that the game was just unpaused.
  function hud:on_unpaused()

    if hud:is_enabled() then
      for _, menu in ipairs(hud.elements) do
        if menu.on_unpaused ~= nil then
          menu:on_unpaused()
        end
      end
    end
  end

  -- Returns whether the HUD is currently enabled.
  function hud:is_enabled()
    return hud.enabled
  end

  -- Enables or disables the HUD.
  function hud:set_enabled(enabled)

    if enabled ~= hud.enabled then
      hud.enabled = enabled

      for _, menu in ipairs(hud.elements) do
        if enabled then
          -- Start each HUD element.
          sol.menu.start(game, menu)
        else
          -- Stop each HUD element.
          sol.menu.stop(menu)
        end
      end
    end
  end

  -- Start the HUD.
  hud:set_enabled(true)

  -- Return the HUD.
  return hud
end

return hud_manager


