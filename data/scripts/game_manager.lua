-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()

local dialog_box_manager = require("scripts/dialog_box")
local hud_manager = require("scripts/hud/hud")
local pause_manager = require("scripts/menus/pause")
local dungeon_manager = require("scripts/dungeons")
local equipment_manager = require("scripts/equipment")
local camera_manager = require("scripts/camera_manager")

local game_manager = {}

-- Sets initial values for a new savegame of this quest.
local function initialize_new_savegame(game)
  game:set_starting_location("intro")
  game:set_max_money(999)
  game:set_max_life(6)
  game:set_life(game:get_max_life())
  game:set_value("force", 0)
  game:set_value("defense", 0)
  game:set_value("time_played", 0)
  game:get_item("bombs_counter"):set_variant(1)
end

-- Measures the time played in this savegame.
local function run_chronometer(game)

  local timer = sol.timer.start(game, 100, function()
    local time = game:get_value("time_played")
    time = time + 100
    game:set_value("time_played", time)
    return true  -- Repeat the timer.
  end)
  timer:set_suspended_with_map(false)
end

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
    initialize_new_savegame(game)
  end
 
  local dialog_box
  local hud
  local pause_menu
  local previous_world

  -- Function called when the player runs this game.
  function game:on_started()

    dungeon_manager:create(game)
    equipment_manager:create(game)
    dialog_box = dialog_box_manager:create(game)
    hud = hud_manager:create(game)
    pause_menu = pause_manager:create(game)
    camera = camera_manager:create(game)

    -- Initialize the hero.
    local hero = game:get_hero()
    game:stop_rabbit()  -- In case the game was saved as a rabbit.
    hero:set_walking_speed(normal_walking_speed)

    -- Measure the time played.
    run_chronometer(game)
  end

  -- Function called when the game stops.
  function game:on_finished()

    dialog_box:quit()
    dialog_box = nil
    hud:quit()
    hud = nil
    pause_menu = nil
    camera = nil
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

    -- Start the pause menu.
    sol.menu.start(game, pause_menu)
  end

  -- Function called when the game is paused.
  function game:on_unpaused()

    -- Tell the HUD we are no longer paused.
    hud:on_unpaused()

    -- Stop the pause menu.
    sol.menu.stop(pause_menu)
  end

  -- Function called when the player goes to another map.
  function game:on_map_changed(map)

    -- Notify the HUD (some HUD elements may want to know that).
    hud:on_map_changed(map)

    -- Reset torches info if the world changes.
    -- TODO the engine should have an event game:on_world_changed().
    local new_world = map:get_world()
    local world_changed = previous_world == nil or
        new_world == nil or
        new_world ~= previous_world
    if world_changed then
      game.lit_torches_by_map = nil  -- See entities/torch.lua
    end

    previous_world = new_world
  end

  -- Function called when the player presses a key during the game.
  function game:on_key_pressed(key)

    local handled = false
    if key == "left shift"
        or key == "right shift"
        or key == "caps lock" then
      -- Run.
      update_walking_speed()
      handled = true

    elseif game:is_pause_allowed() then  -- Keys below are menus.
      if key == "p" then
        -- Map.
        if not game:is_suspended() or game:is_paused() then
          game:switch_pause_menu("map")
          handled = true
        end

      elseif key == "m" then
        -- Monsters.
        if not game:is_suspended() or game:is_paused() then
          if game:has_item("monsters_encyclopedia") then
            game:switch_pause_menu("monsters")
            handled = true
          end
        end

      elseif key == "f1" then
        -- Help.
        if not game:is_suspended() or game:is_paused() then
          game:switch_pause_menu("help")
          handled = true
        end

      elseif key == "escape" then
        if not game:is_paused() then
          if not game:is_dialog_enabled() then
            game:start_dialog("save_quit", function(answer)
              if answer == 2 then
                -- Continue.
                sol.audio.play_sound("danger")
              elseif answer == 3 then
                -- Save and quit.
                sol.audio.play_sound("quit")
                game:save()
                sol.main.reset()
              else
                -- Quit without saving.
                sol.audio.play_sound("quit")
                sol.main.reset()
              end
            end)
            handled = true
          end
        end
      end
    end

    return handled
  end

  -- Function called when the player releases a key during the game.
  function game:on_key_released(key)

    local handled = false
    if key == "left shift"
        or key == "right shift"
        or key == "caps lock" then
      update_walking_speed()
      handled = true
    end

    return handled
  end

  -- Game over animation.
  function game:on_game_over_started()
    sol.audio.play_sound("hero_dying")
    local map = game:get_map()
    local hero = game:get_hero()
    local death_count = game:get_value("death_count") or 0
    if game:is_rabbit() then
      game:stop_rabbit()
    end
    game:set_value("death_count", death_count + 1)
    hero:set_visible(false)
    local x, y, layer = hero:get_position()

    -- Use a fake hero entity for the animation because
    -- the one of the hero is suspended.
    local fake_hero = map:create_custom_entity({
      x = x,
      y = y,
      layer = layer,
      direction = 0,
      sprite = hero:get_tunic_sprite_id(),
    })
    fake_hero:get_sprite():set_animation("dying")
    fake_hero:get_sprite():set_ignore_suspend(true)  -- Cannot be done on the hero (yet).
    local timer = sol.timer.start(game, 3000, function()
      -- Restart the game.
      game:start()
    end)
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

  -- Pauses the game with the specified pause submenu,
  -- or unpauses the game if this submenu is already active.
  function game:switch_pause_menu(submenu_name)
    pause_menu:switch_submenu(submenu_name)
  end

  -- Returns the game time in seconds.
  function game:get_time_played()
    local milliseconds = game:get_value("time_played")
    local total_seconds = math.floor(milliseconds / 1000)
    return total_seconds
  end

  -- Returns a string representation of the game time.
  function game:get_time_played_string()
    local total_seconds = game:get_time_played()
    local seconds = total_seconds % 60
    local total_minutes = math.floor(total_seconds / 60)
    local minutes = total_minutes % 60
    local total_hours = math.floor(total_minutes / 60)
    local time_string = string.format("%02d:%02d:%02d", total_hours, minutes, seconds)
    return time_string
  end

  -- Returns whether the hero is currently turned into a rabbit.
  function game:is_rabbit()
    return game:get_value("rabbit")
  end

  -- Turns the hero into a rabbit until he gets hurt.
  function game:start_rabbit()

    if game:is_rabbit() then
      return
    end

    local map = game:get_map()
    local hero = map:get_hero()
    local x, y, layer = hero:get_position()
    local rabbit_effect = map:create_custom_entity({
      x = x,
      y = y - 5,
      layer = layer,
      direction = 0,
      sprite = "hero/rabbit_explosion",
    })
    sol.timer.start(hero, 500, function()
      rabbit_effect:remove()
    end)

    game:set_value("rabbit", true)

    hero:freeze()
    hero:unfreeze()  -- Get back to walking normally before changing sprites.

    -- Temporarily remove the equipment and block using items.
    local tunic = game:get_ability("tunic")
    game:set_ability("tunic", 1)
    hero:set_tunic_sprite_id("hero/rabbit_tunic")

    local sword = game:get_ability("sword")
    game:set_ability("sword", 0)

    local shield = game:get_ability("shield")
    game:set_ability("shield", 0)

    local keyboard_item_1 = game:get_command_keyboard_binding("item_1")
    game:set_command_keyboard_binding("item_1", nil)
    local joypad_item_1 = game:get_command_joypad_binding("item_1")
    game:set_command_joypad_binding("item_1", nil)

    local keyboard_item_2 = game:get_command_keyboard_binding("item_2")
    game:set_command_keyboard_binding("item_2", nil)
    local joypad_item_2 = game:get_command_joypad_binding("item_2")
    game:set_command_joypad_binding("item_2", nil)

    -- Write the previous equipement to the game in case of game-over or save/quit as a rabbit.
    game:set_value("rabbit_saved_tunic", tunic)
    game:set_value("rabbit_saved_sword", sword)
    game:set_value("rabbit_saved_shield", shield)
    game:set_value("rabbit_saved_keyboard_item_1", keyboard_item_1)
    game:set_value("rabbit_saved_joypad_item_1", joypad_item_1)
    game:set_value("rabbit_saved_keyboard_item_2", keyboard_item_2)
    game:set_value("rabbit_saved_joypad_item_2", joypad_item_2)
  end

  -- Stops the rabbit transformation.
  function game:stop_rabbit()

    if not game:is_rabbit() then
      return
    end
    local hero = game:get_hero()
    hero:set_tunic_sprite_id("hero/tunic" .. game:get_value("rabbit_saved_tunic"))
    game:set_ability("tunic", game:get_value("rabbit_saved_tunic"))
    game:set_ability("sword", game:get_value("rabbit_saved_sword"))
    game:set_ability("shield", game:get_value("rabbit_saved_shield"))
    game:set_command_keyboard_binding("item_1", game:get_value("rabbit_saved_keyboard_item_1"))
    game:set_command_joypad_binding("item_1", game:get_value("rabbit_saved_joypad_item_1"))
    game:set_command_keyboard_binding("item_2", game:get_value("rabbit_saved_keyboard_item_2"))
    game:set_command_joypad_binding("item_2", game:get_value("rabbit_saved_joypad_item_2"))
    game:set_value("rabbit", false)
  end

  return game
end

return game_manager

