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

-- Makes a frame of the specified size with the border specified by
-- border_x and border_y from gui.png.
-- border_x and border_y are the upper left coordinates of a standard 24x24
-- rectangle containing the border graphics.
local function draw_frame_8_8(border_x, border_y, canvas, x, y, width, height)

  if x == nil then
    -- Use the entire widget by default.
    x, y = 0, 0
    width, height = canvas:get_size()
  end

  -- Black background.
  draw_tiled_region(get_frames_img(), border_x + 8, border_y + 8, 8, 8, canvas, x + 8, y + 8, width - 16, height - 16)

  -- Sides.
  draw_tiled_region(get_frames_img(), border_x + 8, border_y, 8, 8, canvas, x + 8, y, width - 16, 8)
  draw_tiled_region(get_frames_img(), border_x + 8, border_y + 16, 8, 8, canvas, x + 8, y + height - 8, width - 16, 8)
  draw_tiled_region(get_frames_img(), border_x, border_y + 8, 8, 8, canvas, x, y + 8, 8, height - 16)
  draw_tiled_region(get_frames_img(), border_x + 16, border_y + 8, 8, 8, canvas, x + width - 8, y + 8, 8, height - 16)

  -- Angles, drawn after the sides in case the size is not a multiple of 8.
  get_frames_img():draw_region(border_x, border_y, 8, 8, canvas, x, y)
  get_frames_img():draw_region(border_x + 16, border_y, 8, 8, canvas, x + width - 8, y)
  get_frames_img():draw_region(border_x, border_y + 16, 8, 8, canvas, x, y + height - 8)
  get_frames_img():draw_region(border_x + 16, border_y + 16, 8, 8, canvas, x + width - 8, y + height - 8)
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
  local sprites = {}

  -- Fills a rectangle with a green tiled background image.
  function widget:make_green_tiled_background(x, y, w, h)
    x = x or 0
    y = y or 0
    w = w or width
    h = h or height
    draw_tiled_region(get_frames_img(), 72, 8, 16, 16, canvas, x, y, w, h)
  end

  -- Fills a rectangle with brown color.
  function widget:make_brown_background(x, y, w, h)
    x = x or 0
    y = y or 0
    w = w or width
    h = h or height
    draw_tiled_region(get_frames_img(), 112, 0, 16, 16, canvas, x, y, w, h)
  end

  -- Fills a rectangle with the specified color.
  function widget:make_color_background(color, x, y, w, h)
    x = x or 0
    y = y or 0
    w = w or width
    h = h or height
    canvas:fill_color(color, x, y, w, h)
  end

  -- Makes a frame of the specified size with a wooden border.
  function widget:make_wooden_frame(x, y, width, height)
    draw_frame_8_8(48, 0, canvas, x, y, width, height)
  end

  -- Makes a frame of the specified size with a dark wooden border.
  function widget:make_dark_wooden_frame(x, y, width, height)
    draw_frame_8_8(88, 0, canvas, x, y, width, height)
  end

  -- Makes a frame of the specified size with a green border.
  function widget:make_green_frame(x, y, width, height)
    draw_frame_8_8(0, 24, canvas, x, y, width, height)
  end

  -- Makes a wooden frame of the specified size
  -- with a bigger border and a shadow.
  -- The height parameter is the height of the frame without the shadow.
  -- The shadow is added below the frame.
  function widget:make_big_wooden_frame(x, y, width, height)

    if x == nil then
      -- Use the entire widget by default.
      x, y = 0, 0
      width, height = canvas:get_size()
    end

    -- Black background.
    draw_tiled_region(get_frames_img(), 56, 8, 8, 8, canvas, x + 8, y + 8, width - 16, height - 16)

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
    draw_tiled_region(get_frames_img(), 72, 0, 16, 8, canvas, x, y + height, width, 8)
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

  -- Adds an image.
  function widget:make_image(src_surface, dst_x, dst_y)
    local src_width, src_height = src_surface:get_size()
    widget:make_image_region(src_surface, 0, 0, src_width, src_height, dst_x, dst_y)
  end

  -- Adds a region of an image.
  function widget:make_image_region(src_surface, src_x, src_y, src_width, src_height, dst_x, dst_y)
    src_surface:draw_region(src_x, src_y, src_width, src_height, canvas, dst_x, dst_y)
  end

  -- Add a tiled image.
  function widget:make_tiled_image(src_surface, x, y, w, h)
    x = x or 0
    y = y or 0
    w = w or width
    h = h or height
    local src_w, src_h = src_surface:get_size()
    draw_tiled_region(src_surface, 0, 0, src_w, src_h, canvas, x, y, w, h)
  end

  -- Adds an animated sprite.
  function widget:make_sprite(sprite, dst_x, dst_y)

    sprites[#sprites + 1] = { sprite = sprite, x = dst_x, y = dst_y }
  end

  -- Draws the widget.
  function widget:draw(dst_surface, dst_x, dst_y)
    canvas:draw(dst_surface, dst_x, dst_y)
    for _, sprite_info in ipairs(sprites) do
      sprite_info.sprite:draw(dst_surface, sprite_info.x, sprite_info.y)
    end
  end

  -- Moves the widget.
  function widget:start_movement(movement, callback)
    movement:start(canvas, callback)
  end

  -- Gets the widget coordinates.
  function widget:get_xy(x, y)
    return canvas:get_xy(x, y)
  end

  -- Sets the widget coordinates.
  function widget:set_xy(x, y)
    canvas:set_xy(x, y)
  end

  -- Returns the encapsulated surface.
  function widget:get_surface()
    return canvas
  end

  return widget
end

-- Forwards joypad events of a menu to keyboard events.
-- Joypad direction event are replaced by direction keystrokes,
-- and any joypad button event is replaced by a spacebar keyboard event.
function gui_designer:map_joypad_to_keyboard(menu)

  function menu:on_joypad_button_pressed(button)
    return self:on_key_pressed("space")
  end

  function menu:on_joypad_axis_moved(axis, state)

    if axis % 2 == 0 then  -- Horizontal axis.
      if state > 0 then
        return self:on_key_pressed("right")
      elseif state < 0 then
        return self:on_key_pressed("left")
      end
    else  -- Vertical axis.
      if state > 0 then
        return self:on_key_pressed("down")
      elseif state < 0 then
        return self:on_key_pressed("up")
      end
    end
  end

  function menu:on_joypad_hat_moved(hat, direction8)

    if direction8 == -1 or direction8 % 2 ~= 0 then
      return false
    end

    local keys = { "right", "up", "left", "down" }
    return self:on_key_pressed_pressed(keys[direction8 % 2])
  end
end

return gui_designer

