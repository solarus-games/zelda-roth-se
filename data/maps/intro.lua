local map = ...
local game = map:get_game()

-- Intro.

local map_width, map_height = map:get_size()

game:set_hud_enabled(false)

-- Scrolling backgrounds.
local bg1_img = sol.surface.create("menus/intro/bg1.png")
local bg1_width, bg1_height = bg1_img:get_size()
local bg1_xy = {}
local bg1_movement = sol.movement.create("straight")
bg1_movement:set_angle(3 * math.pi / 4)
bg1_movement:set_speed(32)
bg1_movement:start(bg1_xy)

local bg2_img = sol.surface.create("menus/intro/bg2.png")
local bg2_width, bg2_height = bg2_img:get_size()
local bg2_xy = {}
local bg2_movement = sol.movement.create("straight")
bg2_movement:set_angle(math.pi / 4)
bg2_movement:set_speed(32)
bg2_movement:start(bg2_xy)

-- Frescos.
local frescos = {}
for i = 1, 5 do
  frescos[i] = sol.surface.create("menus/intro/intro" .. i .. ".png")
  frescos[i]:set_xy(0, 16)
end
local fresco_index = 0  -- Index of the current fresco.

-- Dialog.
local dialog_background_img = sol.surface.create(256, 64)
dialog_background_img:set_xy(32, 160)
dialog_background_img:fill_color({255, 255, 128, 128})

function bg1_movement:on_position_changed(x, y)

  if y <= -bg1_height then
    bg1_movement:set_xy(0, 0)
  end

end

function bg2_movement:on_position_changed(x, y)

  if y <= -bg2_height then
    bg2_movement:set_xy(0, 0)
  end
    
end

local function next_fresco()


  if fresco_index < #frescos then
    fresco_index = fresco_index + 1
    game:start_dialog("intro.fresco_" .. fresco_index, next_fresco)
  else
    -- Restore usual settings.
    game:get_dialog_box():set_style("box")
    game:get_dialog_box():set_position("bottom")
    hero:unfreeze()

    -- Go to the first map.
    hero:teleport("houses/link_house", "from_intro")
  end
end

function map:on_started()

  game:get_dialog_box():set_style("empty")
  game:get_dialog_box():set_position({ x = 32, y = 160})
  next_fresco()
end

function map:on_opening_transition_finished()

  hero:freeze()
end

function map:on_draw(dst_surface)

  -- Scrolling backgrounds.
  for y = -bg2_height, map_height + bg2_height, bg2_height do
    for x = -bg2_width, map_width + bg2_width, bg2_width do
      bg2_img:draw(dst_surface, bg2_xy.x + x, bg2_xy.y + y)
    end
  end

  for y = -bg1_height, map_height + bg1_height, bg1_height do
    for x = -bg1_width, map_width + bg1_width, bg1_width do
      bg1_img:draw(dst_surface, bg1_xy.x + x, bg1_xy.y + y)
    end
  end

  -- Fresco.
  if fresco_index > 0 and fresco_index <= #frescos then
    frescos[fresco_index]:draw(dst_surface)
  end

  -- Dialog box background.
  dialog_background_img:draw(dst_surface)
end

