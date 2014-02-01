local map = ...
local game = map:get_game()

local night_overlay = sol.surface.create(map:get_size())
local alpha = 192
night_overlay:fill_color({0, 0, 64, alpha})
sol.timer.start(map, 100, function()
  alpha = alpha - 1
  night_overlay:clear()
  night_overlay:fill_color({0, 0, 64, alpha})
  return alpha > 0
end)

function map:on_draw(dst_surface)

  night_overlay:draw(dst_surface)
end

