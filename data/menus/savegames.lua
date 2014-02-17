local savegames_menu = {}

local gui_designer = require("menus/lib/gui_designer")
local layout
local tr = sol.language.get_string

function savegames_menu:on_started()

  sol.audio.play_music("game_over")

  -- Build the layout.
  layout = gui_designer:create(320, 240)

  layout:make_background()
  layout:make_big_frame(16, 8, 160, 32)
  layout:make_text(tr("savegames_menu.title"), 96, 16, "center")
  layout:make_frame(16, 48, 288, 32)
  layout:make_frame(16, 96, 288, 32)
  layout:make_frame(16, 144, 288, 32)
  layout:make_frame(16, 192, 136, 32)
  layout:make_frame(168, 192, 136, 32)
  layout:make_text(tr("savegames_menu.options"), 84, 200, "center")
  layout:make_text(tr("savegames_menu.records"), 236, 200, "center")
  layout:make_text("1.", 44, 56)
  layout:make_text("2.", 44, 104)
  layout:make_text("3.", 44, 152)
end

function savegames_menu:on_finished()
  layout = nil
end

function savegames_menu:on_draw(dst_surface)

  layout:draw(dst_surface)
end

return savegames_menu

