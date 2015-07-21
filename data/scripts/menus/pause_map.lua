local map_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

local world_map_width, world_map_height = 5120, 3840
local world_map_left_margin, world_map_top_margin = 0, 480
-- Note: among the 3840 pixels of the height, only 2880 pixels are on
-- playable maps.
-- The world minimap image has a height of 3840 pixels.
-- to have a map menu with the correct ratio.
-- 3840 = 480 + 2880 + 480
local world_map_scale_x, world_map_scale_y = 5120 / 320, 3840 / 240
local dungeon_map_widget

function map_manager:new(game)

  local map_menu = {}

  local world_map_img = sol.surface.create("menus/world_map.png")
  local link_head_sprite = sol.sprite.create("menus/hero_head")
  local map
  local world

  function map_menu:on_started()

    link_head_sprite:set_animation("tunic" .. game:get_ability("tunic"))

    map = game:get_map()
    world = map:get_world()
    local hero = map:get_hero()
    if world == "outside" then
      local map_x, map_y = map:get_location()
      map_x, map_y = map_x + world_map_left_margin, map_y + world_map_top_margin
      local hero_x, hero_y = hero:get_position()
      local x, y = map_x + hero_x, map_y + hero_y
      x, y = x / world_map_scale_x, y / world_map_scale_y
      x, y = x - 8, y - 8
      link_head_sprite:set_xy(x, y)
    else
      dungeon_map_widget = gui_designer:create(320, 240)
      dungeon_map_widget:make_brown_background()
      dungeon_map_widget:make_dark_wooden_frame(16, 16, 80, 144)
      dungeon_map_widget:make_dark_wooden_frame(16, 176, 80, 48)
      dungeon_map_widget:make_dark_wooden_frame(112, 16, 192, 208)
      local map_title_img = sol.surface.create("map_parchment.png", true)
      dungeon_map_widget:make_image(map_title_img, 32, 32)
      local floors_background_img = sol.surface.create("menus/map_floors_background.png")
      dungeon_map_widget:make_image(floors_background_img, 24, 112)
      local grid_img = sol.surface.create("menus/map_grid.png")
      dungeon_map_widget:make_image(grid_img, 120, 40)
    end
  end

  function map_menu:on_draw(dst_surface)

    if world == "outside" then
      world_map_img:draw(dst_surface)
      link_head_sprite:draw(dst_surface)
    else
      dungeon_map_widget:draw(dst_surface)
    end
  end

  return map_menu
end

return map_manager
