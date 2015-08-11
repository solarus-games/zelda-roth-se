-- Statistics screen about completing the game.

local stats_manager = { }

local gui_designer = require("scripts/menus/lib/gui_designer")

function stats_manager:new(game)

  local stats = {}

  local layout
  local tree_img = sol.surface.create("menus/tree_repeatable.png")

  local function build_layout(page)

    layout = gui_designer:create(320, 240)
    layout:make_tiled_image(tree_img)
  end

  build_layout(page)

  function stats:on_command_pressed(command)

    local handled = false
    if command == "action" then
      sol.menu.stop(stats)
      handled = true
    end
    return handled
  end

  function stats:on_draw(dst_surface)

    layout:draw(dst_surface)
  end

  return stats
end

return stats_manager
