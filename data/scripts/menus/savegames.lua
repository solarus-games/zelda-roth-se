local savegames_menu = {}

local gui_designer = require("scripts/menus/lib/gui_designer")
local game_manager = require("scripts/game_manager")
local options_menu = require("scripts/menus/options")
local records_menu = require("scripts/menus/records")
local layout
local savegames_surfaces = {}
local games = {}
local icons_img = sol.surface.create("menus/icons.png")
local hearts_img = sol.surface.create("hud/hearts.png")
local cursor_img = sol.surface.create("menus/link_cursor.png")
local fairy_img = sol.surface.create("menus/fairy_cursor.png")
local cursor_position = 1
local show_savegame_action_box
local show_confirm_delete_box

local function get_savegame_file_name(index)

  return "save" .. index .. ".dat"
end

local function build_layout()

  layout = gui_designer:create(320, 240)

  layout:make_green_tiled_background()
  layout:make_big_wooden_frame(16, 8, 160, 32)
  layout:make_text(sol.language.get_string("savegames_menu.title"), 96, 16, "center")
  layout:make_wooden_frame(16, 48, 288, 32)
  layout:make_wooden_frame(16, 96, 288, 32)
  layout:make_wooden_frame(16, 144, 288, 32)
  layout:make_wooden_frame(16, 192, 136, 32)
  layout:make_wooden_frame(168, 192, 136, 32)
  layout:make_text(sol.language.get_string("savegames_menu.options"), 84, 200, "center")
  layout:make_text(sol.language.get_string("savegames_menu.records"), 236, 200, "center")
  layout:make_text("1.", 44, 56)
  layout:make_text("2.", 44, 104)
  layout:make_text("3.", 44, 152)
end

local function draw_hearts(game, game_surface)

  local life = game:get_life()
  local max_life = game:get_max_life()
  for j = 1, max_life do
    if j % 2 == 0 then
      local x, y
      if j <= 20 then
        x = 40 + 4 * j
        y = 0
      else
        x = 40 + 4 * (j - 20)
        y = 8
      end
      if life >= j then
        hearts_img:draw_region(0, 0, 8, 8, game_surface, x, y)
      else
        hearts_img:draw_region(16, 0, 8, 8, game_surface, x, y)
      end
    end
  end
  if life % 2 == 1 then
    local x, y
    if life <= 20 then
      x = 40 + 4 * (life + 1)
      y = 0
    else
      x = 40 + 4 * (life - 19)
      y = 8
    end
    hearts_img:draw_region(8, 0, 8, 8, game_surface, x, y)
  end
end

local function read_savegames()

  for i = 1, 3 do
    local file_name = get_savegame_file_name(i)
    local surface = sol.surface.create(272, 16)
    surface:set_xy(24, 8 + i * 48)
    savegames_surfaces[i] = surface

    if not sol.game.exists(file_name) then
      games[i] = nil
    else
      -- Existing file.
      local game = game_manager:create(file_name)
      games[i] = game

      -- Triforce icon.
      if game:get_value("game_finished") then
        icons_img:draw_region(0, 0, 32, 16, surface, 240, 0)
      end

      -- Crystals.
      for dungeon = 1, 7 do
        if game:get_value("dungeon_" .. dungeon .. "_finished") then
          icons_img:draw_region(0, 16, 16, 16, surface, 131 + dungeon * 13, 0)
        else
          icons_img:draw_region(16, 16, 16, 16, surface, 131 + dungeon * 13, 0)
        end
      end

      -- Hearts.
      draw_hearts(game, surface)
    end
  end
end

-- Places the cursor on the savegame 1, 2 or 3,
-- or on the options (4) or on the records (5).
local function set_cursor_position(index)

  cursor_position = index
  if index <= 4 then
    cursor_img:set_xy(26, 2 + index * 48)
  else
    cursor_img:set_xy(178, 194)
  end
end

function savegames_menu:on_started()

  sol.audio.play_music("game_over")

  build_layout()
  read_savegames()
  set_cursor_position(1)
end

function savegames_menu:on_finished()
  layout = nil
end

function savegames_menu:on_draw(dst_surface)

  layout:draw(dst_surface)
  for i = 1, 3 do
    savegames_surfaces[i]:draw(dst_surface)
  end
  cursor_img:draw(dst_surface)
end

function savegames_menu:on_key_pressed(key)

  local handled = false

  if key == "down" then
    if cursor_position < 4 then
      set_cursor_position(cursor_position + 1)
    else
      set_cursor_position(1)
    end
    sol.audio.play_sound("cursor")
    handled = true
  elseif key == "up" then
    if cursor_position > 1 then
      set_cursor_position(cursor_position - 1)
    else
      set_cursor_position(4)
    end
    sol.audio.play_sound("cursor")
    handled = true
  elseif key == "left" or key == "right" then
    if cursor_position == 4 or cursor_position == 5 then
      set_cursor_position(9 - cursor_position)
      sol.audio.play_sound("cursor")
      handled = true
    end
  elseif key == "space" then
    if cursor_position <= 3 then
      if games[cursor_position] == nil then
        -- Create a new savegame.
        local game = game_manager:create(get_savegame_file_name(cursor_position))
        sol.main:start_savegame(game)
      else
        -- Show actions for an existing savegame.
        show_savegame_action_box(cursor_position)
      end
    elseif cursor_position == 4 then
      -- Options.
      sol.audio.play_sound("pause_closed")
      sol.menu.start(savegames_menu, options_menu)
      function options_menu:on_finished()
        build_layout()  -- Because the language may have changed.
        options_menu.on_finished = nil
      end
    elseif cursor_position == 5 then
      -- Records.
      sol.audio.play_sound("pause_closed")
      sol.menu.start(savegames_menu, records_menu)
    end
    handled = true
  end
  return handled
end

-- Creates a popup that lets the user choose between load, delete or cancel
-- for a savegame.
function show_savegame_action_box(savegame_index)

  local action_box_menu = {}
  local fairy_cursor_position = 1
  local layout = gui_designer:create(112, 72)
  layout:make_wooden_frame()
  layout:make_text(sol.language.get_string("savegames_menu.load"), 56, 8, "center")
  layout:make_text(sol.language.get_string("savegames_menu.delete"), 56, 28, "center")
  layout:make_text(sol.language.get_string("savegames_menu.cancel"), 56, 48, "center")

  function action_box_menu:on_key_pressed(key)

    if key == "up" then
      sol.audio.play_sound("cursor")
      if fairy_cursor_position > 1 then
        fairy_cursor_position = fairy_cursor_position - 1
      else
        fairy_cursor_position = 3
      end

    elseif key == "down" then
      sol.audio.play_sound("cursor")
      if fairy_cursor_position < 3 then
        fairy_cursor_position = fairy_cursor_position + 1
      else
        fairy_cursor_position = 1
      end

    elseif key == "space" then

      if fairy_cursor_position == 1 then
        -- Load.
        sol.audio.play_sound("pause_closed")
        sol.main:start_savegame(games[cursor_position])

      elseif fairy_cursor_position == 2 then
        -- Delete.
        sol.menu.stop(action_box_menu)
        show_confirm_delete_box(function()
          sol.audio.play_sound("pause_open")
          sol.game.delete(get_savegame_file_name(savegame_index))
          read_savegames()
        end)

      else
        -- Cancel.
        sol.audio.play_sound("pause_closed")
        sol.menu.stop(action_box_menu)
      end

    end

    return true
  end

  function action_box_menu:on_draw(dst_surface)

    layout:draw(dst_surface, 104, 84)
    fairy_img:draw(dst_surface, 112, 72 + fairy_cursor_position * 20)
  end

  gui_designer:map_joypad_to_keyboard(action_box_menu)
  sol.audio.play_sound("pause_closed")
  sol.menu.start(savegames_menu, action_box_menu)
end

-- Creates a popup that ask confirmation to delete something.
function show_confirm_delete_box(action)

  local delete_box_menu = {}
  local fairy_cursor_position = 2
  local layout = gui_designer:create(112, 72)
  layout:make_wooden_frame()
  layout:make_text(sol.language.get_string("savegames_menu.delete_question"), 56, 8, "center")
  layout:make_text(sol.language.get_string("savegames_menu.yes"), 56, 28, "center")
  layout:make_text(sol.language.get_string("savegames_menu.no"), 56, 48, "center")

  function delete_box_menu:on_key_pressed(key)

    if key == "up" or key == "down" then
      sol.audio.play_sound("cursor")
      fairy_cursor_position = 3 - fairy_cursor_position

    elseif key == "space" then

      if fairy_cursor_position == 1 then
        -- Yes: do the action.
        action()
      else
        sol.audio.play_sound("pause_closed")
      end
      sol.menu.stop(delete_box_menu)

    end

    return true
  end

  function delete_box_menu:on_draw(dst_surface)

    layout:draw(dst_surface, 104, 84)
    fairy_img:draw(dst_surface, 112, 92 + fairy_cursor_position * 20)
  end

  gui_designer:map_joypad_to_keyboard(delete_box_menu)

  sol.audio.play_sound("pause_closed")
  sol.menu.start(savegames_menu, delete_box_menu)
end

gui_designer:map_joypad_to_keyboard(savegames_menu)

return savegames_menu
