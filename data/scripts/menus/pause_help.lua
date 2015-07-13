local help_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

function help_manager:new(game)

  local help = {}

  local layout = gui_designer:create(320, 240)
  layout:make_background()
  layout:make_big_wooden_frame(16, 8, 112, 32)
  layout:make_wooden_frame(16, 56, 288, 128)
  layout:make_wooden_frame(16, 200, 288, 32)

  -- Like game:get_command_keyboard_binding(),
  -- but makes the first letter uppercase.
  local function get_game_key(command)

    local key = game:get_command_keyboard_binding(command)
    return key:gsub("^%l", string.upper)
  end
  local tr = sol.language.get_string

  local help_items = {
    -- Name, unlocked, keyboard key.
    { "action", true, get_game_key("action") },
    { "move", true, tr("help.directional_keys") },
    { "run", true, tr("help.shift_or_caps_lock") },
    { "sword", game:has_ability("sword"), get_game_key("attack") },
    { "spin_attack", game:has_ability("sword"), get_game_key("attack") .. " " .. tr("help.keep_pressed_then_release") },
    { "pause", true, get_game_key("pause") },
    { "item", true, get_game_key("item_1") },
    { "lift", game:has_ability("lift"), get_game_key("action") },
    { "map", true, "P" },
    { "monsters", game:get_value("monsters_quest_started"), "M" },
    { "look", true, tr("help.ctrl_and_direction") },
    { "fullscreen", true, tr("help.ctrl_and_enter") },
    { "save", true, tr("help.escape") },
  }

  local y = 64
  for _, item in ipairs(help_items) do
    local name = item[1]
    local unlocked = item[2]
    local key = item[3]
    if unlocked then
      local text = tr("help." .. name) .. " " .. key
      layout:make_text(text, 24, y)
      y = y + 16
    end
  end

  function help:on_draw(dst_surface)

    layout:draw(dst_surface)
  end

  return help
end

return help_manager
