local help_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

function help_manager:new(game)

  local help = {}

  local layout

  -- Like game:get_command_keyboard_binding(),
  -- but makes the first letter uppercase.
  -- Returns an empty string if the command has no key.
  local function get_game_key(command)

    local key = game:get_command_keyboard_binding(command)
    if key == nil then
      return ""
    end
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
    { "monsters", game:has_item("monsters_encyclopedia"), "M" },
    { "look", true, tr("help.ctrl_and_direction") },
    { "fullscreen", true, "F11" },
    { "save", true, tr("help.escape") },
  }

  for i = #help_items, 1, -1 do
    local item = help_items[i]
    local unlocked = item[2]
    if not unlocked then
      table.remove(help_items, i)
    end
  end

  local max_by_page = 7
  local num_pages = math.ceil(#help_items / max_by_page)
  local page = 1

  local function build_layout(page)

    layout = gui_designer:create(320, 240)
    layout:make_wooden_frame(16, 8, 112, 32)
    local title = tr("help.title") .. " " .. page .. "/" .. num_pages
    layout:make_text(title, 72, 16, "center")

    layout:make_wooden_frame(16, 200, 288, 32)
    local footer = tr("help.pages") .. " - " .. tr("help.menus")
    layout:make_text(footer, 24, 208)

    layout:make_wooden_frame(16, 56, 288, 128)

    local first = (page - 1) * max_by_page + 1
    local last = first + max_by_page - 1

    local y = 64
    for i = first, last do
      local item = help_items[i]
      if item == nil then
        break
      end
      local name = item[1]
      local key = item[3]
      local text = tr("help." .. name) .. " " .. key
      layout:make_text(text, 24, y)
      y = y + 16
    end
  end

  build_layout(page)

  function help:on_command_pressed(command)

    local handled = false
    if command == "up" then
      if page > 1 then
        sol.audio.play_sound("cursor")
        page = page - 1
        build_layout(page)
        handled = true
      end
    elseif command == "down" then
      if page < num_pages then
        sol.audio.play_sound("cursor")
        page = page + 1
        build_layout(page)
        handled = true
      end
    end
    return handled
  end

  function help:on_draw(dst_surface)

    layout:draw(dst_surface)
  end

  return help
end

return help_manager
