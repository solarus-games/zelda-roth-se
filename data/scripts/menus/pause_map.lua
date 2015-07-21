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
  local map_title_img = sol.surface.create("map_parchment.png", true)
  local floors_background_img = sol.surface.create("menus/map_floors_background.png")
  local grid_img = sol.surface.create("menus/map_grid.png")
  local floors_img = sol.surface.create("floors.png", true)
  local dungeon_map_widget
  local selected_floor
  local num_floors
  local map
  local world
  local dungeon

  local function build_dungeon_map_widget()
 
    dungeon_map_widget = gui_designer:create(320, 240)
    dungeon_map_widget:make_brown_background()
    dungeon_map_widget:make_dark_wooden_frame(16, 16, 80, 144)
    dungeon_map_widget:make_dark_wooden_frame(16, 176, 80, 48)
    dungeon_map_widget:make_dark_wooden_frame(112, 16, 192, 208)
    dungeon_map_widget:make_image(map_title_img, 32, 32)
    dungeon_map_widget:make_image(floors_background_img, 24, 112)
    dungeon_map_widget:make_image(grid_img, 120, 40)
    dungeon_map_widget:make_text(game:get_dungeon_name(), 128, 24)

    -- Dungeon items.
    if game:has_dungeon_map() then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("map")
      dungeon_map_widget:make_sprite(sprite, 36, 205)
    end
    if game:has_dungeon_compass() then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("compass")
      dungeon_map_widget:make_sprite(sprite, 56, 205)
    end
    if game:has_dungeon_boss_key() then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("boss_key")
      dungeon_map_widget:make_sprite(sprite, 76, 205)
    end

    -- Floors.
    local lowest = dungeon.lowest_floor
    local highest = dungeon.highest_floor
    local current = game:get_map():get_floor()
    selected_floor = current
    num_floors = highest - lowest + 1

    local src_x = 0
    local src_y = (2 - highest) * 16
    local src_width = 32
    local src_height = num_floors * 16

    local dst_x = 40
    local dst_y = 64 + src_y

    dungeon_map_widget:make_image_region(floors_img, src_x, src_y, src_width, src_height, dst_x, dst_y)
    link_head_sprite:set_xy(0, 0)
  end

  local function select_floor_up()

    sol.audio.play_sound("cursor")
    selected_floor = selected_floor + 1
    if selected_floor > dungeon.highest_floor then
      selected_floor = dungeon.lowest_floor
    end
    link_head_sprite:set_frame(0)
  end

  local function select_floor_down()

    sol.audio.play_sound("cursor")
    selected_floor = selected_floor - 1
    if selected_floor < dungeon.lowest_floor then
      selected_floor = dungeon.highest_floor
    end
    link_head_sprite:set_frame(0)
  end

  local function draw_dungeon_map(dst_surface)

    dungeon_map_widget:draw(dst_surface)

    -- Show the selected floor.
    local src_x = 32
    local src_y = (2 - selected_floor) * 16
    local dst_x = 40
    local dst_y = 64 + src_y
    floors_img:draw_region(src_x, src_y, 32, 16, dst_surface, dst_x, dst_y)
    dst_x = dst_x - 16
    link_head_sprite:draw(dst_surface, dst_x, dst_y)
  end

  function map_menu:on_started()

    link_head_sprite:set_animation("tunic" .. game:get_ability("tunic"))

    map = game:get_map()
    world = map:get_world()
    dungeon = game:get_dungeon()
    local hero = map:get_hero()
    if dungeon == nil then
      -- World map.
      local map_x, map_y = map:get_location()
      map_x, map_y = map_x + world_map_left_margin, map_y + world_map_top_margin
      local hero_x, hero_y = 0, 0
      if world == "outside" then
        hero_x, hero_y = hero:get_position()
      end
      local x, y = map_x + hero_x, map_y + hero_y
      x, y = x / world_map_scale_x, y / world_map_scale_y
      x, y = x - 8, y - 8
      link_head_sprite:set_xy(x, y)
    else
      build_dungeon_map_widget()
    end
  end

  function map_menu:on_draw(dst_surface)

    if world == "outside" then
      world_map_img:draw(dst_surface)
      link_head_sprite:draw(dst_surface)
    else
      draw_dungeon_map(dst_surface)
    end
  end

  function map_menu:on_key_pressed(key)

    local handled = false
    if dungeon ~= nil then
      if key == "up" then
        select_floor_up()
        handled = true
      elseif key == "down" then
        select_floor_down()
        handled = true
      end
    end

    return handled
  end

  return map_menu
end

return map_manager
