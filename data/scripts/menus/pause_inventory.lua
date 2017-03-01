local inventory_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

local item_names = {
  -- Names of up to 12 items to show in the inventory.
  "bow",  -- Will be replaced by the silver one if the player has it.
  "hookshot",
  "bombs_counter",
  "fire_rod",
  "ice_rod",
  "lamp",
  "hammer",
  "flippers",
  "glove",
  "bottle_1",
  "bottle_2",
  "bottle_3",
}
local items_num_columns = 3
local items_num_rows = math.ceil(#item_names / items_num_columns)

local icons_img = sol.surface.create("menus/icons.png")
local piece_of_heart_icon_img = sol.surface.create("hud/piece_of_heart_icon.png")
local items_img = sol.surface.create("entities/items.png")
local movement_speed = 800
local movement_distance = 160

local function create_item_widget(game)
  local widget = gui_designer:create(112, 144)
  widget:set_xy(16 - movement_distance, 16)
  widget:make_green_frame()
  local items_surface = widget:get_surface()

  item_names[1] = game:has_item("bow_silver") and "bow_silver" or "bow"

  for i, item_name in ipairs(item_names) do
    local variant = game:get_item(item_name):get_variant()
    if variant > 0 then
      local column = (i - 1) % items_num_columns + 1
      local row = math.floor((i - 1) / items_num_columns + 1)
      -- Draw the sprite statically. This is okay as long as
      -- item sprites are not animated.
      -- If they become animated one day, they will have to be
      -- drawn at each frame instead (in on_draw()).
      local item_sprite = sol.sprite.create("entities/items")
      item_sprite:set_animation(item_name)
      item_sprite:set_direction(variant - 1)
      item_sprite:set_xy(8 + column * 32 - 16, 13 + row * 32 - 16)
      item_sprite:draw(items_surface)
    end
  end
  return widget
end

local function create_status_widget(game)
  local widget = gui_designer:create(160, 144)
  local sword = game:get_item("sword"):get_variant()
  local shield = game:get_item("shield"):get_variant()
  local force = game:get_value("force")
  local defense = game:get_value("defense")
  local life = game:get_life() .. "/" .. game:get_max_life()
  local magic = game:get_magic() .. "/" .. game:get_max_magic()
  widget:set_xy(144, 16 - movement_distance)
  widget:make_green_frame()
  widget:make_text(sol.language.get_string("pause.inventory.status"), 5, 4, "left")
  widget:make_text(sol.language.get_string("pause.inventory.life"), 5, 28, "left")
  widget:make_text(": " .. life, 65, 28, "left")
  widget:make_text(sol.language.get_string("pause.inventory.magic"), 5, 44, "left")
  widget:make_text(": " .. magic, 65, 44, "left")
  widget:make_text(sol.language.get_string("pause.inventory.force"), 5, 60, "left")
  widget:make_text(": " .. force, 65, 60, "left")
  widget:make_text(sol.language.get_string("pause.inventory.defense"), 5, 76, "left")
  widget:make_text(": " .. defense, 65, 76, "left")
  widget:make_text(sol.language.get_string("pause.inventory.time"), 5, 92, "left")

  if sword > 0 then
    widget:make_image_region(items_img, 528, 32 + 16 * sword, 16, 16, 12, 120)
  end
  if shield > 0 then
    widget:make_image_region(items_img, 544, 32 + 16 * shield, 16, 16, 36, 120)
  end
  if game:has_item("din_medallion") then
    widget:make_image_region(items_img, 176, 0, 16, 16, 60, 120)
  end
  if game:has_item("farore_medallion") then
    widget:make_image_region(items_img, 192, 0, 16, 16, 84, 120)
  end
  if game:has_item("nayru_medallion") then
    widget:make_image_region(items_img, 208, 0, 16, 16, 108, 120)
  end
  if game:has_item("mudora_book") then
    widget:make_image_region(items_img, 160, 0, 16, 16, 132, 120)
  end
  return widget
end

local function create_crystals_widget(game)

  local widget = gui_designer:create(224, 48)
  widget:set_xy(16, 176 + movement_distance)
  widget:make_green_frame()
  widget:make_text(sol.language.get_string("pause.inventory.crystals"), 5, 4, "left")

  for i = 1, 7 do
    local src_x, src_y
    if game:is_dungeon_finished(i) then
      src_x, src_y = 0, 16
    else
      src_x, src_y = 16, 16
    end
    widget:make_image_region(icons_img, src_x, src_y, 16, 16, -13 + 29 * i, 22)
  end

  return widget

end

local function create_pieces_of_heart_widget(game)
  local widget = gui_designer:create(48, 48)
  widget:set_xy(256 + movement_distance, 176)
  widget:make_green_frame()
  local num_pieces_of_heart = game:get_item("piece_of_heart"):get_num_pieces_of_heart()
  widget:make_image_region(piece_of_heart_icon_img, num_pieces_of_heart * 16, 0, 16, 16, 16, 16)
  return widget
end

function inventory_manager:new(game)

  local inventory = {}

  local state = "opening"  -- "opening", "ready" or "closing".

  local item_widget = create_item_widget(game)
  local status_widget = create_status_widget(game)
  local crystals_widget = create_crystals_widget(game)
  local pieces_of_heart_widget = create_pieces_of_heart_widget(game)

  local item_cursor_fixed_sprite = sol.sprite.create("menus/item_cursor")
  item_cursor_fixed_sprite:set_animation("solid_fixed")
  local item_cursor_moving_sprite = sol.sprite.create("menus/item_cursor")
  item_cursor_moving_sprite:set_animation("dashed_blinking")

  -- Determine the place of the item currently assigned if any.
  local item_assigned_row, item_assigned_column, item_assigned_index
  local item_assigned = game:get_item_assigned(1)
  if item_assigned ~= nil then
    local item_name_assigned = item_assigned:get_name()
    for i, item_name in ipairs(item_names) do

      if item_name == item_name_assigned then
        item_assigned_column = (i - 1) % items_num_columns
        item_assigned_row = math.floor((i - 1) / items_num_columns)
        item_assigned_index = i - 1
      end
    end
  end

  -- Rapidly moves the inventory widgets towards or away from the screen.
  local function move_widgets(callback)

    local angle_added = 0
    if item_widget:get_xy() > 0 then
      -- Opposite direction when closing.
      angle_added = math.pi
    end

    local movement = sol.movement.create("straight")
    movement:set_speed(movement_speed)
    movement:set_max_distance(movement_distance)
    movement:set_angle(0 + angle_added)
    item_widget:start_movement(movement, callback)

    local movement = sol.movement.create("straight")
    movement:set_speed(movement_speed)
    movement:set_max_distance(movement_distance)
    movement:set_angle(3 * math.pi / 2 + angle_added)
    status_widget:start_movement(movement)

    local movement = sol.movement.create("straight")
    movement:set_speed(movement_speed)
    movement:set_max_distance(movement_distance)
    movement:set_angle(math.pi / 2 + angle_added)
    crystals_widget:start_movement(movement)

    local movement = sol.movement.create("straight")
    movement:set_speed(movement_speed)
    movement:set_max_distance(movement_distance)
    movement:set_angle(math.pi + angle_added)
    pieces_of_heart_widget:start_movement(movement)

  end

  local time_played_text = sol.text_surface.create{
    font = "alttp",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  }

  -- Draws the time played on the status widget.
  local function draw_time_played(dst_surface)
    local time_string = game:get_time_played_string()
    time_played_text:set_text(": " .. time_string)
    local status_x, status_y = status_widget:get_xy()
    time_played_text:draw(dst_surface, status_x + 65, status_y + 92)
  end

  local cursor_index = game:get_value("pause_inventory_last_item_index") or 0
  local cursor_row = math.floor(cursor_index / items_num_columns)
  local cursor_column = cursor_index % items_num_columns

  -- Draws cursors on the selected and on the assigned items.
  local function draw_item_cursors(dst_surface)

    -- Selected item.
    local widget_x, widget_y = item_widget:get_xy()
    item_cursor_moving_sprite:draw(
        dst_surface,
        widget_x + 24 + 32 * cursor_column,
        widget_y + 24 + 32 * cursor_row
    )

    -- Item assigned (only if different from the selected one).
    if item_assigned_row ~= nil then
      if item_assigned_index ~= cursor_index then
        item_cursor_fixed_sprite:draw(
            dst_surface,
            widget_x + 24 + 32 * item_assigned_column,
            widget_y + 24 + 32 * item_assigned_row
        )
      end
    end
  end

  -- Changes the position of the item cursor.
  local function set_cursor_position(row, column)
    cursor_row = row
    cursor_column = column
    cursor_index = cursor_row * items_num_columns + cursor_column
    if cursor_index == item_assigned_index then
      item_cursor_moving_sprite:set_animation("solid_blinking")
      item_cursor_moving_sprite:set_frame(1)
    else
      item_cursor_moving_sprite:set_animation("dashed_blinking")
    end
  end

  function inventory:on_draw(dst_surface)

    item_widget:draw(dst_surface)
    status_widget:draw(dst_surface)
    crystals_widget:draw(dst_surface)
    pieces_of_heart_widget:draw(dst_surface)

    -- Show the time played.
    draw_time_played(dst_surface)

    -- Show the item cursors.
    draw_item_cursors(dst_surface)
  end

  function inventory:on_command_pressed(command)

    if state ~= "ready" then
      return true
    end

    local handled = false

    if command == "pause" then
      -- Close the pause menu.
      state = "closing"
      sol.audio.play_sound("pause_closed")
      move_widgets(function() game:set_paused(false) end)
      handled = true

    elseif command == "item_1" or command == "action" then
      -- Assign an item.
      local item = game:get_item(item_names[cursor_index + 1])
      if cursor_index ~= item_assigned_index
          and item:has_variant()
          and item:is_assignable() then
        sol.audio.play_sound("ok")
        game:set_item_assigned(1, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_blinking")
        item_cursor_moving_sprite:set_frame(0)
      end
      handled = true

    elseif command == "right" then
      if cursor_column < items_num_columns - 1 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column + 1)
        handled = true
      end

    elseif command == "up" then
      sol.audio.play_sound("cursor")
      if cursor_row > 0 then
        set_cursor_position(cursor_row - 1, cursor_column)
      else
        set_cursor_position(items_num_rows - 1, cursor_column)
      end
      handled = true

    elseif command == "left" then
      if cursor_column > 0 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column - 1)
        handled = true
      end

    elseif command == "down" then
      sol.audio.play_sound("cursor")
      if cursor_row < items_num_rows - 1 then
        set_cursor_position(cursor_row + 1, cursor_column)
      else
        set_cursor_position(0, cursor_column)
      end
      handled = true
    end

    return handled
  end

  function inventory:on_finished()
    -- Store the cursor position.
    game:set_value("pause_inventory_last_item_index", cursor_index)
  end

  set_cursor_position(cursor_row, cursor_column)
  move_widgets(function() state = "ready" end)

  return inventory
end

return inventory_manager

