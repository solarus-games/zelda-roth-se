-- The end.
local map = ...
local game = map:get_game()

local stats_manager = require("scripts/menus/stats")

local background_img = sol.surface.create("menus/ending.png")

function map:on_started()

  game:set_pause_allowed(false)
  game:set_hud_enabled(false)
  game:get_dialog_box():set_style("empty")
  game:get_dialog_box():set_position({ x = 8, y = 8})
end

function map:on_opening_transition_finished()

  hero:freeze()
  game:start_dialog("ending", function()
    -- Show the statistics menu.
    sol.audio.stop_music()
    sol.audio.play_sound("pause_open")
    local stats = stats_manager:new(game)
    sol.menu.start(map, stats)
  end)
end

function map:on_draw(dst_surface)

  background_img:draw(dst_surface)
end
