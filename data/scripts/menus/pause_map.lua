-- Map submenu.
-- Shows the dungeon map when the player is in a dungeon
-- and the world map otherwise.

local map_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")
local chest_loader = require("scripts/lib/chest_loader")

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
  local floors_img = sol.surface.create("floors.png", true)
  local grid_img = sol.surface.create("menus/map_grid.png")
  local boss_icon_img = sol.surface.create("menus/boss_icon.png")
  local chest_icon_img = sol.surface.create("menus/chest_icon.png")
  local rooms_sprite
  local rooms_img
  local dungeon_map_widget
  local current_floor
  local selected_floor
  local num_floors
  local map
  local world
  local dungeon_index
  local dungeon

  -- Converts coordinates relative to the floor
  -- into coordinates relative to the dungeon minimap grid image.
  local function to_dungeon_minimap_coordinates(x, y)

    local scale_x, scale_y = 160 / 3200, 160 / 2400  -- The minimap is a grid of 10*10 rooms.
    x = x * scale_x
    y = y * scale_y
    return x, y
  end

  local function build_rooms_image()

    rooms_img = sol.surface.create(160, 160)
    rooms_sprite:set_animation(selected_floor)

    -- Background: show the whole floor as non visited.
    rooms_sprite:set_direction(0)
    rooms_sprite:draw(rooms_img)

    for i = 1, rooms_sprite:get_num_directions(floor_animation) - 1 do
      if game:has_explored_dungeon_room(dungeon_index, selected_floor, i) then
        -- If the room is visited, show it in another color.
        rooms_sprite:set_direction(i)
        rooms_sprite:draw(rooms_img)
      end
    end

    if game:has_dungeon_compass() then
      -- Boss.
      local boss = dungeon.boss
      if boss ~= nil
          and boss.floor == selected_floor
          and boss.savegame_variable ~= nil
          and not game:get_value(boss.savegame_variable) then
        local dst_x, dst_y = to_dungeon_minimap_coordinates(boss.x, boss.y)
        dst_x, dst_y = dst_x - 4, dst_y - 4
        boss_icon_img:draw(rooms_img, dst_x, dst_y)
      end

      -- Chests.
      if dungeon.chests == nil then
        -- Lazily load the chest information.
        dungeon.chests = chest_loader:load_chests(dungeon.maps)
      end
      for _, chest in ipairs(dungeon.chests) do
        if chest.floor == selected_floor
            and chest.savegame_variable ~= nil
            and not game:get_value(chest.savegame_variable) then
          -- Chests coordinates are already relative to their floor.
          local dst_x, dst_y = to_dungeon_minimap_coordinates(chest.x, chest.y)
          dst_x = dst_x - 1
          chest_icon_img:draw(rooms_img, dst_x, dst_y)
        end
      end
    end
  end

  local function build_dungeon_map_widget()
 
    dungeon_map_widget = gui_designer:create(320, 240)
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

    if game:has_dungeon_map() then
      -- Floors.
      local lowest = dungeon.lowest_floor
      local highest = dungeon.highest_floor
      current_floor = game:get_map():get_floor()
      selected_floor = current_floor
      num_floors = highest - lowest + 1

      local src_x = 0
      local src_y = (2 - highest) * 16
      local src_width = 32
      local src_height = num_floors * 16

      local dst_x = 40
      local dst_y = 64 + src_y

      dungeon_map_widget:make_image_region(floors_img, src_x, src_y, src_width, src_height, dst_x, dst_y)

      -- Show Link's head near his floor.
      dst_x = 24
      dst_y = (2 - current_floor) * 16 + 64
      dungeon_map_widget:make_sprite(link_head_sprite, dst_x, dst_y)

      -- Show the boss icon near his floor.
      if game:has_dungeon_compass() and dungeon.boss ~= nil then
        dst_x = 76
        dst_y = (2 - dungeon.boss.floor) * 16 + 68
        dungeon_map_widget:make_image(boss_icon_img, dst_x, dst_y)
      end

      -- Rooms.
      rooms_sprite = sol.sprite.create("menus/dungeon_maps/map_" .. dungeon_index)
      build_rooms_image()
    end
  end

  local function select_floor_up()

    sol.audio.play_sound("cursor")
    selected_floor = selected_floor + 1
    if selected_floor > dungeon.highest_floor then
      selected_floor = dungeon.lowest_floor
    end
    build_rooms_image()
  end

  local function select_floor_down()

    sol.audio.play_sound("cursor")
    selected_floor = selected_floor - 1
    if selected_floor < dungeon.lowest_floor then
      selected_floor = dungeon.highest_floor
    end
    build_rooms_image()
  end

  local function draw_dungeon_map(dst_surface)

    dungeon_map_widget:draw(dst_surface)

    if game:has_dungeon_map() then
      -- Highlight the selected floor with another color.
      local src_x = 32
      local src_y = (2 - selected_floor) * 16
      local dst_x = 40
      local dst_y = 64 + src_y
      floors_img:draw_region(src_x, src_y, 32, 16, dst_surface, dst_x, dst_y)

      -- Show rooms.
      rooms_img:draw(dst_surface, 128, 48)

      local map_x, map_y = map:get_location()
      local hero_x, hero_y = map:get_hero():get_position()
      dst_x, dst_y = to_dungeon_minimap_coordinates(map_x + hero_x, map_y + hero_y)
      dst_x, dst_y = dst_x + 128 - 8, dst_y + 48 - 8
      if selected_floor == current_floor then
        link_head_sprite:draw(dst_surface, dst_x, dst_y)
      end
    end
  end

  function map_menu:on_started()

    link_head_sprite:set_animation("tunic" .. game:get_ability("tunic"))

    map = game:get_map()
    world = map:get_world()
    dungeon_index = game:get_dungeon_index()
    dungeon = game:get_dungeon()
    rooms_img = nil
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

    if dungeon == nil then
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
