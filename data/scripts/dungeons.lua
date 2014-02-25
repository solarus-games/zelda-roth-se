-- Defines the dungeon information of a game.

-- Usage:
-- local dungeon_manager = require("scripts/dungeons")
-- dungeon_manager:create(game)

local dungeon_manager = {}

function dungeon_manager:create(game)

  -- Define the existing dungeons and their floors for the minimap menu.
  local dungeons_info = {
    [1] = {
      floor_width = 1280,
      floor_height = 1200,
      lowest_floor = -1,
      highest_floor = 0,
      maps = { "dungeon_1_b1", "dungeon_1_1f" },
      boss = {
        floor = -1,
        x = 640,
        y = 120,
        savegame_variable = "dungeon_1_boss",
      },
    },
    -- TODO
  }

  -- Returns the index of the current dungeon if any, or nil.
  function game:get_dungeon_index()

    local world = game:get_map():get_world()
    if world == nil then
      return nil
    end
    local index = tonumber(world:match("^dungeon_([0-9]+)$"))
    return index
  end

  -- Returns the current dungeon if any, or nil.
  function game:get_dungeon()

    local index = game:get_dungeon_index()
    return dungeons_info[index]
  end

  function game:is_dungeon_finished(dungeon_index)
    return game:get_value("dungeon_" .. dungeon_index .. "_finished")
  end

  function game:set_dungeon_finished(dungeon_index, finished)
    if finished == nil then
      finished = true
    end
    game:set_value("dungeon_" .. dungeon_index .. "_finished", finished)
  end

  function game:has_dungeon_map(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_map")
  end

  function game:has_dungeon_compass(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_compass")
  end

  function game:has_dungeon_big_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_big_key")
  end

  function game:has_dungeon_boss_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_boss_key")
  end

end

return dungeon_manager

