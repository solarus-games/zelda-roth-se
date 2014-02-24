-- The bomb counter shown in the game screen.

local bombs_builder = {}

local bomb_icon_img = sol.surface.create("hud/bomb_icon.png")

function bombs_builder:new(game)

  local bombs = {}

  local digits_text = sol.text_surface.create({
    font = "white_digits",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  })
  local bombs_counter = game:get_item("bombs_counter")
  local amount_displayed = bombs_counter:get_amount()

  function bombs:set_dst_position(x, y)
    bombs.dst_x = x
    bombs.dst_y = y
  end

  function bombs:on_draw(dst_surface)

    local x, y = bombs.dst_x, bombs.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    bomb_icon_img:draw(dst_surface, x + 4, y)
    digits_text:draw(dst_surface, x, y + 10)
  end

  -- Checks whether the view displays correct information
  -- and updates it if necessary.
  local function check()

    local need_rebuild = false
    local amount = bombs_counter:get_amount()
    local max_amount = bombs_counter:get_max_amount()

    -- Current amount.
    if amount ~= amount_displayed then
      need_rebuild = true
      if amount_displayed < amount then
        amount_displayed = amount_displayed + 1
      else
        amount_displayed = amount_displayed - 1
      end
    end

    if digits_text:get_text() == "" then
      need_rebuild = true
    end

    -- Update the text if something has changed.
    if need_rebuild then
      digits_text:set_text(string.format("%02d", amount_displayed))

      -- Show in green if the maximum is reached.
      if amount_displayed == max_amount then
        digits_text:set_font("green_digits")
      else
        digits_text:set_font("white_digits")
      end
    end

    return true  -- Repeat the timer.
  end

  -- Periodically check.
  check()
  sol.timer.start(game, 40, check)

  return bombs
end

return bombs_builder

