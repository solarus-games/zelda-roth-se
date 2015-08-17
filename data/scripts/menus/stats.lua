-- Statistics screen about completing the game.

local stats_manager = { }

local gui_designer = require("scripts/menus/lib/gui_designer")
local records_manager = require("scripts/records_manager")

function stats_manager:new(game)

  local stats = {}

  local layout
  local tree_img = sol.surface.create("menus/tree_repeatable.png")
  local death_count
  local num_pieces_of_heart
  local max_pieces_of_heart
  local num_items
  local max_items
  local num_monsters
  local max_monsters
  local percent
  local tr = sol.language.get_string

  local function get_game_time_string()
    return tr("stats_menu.game_time") .. " " .. game:get_time_played_string()
  end

  local function get_death_count_string()
    death_count = game:get_value("death_count") or 0
    return tr("stats_menu.death_count"):gsub("%$v", death_count)
  end

  local function get_pieces_of_heart_string()
    local item = game:get_item("piece_of_heart")
    num_pieces_of_heart = item:get_total_pieces_of_heart()
    max_pieces_of_heart = item:get_max_pieces_of_heart()
    return tr("stats_menu.pieces_of_heart") .. " "  ..
        num_pieces_of_heart .. " / " .. max_pieces_of_heart
  end

  local function get_items_string()

    num_items = 0
    for _, item in ipairs({
      "bow",
      "bow_silver",
      "hookshot",
      "fire_rod",
      "ice_rod",
      "lamp",
      "hammer",
      "flippers",
      "bottle_1",
      "bottle_2",
      "bottle_3",
      "shield",
      "farore_medallion",
      "din_medallion",
      "nayru_medallion",
      "mudora_book",
    }) do
      if game:has_item(item) then
        num_items = num_items + 1
      end
    end
    num_items = num_items + game:get_item("glove"):get_variant()
    num_items = num_items + game:get_item("sword"):get_variant()
    if game:get_magic() > 32 then
      num_items = num_items + 1
    end
    for i = 1, 9 do
      if game:get_value("dungeon_" .. i .. "_map") then
        num_items = num_items + 1
      end
      if game:get_value("dungeon_" .. i .. "_compass") then
        num_items = num_items + 1
      end
      if game:get_value("dungeon_" .. i .. "_boss_key") then
        num_items = num_items + 1
      end
    end
    num_items = num_items + game:get_num_crystals()

    max_items = 56
    return tr("stats_menu.items") .. " " .. num_items .. " / "  ..max_items
  end

  local function get_monsters_string()
    local encyclopedia = game:get_item("monsters_encyclopedia")
    num_monsters = encyclopedia:get_num_monster_types_killed()
    max_monsters = encyclopedia:get_max_monster_types()
    return tr("stats_menu.monsters") .. " " .. num_monsters .. " / " .. max_monsters
  end

  local function get_percent_string()
    local current = num_pieces_of_heart + num_items + num_monsters
    local max = max_pieces_of_heart + max_items + max_monsters
    percent = math.floor(current / max * 100)
    return tr("stats_menu.percent"):gsub("%$v", percent)
  end

  local function compute_skill_rank()

    local rank
    if death_count == 0 and
        not game:has_item("shield") and
        not game:has_item("bottle_1") and
        not game:has_item("bottle_2") and
        not game:has_item("bottle_3") and
        not game:has_item("farore_medallion") and
        not game:has_item("din_medallion") and
        not game:has_item("nayru_medallion") and
        game:get_max_life() == 20 and
        game:get_max_magic() == 32 then
      rank = tr("stats_menu.rank.ultimate")
      records_manager:set_rank_ultimate()
      records_manager:save()
    elseif percent == 100 then
      rank = tr("stats_menu.rank.completion.1")
      records_manager:set_rank_100_percent()
      records_manager:save()
    elseif percent > 95 then
      rank = tr("stats_menu.rank.completion.2")
    elseif percent > 90 then
      rank = tr("stats_menu.rank.completion.3")
    elseif percent > 85 then
      rank = tr("stats_menu.rank.completion.4")
    elseif percent > 80 then
      rank = tr("stats_menu.rank.completion.5")
    else
      rank = tr("stats_menu.rank.completion.6")
    end
    if rank == nil then
      return ""
    end
    return "- " .. rank
  end

  local function compute_death_rank()

    local rank
    if death_count >= 50 then
      rank = tr("stats_menu.rank.death.1")
    elseif death_count > 95 then
      rank = tr("stats_menu.rank.death.2")
    end
    if rank == nil then
      return ""
    end
    return "- " .. rank
  end

  local function compute_speed_rank()

    local time_played = game:get_time_played()
    records_manager:add_candidate_time(time_played)
    local rank
    if time_played <= 7200 then
      rank = tr("stats_menu.rank.speed")
      records_manager:set_rank_speed()
    end
    records_manager:save()
    if rank == nil then
      return ""
    end
    return "- " .. rank
  end

  local function build_layout(page)

    layout = gui_designer:create(320, 240)
    layout:make_tiled_image(tree_img)

    local y = 11
    layout:make_text(tr("stats_menu.title"), 160, y, "center")
    local x = 11
    y = y + 20
    layout:make_text(get_game_time_string(), x, y)
    y = y + 20
    layout:make_text(get_death_count_string(), x, y)
    y = y + 20
    layout:make_text(get_pieces_of_heart_string(), x, y)
    y = y + 20
    layout:make_text(get_items_string(), x, y)
    y = y + 20
    layout:make_text(get_monsters_string(), x, y)
    y = y + 20
    layout:make_text(get_percent_string(), x, y)

    y = 170
    layout:make_text(tr("stats_menu.rank"), x, y)
    x = 59
    layout:make_text(compute_skill_rank(), x, y)
    y = y + 20
    layout:make_text(compute_death_rank(), x, y)
    y = y + 20
    layout:make_text(compute_speed_rank(), x, y)
  end

  build_layout(page)

  function stats:on_command_pressed(command)

    local handled = false
    if command == "action" then
      sol.main.reset()
      return true
    end
    return handled
  end

  function stats:on_draw(dst_surface)

    layout:draw(dst_surface)
  end

  return stats
end

return stats_manager
