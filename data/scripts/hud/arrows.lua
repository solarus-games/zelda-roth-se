-- The arrow counter shown in the game screen.

local arrows_builder = {}

local arrow_icon_img = sol.surface.create("hud/arrow_icon.png")

function arrows_builder:new(game)

  local arrows = {}

  local digits_text = sol.text_surface.create({
    font = "white_digits",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  })
  local bow = game:get_item("bow")
  local bow_silver = game:get_item("bow_silver")
  local amount_displayed = bow:get_amount()
  local max_amount_displayed = bow:get_max_amount()

  function arrows:set_dst_position(x, y)
    arrows.dst_x = x
    arrows.dst_y = y
  end

  function arrows:on_draw(dst_surface)

    -- Don't show the counter before the player has the bow.
    if not bow:has_variant() and not bow_silver:has_variant() then
      return
    end

    local x, y = arrows.dst_x, arrows.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    -- Show either the arrow icon or the silver arrow icon.
    local src_x = 0
    local src_y = bow_silver:has_variant() and 8 or 0

    arrow_icon_img:draw_region(src_x, src_y, 16, 8, dst_surface, x, y)
    digits_text:draw(dst_surface, x, y + 10)
  end

  -- Checks whether the view displays correct information
  -- and updates it if necessary.
  local function check()

    local need_rebuild = false
    local amount = bow:get_amount()
    local max_amount = bow:get_max_amount()

    -- Max amount.
    if max_amount ~= max_amount_displayed then
      need_rebuild = true
      max_amount_displayed = max_amount
    end

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
      if amount_displayed == max_amount_displayed then
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

  return arrows
end

return arrows_builder

