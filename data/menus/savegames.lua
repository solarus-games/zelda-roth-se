local savegames_menu = {}

local gui_designer = require("menus/lib/gui_designer")
local layout
local savegame_surfaces = {}
local tr = sol.language.get_string

local function build_layout()

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

local function read_savegames()

  for i = 1, 3 do
    local file_name = "save" .. i .. ".dat"
    local savegame = sol.game.load(slot.file_name)
    local surface = sol.surface.create(272, 16)
    savegames_surfaces[i] = surface

    if sol.game.exists(slot.file_name) then
      -- Existing file.


    end
  end
end

function savegames_menu:on_started()

  sol.audio.play_music("game_over")

  build_layout()
  read_savegames()
end

function savegames_menu:on_finished()
  layout = nil
end

function savegames_menu:on_draw(dst_surface)

  layout:draw(dst_surface)
  for i = 1, 3 do
    savegame_surfaces[i]:draw(dst_surface)
  end
end

return savegames_menu

