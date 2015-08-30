-- Shows the current floor for a few seconds when it changes.

local floor_builder = {}

function floor_builder:new(game)

  local floor_view = {}

  local visible = false
  local surface = sol.surface.create(32, 85)
  local floors_img = sol.surface.create("floors.png", true)  -- Language-specific image
  local current_floor = nil

  function floor_view:on_map_changed(map)

    local need_rebuild = false
    local new_floor = map:get_floor()
    if new_floor == current_floor
        or (new_floor == nil and game:get_dungeon() == nil) then
      -- No floor or unchanged floor.
      visible = false
    else
      -- Show the floor view during 3 seconds.
      visible = true
      local timer = sol.timer.start(map, 3000, function()
        visible = false
      end)
      timer:set_suspended_with_map(false)
      need_rebuild = true
    end

    current_floor = new_floor

    if need_rebuild then
      floor_view:rebuild_surface()
    end
  end

  function floor_view:rebuild_surface()

    surface:clear()

    local highest_floor_displayed
    local dungeon = game:get_dungeon()

    if dungeon ~= nil and current_floor ~= nil then
      -- We are in a dungeon: show the neighboor floors before the current one.
      local nb_floors = dungeon.highest_floor - dungeon.lowest_floor + 1
      local nb_floors_displayed = math.min(7, nb_floors)

      -- If there are less 7 floors or less, show them all.
      if nb_floors <= 7 then
        highest_floor_displayed = dungeon.highest_floor
      elseif current_floor >= dungeon.highest_floor - 2 then
        -- Otherwise we only display 7 floors including the current one.
        highest_floor_displayed = dungeon.highest_floor
      elseif current_floor <= dungeon.lowest_floor + 2 then
        highest_floor_displayed = dungeon.lowest_floor + 6
      else
        highest_floor_displayed = current_floor + 3
      end

      local src_y = (2 - highest_floor_displayed) * 16
      local src_height = nb_floors_displayed * 16

      floors_img:draw_region(0, src_y, 32, src_height, surface)
    else
      highest_floor_displayed = current_floor
    end

    -- Show the current floor then.
    local src_y
    local dst_y

    src_y = (2 - current_floor) * 16
    dst_y = (highest_floor_displayed - current_floor) * 16

    floors_img:draw_region(32, src_y, 32, 16, surface, 0, dst_y)
  end

  function floor_view:set_dst_position(x, y)
    dst_x = x
    dst_y = y
  end

  function floor_view:on_draw(dst_surface)

    if visible then
      local x, y = dst_x, dst_y
      local width, height = dst_surface:get_size()
      if x < 0 then
        x = width + x
      end
      if y < 0 then
        y = height + y
      end

      surface:draw(dst_surface, x, y)
    end
  end

  return floor_view
end

return floor_builder
