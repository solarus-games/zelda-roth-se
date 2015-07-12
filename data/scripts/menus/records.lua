local records_menu = {}

local gui_designer = require("scripts/menus/lib/gui_designer")
local records = require("scripts/records_manager")
local layout
local cursor_img = sol.surface.create("menus/link_cursor.png")
local icons_img = sol.surface.create("menus/icons.png")
local gray_triforce_img = sol.surface.create(25, 16)
icons_img:draw_region(40, 0, 25, 16, gray_triforce_img)
local yellow_triforce_img = sol.surface.create(25, 16)
icons_img:draw_region(8, 0, 25, 16, yellow_triforce_img)

-- Cursor position:
-- 1: 100% rank
-- 2: ultimate rank
-- 3: speed rank
-- 4: back
local cursor_position

local function get_best_time_text()

  local best_time = records:get_best_time()
  if best_time == nil then
    return ""
  end

  local total_seconds = best_time
  local seconds = total_seconds % 60
  local total_minutes = math.floor(total_seconds / 60)
  local minutes = total_minutes % 60
  local total_hours = math.floor(total_minutes / 60)
  local time_string = string.format(": %02d:%02d:%02d", total_hours, minutes, seconds)
  return time_string
end

local function build_layout()

  layout = gui_designer:create(320, 240)

  layout:make_background()

  layout:make_big_wooden_frame(16, 8, 96, 32)
  layout:make_text(sol.language.get_string("records_menu.title"), 96, 16, "center")

  layout:make_wooden_frame(128, 8, 176, 32)
  layout:make_text(sol.language.get_string("records_menu.best_time"), 140, 16)
  layout:make_text(get_best_time_text(), 244, 16)

  layout:make_wooden_frame(16, 48, 240, 32)
  layout:make_text(sol.language.get_string("records_menu.100_percent_rank"), 44, 56)
  layout:make_wooden_frame(272, 48, 32, 32)
  layout:make_image(records:get_rank_100_percent() and yellow_triforce_img or gray_triforce_img, 279, 56)

  layout:make_wooden_frame(16, 96, 240, 32)
  layout:make_text(sol.language.get_string("records_menu.ultimate_rank"), 44, 104)
  layout:make_wooden_frame(272, 96, 32, 32)
  layout:make_image(records:get_rank_ultimate() and yellow_triforce_img or gray_triforce_img, 279, 104)

  layout:make_wooden_frame(16, 144, 240, 32)
  layout:make_text(sol.language.get_string("records_menu.speed_rank"), 44, 152)
  layout:make_wooden_frame(272, 144, 32, 32)
  layout:make_image(records:get_rank_speed() and yellow_triforce_img or gray_triforce_img, 279, 152)

  layout:make_wooden_frame(16, 192, 136, 32)
  layout:make_text(sol.language.get_string("records_menu.back"), 84, 200)

  layout:make_wooden_frame(168, 192, 136, 32)
  layout:make_text(sol.language.get_string("records_menu.clear"), 236, 200)
end

-- Places the cursor on the record 1, 2 or 3,
-- or on the back button (4) or on the clear button (5).
local function set_cursor_position(index)

  cursor_position = index
  if index <= 4 then
    cursor_img:set_xy(26, 2 + index * 48)
  else
    cursor_img:set_xy(178, 194)
  end
end

function records_menu:on_started()

  records:load()
  build_layout()
  set_cursor_position(4)  -- Back.
end

function records_menu:on_draw(dst_surface)

  layout:draw(dst_surface)
  cursor_img:draw(dst_surface)
end

function records_menu:on_key_pressed(key)

  -- Don't forward the key event to the savegame menu below.
  return true
end

return records_menu
