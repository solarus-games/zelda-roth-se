local monsters_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

local models = {
  { enemy = "tentacle",            page = 1, frame = { 152,   8, 32, 32 }, xy = {  8, 13 } },  -- TODO rename to Popo
  { enemy = "rope",                page = 1, frame = { 208,   8, 32, 32 }, xy = {  8, 13 } },
  { enemy = "stal",                page = 1, frame = { 264,   8, 32, 32 }, xy = {  8, 13 } },
  { enemy = "poe",                 page = 1, frame = {  16,  48, 48, 48 }, xy = { 16, 21 } },
  { enemy = "zora_water",          page = 1, frame = {  96,  48, 48, 48 }, xy = { 16, 21 } },
  { enemy = "zora_feet",           page = 1, frame = { 176,  48, 48, 48 }, xy = { 16, 25 } },
  { enemy = "pikku",               page = 1, frame = { 256,  48, 48, 48 }, xy = { 16, 25 } },
  { enemy = "skeleton",            page = 1, frame = {  16, 112, 48, 48 }, xy = { 16, 25 } },  -- TODO rename to Blue Stalfos
  { enemy = "armos",               page = 1, frame = {  96, 112, 48, 48 }, xy = { 16, 29 } },
  { enemy = "moblin",              page = 1, frame = { 176, 112, 48, 48 }, xy = { 16, 25 } },
  { enemy = "wizzrobe_blue",       page = 1, frame = { 256, 112, 48, 48 }, xy = { 16, 25 } },
  { enemy = "lynel",               page = 1, frame = {  16, 176, 48, 48 }, xy = { 16, 29 } },
  { enemy = "tektite_blue",        page = 1, frame = {  96, 176, 48, 48 }, xy = { 16, 21 } },
  { enemy = "vulture",             page = 1, frame = { 176, 176, 48, 48 }, xy = { 16, 21 } },
  { enemy = "geldman",             page = 1, frame = { 252, 176, 56, 48 }, xy = { 20, 21 } },
  { enemy = "keese",               page = 2, frame = {  16,  48, 48, 48 }, xy = { 16, 21 } },
  { enemy = "chasupa",             page = 2, frame = {  96,  48, 48, 48 }, xy = { 16, 21 } },
  { enemy = "hover",               page = 2, frame = { 176,  48, 48, 48 }, xy = { 16, 21 } },
  { enemy = "octorok",             page = 2, frame = { 256,  48, 48, 48 }, xy = { 16, 21 } },
  { enemy = "ropa",                page = 2, frame = {  16, 112, 48, 48 }, xy = { 16, 25 } },
  { enemy = "bari_blue",           page = 2, frame = {  96, 112, 48, 48 }, xy = { 16, 25 } },
  { enemy = "wizzrobe_white",      page = 2, frame = { 176, 112, 48, 48 }, xy = { 16, 25 } },
  { enemy = "sand_crab",           page = 2, frame = { 256, 112, 48, 48 }, xy = { 16, 21 } },
  { enemy = "freezor",             page = 2, frame = {  16, 176, 48, 48 }, xy = { 16, 21 } },
  { enemy = "skeleton_red",        page = 2, frame = {  96, 176, 48, 48 }, xy = { 16, 25 } },
  { enemy = "pengator",            page = 2, frame = { 176, 176, 48, 48 }, xy = { 16, 25 } },
  { enemy = "gibdo",               page = 2, frame = { 256, 176, 48, 48 }, xy = { 16, 25 } },
  { enemy = "zazak_blue",          page = 3, frame = {  16,  48, 48, 48 }, xy = { 16, 25 } },
  { enemy = "hinox",               page = 3, frame = {  96,  48, 48, 48 }, xy = { 16, 25 } },
  { enemy = "goriya_green",        page = 3, frame = { 176,  48, 48, 48 }, xy = { 16, 25 } },
  { enemy = "eyegore_green",       page = 3, frame = { 256,  48, 48, 48 }, xy = { 16, 25 } },
  { enemy = "goriya_red",          page = 3, frame = {  16, 112, 48, 48 }, xy = { 16, 25 } },
  { enemy = "eyegore_red",         page = 3, frame = {  96, 112, 48, 48 }, xy = { 16, 25 } },
  { enemy = "tarosu_red",          page = 3, frame = { 176, 112, 48, 48 }, xy = { 16, 25 } },
  { enemy = "sword_soldier_green", page = 3, frame = { 256, 112, 48, 48 }, xy = { 16, 25 } },
  { enemy = "sword_soldier_blue",  page = 3, frame = {  16, 176, 48, 48 }, xy = { 16, 25 } },
  { enemy = "spear_soldier_red",   page = 3, frame = {  96, 176, 48, 48 }, xy = { 16, 25 } },
  { enemy = "mothula",             page = 4, frame = {  16,  48, 80, 48 }, xy = { 32, 16 } },
  { enemy = "arrghus",             page = 4, frame = { 112,  44, 48, 56 }, xy = { 16, 20 } },
  { enemy = "armos_knight",        page = 4, frame = { 176,  48, 48, 48 }, xy = { 16, 29 } },
  { enemy = "agahnim",             page = 4, frame = { 240,  48, 48, 48 }, xy = { 16, 29 } },
  { enemy = "vitreous",            page = 4, frame = {  16, 112, 48, 48 }, xy = { 16, 21 } },
  { enemy = "blind",               page = 4, frame = {  80, 108, 64, 56 }, xy = { 24, 37 } },
  { enemy = "kholdstare",          page = 4, frame = { 160, 112, 48, 48 }, xy = { 16, 29 } },
  { enemy = "helmasaur_king",      page = 4, frame = { 224, 104, 80, 88 }, xy = { 32, 63 } },
  { enemy = "ganon",               page = 4, frame = {  16, 176, 64, 48 }, xy = { 24, 24 } },
}
local num_pages = 4

function monsters_manager:new(game)

  local monsters = {}

  local layout
  local page = 1

  local function build_layout(page)

    layout = gui_designer:create(320, 240)
    layout:make_green_tiled_background()

    layout:make_big_wooden_frame(16, 8, 112, 32)
    layout:make_text(sol.language.get_string("pause.monsters.title") .. " " .. page, 72, 16, "center")

    for _, monster in ipairs(models) do
      if monster.page == page then
        layout:make_wooden_frame(unpack(monster.frame))
        if game:get_value("monsters_encyclopedia_" .. monster.enemy) then
          local sprite = sol.sprite.create("enemies/" .. monster.enemy)
          if sprite:has_animation("walking") then
            sprite:set_animation("walking")
            sprite:set_direction(3)
            sprite:set_paused(true)  -- TODO isn't this better when animated?
            local dst_x = monster.frame[1] + monster.xy[1] + 8
            local dst_y = monster.frame[2] + monster.xy[2] + 8
            layout:make_sprite(sprite, dst_x, dst_y)
          end
        end
      end
    end
  end

  build_layout(page)

  function monsters:on_command_pressed(command)

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

  function monsters:on_draw(dst_surface)

    layout:draw(dst_surface)
  end

  function monsters:get_monster_count()

    local monster_count = 0
    for _, monster in ipairs(models) do
      if game:get_value("monsters_encyclopedia_" .. monster.enemy) then
        monster_count = monster_count + 1
      end
    end
    return monster_count
  end

  return monsters
end

return monsters_manager
