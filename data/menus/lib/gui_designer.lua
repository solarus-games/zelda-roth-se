-- This module helps creating ALTTP-like basic graphical interfaces.

local gui_designer = {}

local frames_img
local background_img

-- Returns the image containing most graphics needed for the GUI:
-- menus/gui.png.
local function get_frames_img()
  
  if frames_img == nil then
    frames_img = sol.surface.create("menus/gui.png")
  end
  return frames_img
end

-- Fills a region of a surface by repeating a pattern.
local function draw_tiled_region(src_surface, src_x, src_y, src_width, src_height,
  dst_surface, dst_x, dst_y, dst_width, dst_height)

  if dst_x == nil then
    dst_x, dst_y = 0, 0
    dst_width, dst_height = dst_surface:get_size()
  end

  local start_x = dst_x
  local start_y = dst_y

  local y = start_y
  while y < start_y + dst_height do
    local x = start_x
    while x < start_x + dst_width do
      src_surface:draw_region(src_x, src_y, src_width, src_height, dst_surface, x, y)
      x = x + src_width
    end
    y = y + src_height
  end
end

-- Fills a region of a surface by repeating a pattern.
local function draw_tiled(src_surface, dst_surface, dst_x, dst_y, dst_width, dst_height)

  local src_width, src_height = src_surface:get_size()
  draw_tiled_region(src_surface, 0, 0, src_width, src_height, dst_x, dst_y, dst_width, dst_height)
end

-- Create a new widget.
-- A widget basically wraps a surface. It provides features to easily draw
-- on this surface high-level ALTTP-like objects like a frame with some text.
function gui_designer:create(width, height)

  if width == nil then
    width, height = sol.video.get_quest_size()
  end

  local widget = {}
  local canvas = sol.surface.create(width, height)

  -- Fills the entire widget with the background pattern.
  function widget:make_background()
    draw_tiled_region(get_frames_img(), 24, 24, 16, 16, canvas, 0, 0, width, height)
  end

  -- Makes a frame of the specified size with a normal border.
  function widget:make_frame(x, y, width, height)

    -- Black background.
    draw_tiled_region(get_frames_img(), 8, 32, 8, 8, canvas, x + 8, y + 8, width - 16, height - 16)

    -- Angles.
    get_frames_img():draw_region(0, 24, 8, 8, canvas, x, y)
    get_frames_img():draw_region(16, 24, 8, 8, canvas, x + width - 8, y)
    get_frames_img():draw_region(0, 40, 8, 8, canvas, x, y + height - 8)
    get_frames_img():draw_region(16, 40, 8, 8, canvas, x + width - 8, y + height - 8)

    -- Sides.
    draw_tiled_region(get_frames_img(), 8, 24, 8, 8, canvas, x + 8, y, width - 16, 8)
    draw_tiled_region(get_frames_img(), 8, 40, 8, 8, canvas, x + 8, y + height - 8, width - 16, 8)
    draw_tiled_region(get_frames_img(), 0, 32, 8, 8, canvas, x, y + 8, 8, height - 16)
    draw_tiled_region(get_frames_img(), 16, 32, 8, 8, canvas, x + width - 8, y + 8, 8, height - 16)

  end

  -- Makes a frame of the specified size with a bigger border and a shadow.
  -- The height parameter is the height of the frame without the shadow.
  -- The shadow is added below the frame.
  function widget:make_big_frame(x, y, width, height)

    -- Black background.
    draw_tiled_region(get_frames_img(), 8, 32, 8, 8, canvas, x + 8, y + 8, width - 16, height - 16)

    -- Angles.
    get_frames_img():draw_region(0, 0, 16, 8, canvas, x, y)
    get_frames_img():draw_region(32, 0, 16, 8, canvas, x + width - 16, y)
    get_frames_img():draw_region(0, 16, 16, 8, canvas, x, y + height - 8)
    get_frames_img():draw_region(32, 16, 16, 8, canvas, x + width - 16, y + height - 8)

    -- Sides.
    draw_tiled_region(get_frames_img(), 16, 0, 16, 8, canvas, x + 16, y, width - 32, 8)
    draw_tiled_region(get_frames_img(), 16, 16, 16, 8, canvas, x + 16, y + height - 8, width - 32, 8)
    draw_tiled_region(get_frames_img(), 0, 8, 16, 8, canvas, x, y + 8, 16, height - 16)
    draw_tiled_region(get_frames_img(), 32, 8, 16, 8, canvas, x + width - 16, y + 8, 16, height - 16)

    -- Shadow.
    draw_tiled_region(get_frames_img(), 24, 40, 16, 8, canvas, x, y + height, width, 8)
  end

  -- Adds some text.
  function widget:make_text(text, x, y, alignment)
    alignment = alignment or "left"
    local text_surface = sol.text_surface.create{
      text = text,
      font = "alttp",
      horizontal_alignment = alignment,
      vertical_alignment = "top",
    }
    text_surface:draw(canvas, x, y)
  end

  -- Draws the widget.
  function widget:draw(dst_surface)
    canvas:draw(dst_surface)
  end

  return widget
end

return gui_designer

