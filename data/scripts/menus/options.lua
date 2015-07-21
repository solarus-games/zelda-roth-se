local options_menu = {}

local gui_designer = require("scripts/menus/lib/gui_designer")
local layout
local cursor_img = sol.surface.create("menus/link_cursor.png")
local slider_img = sol.surface.create("menus/slider.png")
local cursor_position
local music_slider_x
local sound_slider_x
local slider_cursor_img = sol.surface.create("menus/slider_cursor.png")

-- Cursor position:
-- 1: music volume
-- 2: sound volume
-- 3: back
local cursor_position

local function build_layout()

  layout = gui_designer:create(320, 240)

  layout:make_green_tiled_background()
  layout:make_big_wooden_frame(16, 8, 96, 32)
  layout:make_text(sol.language.get_string("options_menu.title"), 64, 16, "center")
  layout:make_wooden_frame(16, 64, 288, 32)
  layout:make_wooden_frame(16, 128, 288, 32)
  layout:make_wooden_frame(16, 192, 136, 32)
  layout:make_text(sol.language.get_string("options_menu.music_volume"), 64, 72)
  layout:make_image(slider_img, 128, 72)
  layout:make_text(sol.language.get_string("options_menu.sound_volume"), 64, 136)
  layout:make_image(slider_img, 128, 136)
  layout:make_text(sol.language.get_string("options_menu.back"), 64, 200)
end

-- Places the cursor on option 1 or 2,
-- or on the back button (3).
local function set_cursor_position(index)

  cursor_position = index
  cursor_img:set_xy(26, 2 + index * 64)
end

local function update_music_slider()

  local volume = sol.audio.get_music_volume()
  music_slider_x = 136 + (volume * 128 / 100)
end

local function update_sound_slider()

  local volume = sol.audio.get_sound_volume()
  sound_slider_x = 136 + (volume * 128 / 100)
end

local function increase_music_volume()

  local volume = sol.audio.get_music_volume()
  if volume < 100 then
    volume = volume + 10
    sol.audio.set_music_volume(volume)
    update_music_slider()
  end
end

local function decrease_music_volume()

  local volume = sol.audio.get_music_volume()
  if volume > 0 then
    volume = volume - 10
    sol.audio.set_music_volume(volume)
    update_music_slider()
  end
end

local function increase_sound_volume()

  local volume = sol.audio.get_sound_volume()
  if volume < 100 then
    volume = volume + 10
    sol.audio.set_sound_volume(volume)
    update_sound_slider()
  end
end

local function decrease_sound_volume()

  local volume = sol.audio.get_sound_volume()
  if volume > 0 then
    volume = volume - 10
    sol.audio.set_sound_volume(volume)
    update_sound_slider()
  end
end

function options_menu:on_started()

  build_layout()
  set_cursor_position(3)  -- Back.
  update_music_slider()
  update_sound_slider()
end

function options_menu:on_draw(dst_surface)

  layout:draw(dst_surface)
  cursor_img:draw(dst_surface)
  slider_cursor_img:draw(dst_surface, music_slider_x, 72)
  slider_cursor_img:draw(dst_surface, sound_slider_x, 136)
end

function options_menu:on_key_pressed(key)

  if key == "down" then
    if cursor_position < 3 then
      set_cursor_position(cursor_position + 1)
    else
      set_cursor_position(1)
    end
    sol.audio.play_sound("cursor")
  elseif key == "up" then
    if cursor_position > 1 then
      set_cursor_position(cursor_position - 1)
    else
      set_cursor_position(3)
    end
    sol.audio.play_sound("cursor")
  elseif key == "left" then
    if cursor_position == 1 then
      decrease_music_volume()
    elseif cursor_position == 2 then
      decrease_sound_volume()
    end
    sol.audio.play_sound("cursor")
  elseif key == "right" then
    if cursor_position == 1 then
      increase_music_volume()
    elseif cursor_position == 2 then
      increase_sound_volume()
    end
    sol.audio.play_sound("cursor")
  elseif key == "space" then
    if cursor_position == 3 then
      sol.audio.play_sound("pause_open")
      sol.menu.stop(options_menu)
    end
  end

  -- Don't forward the key event to the savegame menu below.
  return true
end

return options_menu
