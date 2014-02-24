-- The small keys counter shown during dungeons or maps with small keys enabled.

local small_keys_builder = {}

local small_key_icon_img = sol.surface.create("hud/small_keys.png")

function small_keys_builder:new(game)

  local small_keys = {}

  local digits_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  }
  local num_small_keys_displayed = nil
  if game:are_small_keys_enabled() then
    num_small_keys_displayed = game:get_num_small_keys()
  end

  function small_keys:set_dst_position(x, y)
    self.dst_x = x
    self.dst_y = y
  end

  function small_keys:on_draw(dst_surface)

    if not game:are_small_keys_enabled() then
      return
    end

    local x, y = self.dst_x, self.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    small_key_icon_img:draw(dst_surface, x, y)
    digits_text:draw(dst_surface, x, y + 10)
  end

  local function check()

    if game:are_small_keys_enabled() then
      local num_small_keys = game:get_num_small_keys()
      if num_small_keys_displayed ~= num_small_keys then
        num_small_keys_displayed = num_small_keys
        digits_text:set_text(num_small_keys)
      end
    end

    return true  -- Repeat the timer.
  end

  -- Periodically check the number of small keys.
  check()
  sol.timer.start(game, 40, check)

  return small_keys
end

return small_keys_builder

