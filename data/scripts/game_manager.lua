-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()

local dialog_box_manager = require("scripts/dialog_box")
local hud_manager = require("scripts/hud/hud")
local dungeon_manager = require("scripts/dungeons")
local equipment_manager = require("scripts/equipment")

local game_manager = {}

-- Creates a game ready to be played.
function game_manager:create(file)

  -- Game constants.
  local normal_walking_speed = 96
  local fast_walking_speed = 192

  -- Create the game (but do not start it).
  local exists = sol.game.exists(file)
  local game = sol.game.load(file)
  if not exists then
    -- This is a new savegame file.
    game:set_starting_location("intro")
    game:set_max_money(999)
    game:set_max_life(6)
    game:set_life(game:get_max_life())
  end
 
  local dialog_box
  local hud

  -- Function called when the player runs this game.
  function game:on_started()

    dungeon_manager:create(game)
    equipment_manager:create(game)
    dialog_box = dialog_box_manager:create(game)
    hud = hud_manager:create(game)

    -- Initialize the hero.
    game:get_hero():set_walking_speed(normal_walking_speed)
  end

  -- Function called when the game stops.
  function game:on_finished()

    -- Clean the dialog box and the HUD.
    dialog_box:quit()
    dialog_box = nil
    hud:quit()
    hud = nil
  end

  -- Changes the walking speed of the hero depending on whether
  -- shift is pressed or caps lock is active.
  local function update_walking_speed()

    local hero = game:get_hero()
    local modifiers = sol.input.get_key_modifiers()
    local speed = normal_walking_speed
    if modifiers["shift"] or modifiers["caps lock"] then
      speed = fast_walking_speed
    end
    if hero:get_walking_speed() ~= speed then
      hero:set_walking_speed(speed)
    end
  end

  -- Function called when the game is paused.
  function game:on_paused()

    -- Tell the HUD we are paused.
    hud:on_paused()
  end

  -- Function called when the game is paused.
  function game:on_unpaused()

    -- Tell the HUD we are no longer paused.
    hud:on_unpaused()
  end

  -- Function called when the player goes to another map.
  function game:on_map_changed(map)

    -- Notify the HUD (some HUD elements need to know that).
    hud:on_map_changed(map)
  end

  function game:on_key_pressed(key)

    if key == "left shift"
        or key == "right shift"
        or key == "caps lock" then
      update_walking_speed()
    end
  end

  function game:on_key_released(key)

    if key == "left shift"
        or key == "right shift"
        or key == "caps lock" then
      update_walking_speed()
    end
  end

  function game:get_dialog_box()
    return dialog_box
  end

  -- Returns whether the HUD is currently shown.
  function game:is_hud_enabled()
    return hud:is_enabled()
  end

  -- Enables or disables the HUD.
  function game:set_hud_enabled(enable)
    return hud:set_enabled(enable)
  end

  return game
end

return game_manager

