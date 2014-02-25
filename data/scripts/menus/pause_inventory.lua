local inventory_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

local item_names = {
  -- Names of up to 12 items to show in the inventory.
  "bow",
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

local movement_speed = 800
local movement_distance = 160

function inventory_manager:new(game)

  local inventory = {}

  local state = "opening"  -- "opening", "ready" or "closing".

  local item_widget = gui_designer:create(112, 144)
  item_widget:set_xy(16 - movement_distance, 16)
  item_widget:make_green_frame()

  local status_widget = gui_designer:create(160, 144)
  status_widget:set_xy(144, 16 - movement_distance)
  status_widget:make_green_frame()

  local crystals_widget = gui_designer:create(224, 48)
  crystals_widget:set_xy(16, 176 + movement_distance)
  crystals_widget:make_green_frame()

  local pieces_of_heart_widget = gui_designer:create(48, 48)
  pieces_of_heart_widget:set_xy(256 + movement_distance, 176)
  pieces_of_heart_widget:make_green_frame()

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

  function inventory:on_draw(dst_surface)

    item_widget:draw(dst_surface)
    status_widget:draw(dst_surface)
    crystals_widget:draw(dst_surface)
    pieces_of_heart_widget:draw(dst_surface)
  end

  function inventory:on_command_pressed(command)

    if command == "pause" then
      if state == "ready" then
        -- Close the pause menu.
        state = "closing"
        sol.audio.play_sound("pause_closed")
        move_widgets(function() game:set_paused(false) end)
      end
      return true
    end
  end

  move_widgets(function() state = "ready" end)

  return inventory
end

return inventory_manager

