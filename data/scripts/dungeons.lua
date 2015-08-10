-- Defines the dungeon information of a game.

-- Usage:
-- local dungeon_manager = require("scripts/dungeons")
-- dungeon_manager:create(game)

local dungeon_manager = {}

function dungeon_manager:create(game)

  -- Define the existing dungeons and their floors for the minimap menu.
  local dungeons_info = {
    [1] = {
      lowest_floor = -1,
      highest_floor = 0,
      maps = { "dungeon_1/b1", "dungeon_1/1f" },
      boss = {
        floor = -1,
        x = 960 + 640,
        y = 720 + 120,
        savegame_variable = "dungeon_1_boss",
      },
    },
    [2] = {
      lowest_floor = 0,
      highest_floor = 0,
      maps = { "dungeon_2/1f" },
      boss = {
        floor = 0,
        x = 320 + 1120,
        y = 240 + 1056,
        savegame_variable = "dungeon_2_boss",
      },
    },
    [3] = {
      lowest_floor = 0,
      highest_floor = 1,
      maps = { "dungeon_3/1f", "dungeon_3/2f" },
      boss = {
        floor = 0,
        x = 640 + 1120,
        y = 480 + 840,
        savegame_variable = "dungeon_3_boss",
      },
    },
    [4] = {
      lowest_floor = 0,
      highest_floor = 2,
      maps = { "dungeon_4/1f", "dungeon_4/2f", "dungeon_4/3f" },
      boss = {
        floor = 0,
        x = 640 + 800,
        y = 480 + 608,
        savegame_variable = "dungeon_4_boss",
      },
    },
    [5] = {
      lowest_floor = -2,
      highest_floor = 0,
      maps = { "dungeon_5/b2", "dungeon_5/b1", "dungeon_5/1f" },
      boss = {
        floor = -2,
        x = 640 + 1760,
        y = 480 + 840,
        savegame_variable = "dungeon_5_boss",
      },
    },
    [6] = {
      lowest_floor = 0,
      highest_floor = 1,
      maps = { "dungeon_6/1f", "dungeon_6/2f" },
      boss = {
        floor = 1,
        x = 320 + 1120,
        y = 0 + 1560,
        savegame_variable = "dungeon_6_boss",
      },
    },
    [7] = {
      lowest_floor = 0,
      highest_floor = 1,
      maps = { "dungeon_7/1f", "dungeon_7/2f" },
      boss = {
        floor = 1,
        x = 640 + 800,
        y = 480 + 360,
        savegame_variable = "dungeon_7_boss",
      },
    },
    [8] = {
      lowest_floor = 0,
      highest_floor = 0,
      maps = { "dungeon_8/1f" },
      boss = {
        floor = 0,
        x = 960 + 480,
        y = 0 + 840,
        savegame_variable = "dungeon_8_boss",
      },
    },
    [9] = {
      lowest_floor = -2,
      highest_floor = 1,
      maps = { "dungeon_9/b2", "dungeon_9/b1", "dungeon_9/1f", "dungeon_9/2f" },
      boss = {
        floor = 1,
        x = 640 + 800,
        y = 480 + 120,
        savegame_variable = "dungeon_9_boss",
      },
    },
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

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_finished")
  end

  function game:set_dungeon_finished(dungeon_index, finished)
    if finished == nil then
      finished = true
    end
    dungeon_index = dungeon_index or game:get_dungeon_index()
    game:set_value("dungeon_" .. dungeon_index .. "_finished", finished)
  end

  function game:has_all_crystals()

    for i = 1, 7 do
      if not game:is_dungeon_finished(i) then
        return false
      end
    end
    return true
  end

  function game:get_num_crystals()

    local num_finished = 0
    for i = 1, 7 do
      if game:is_dungeon_finished(i) then
        num_finished = num_finished + 1
      end
    end
    return num_finished
  end

  function game:has_dungeon_map(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_map")
  end

  function game:has_dungeon_compass(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_compass")
  end

  function game:has_dungeon_boss_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_boss_key")
  end

  function game:get_dungeon_name(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return sol.language.get_string("dungeon_" .. dungeon_index .. ".name")
  end

  -- Returns the name of the boolean variable that stores the exploration
  -- of a dungeon room, or nil.
  function game:get_explored_dungeon_room_variable(dungeon_index, floor, room)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    room = room or 1

    if floor == nil then
      if game:get_map() ~= nil then
        floor = game:get_map():get_floor()
      else
        floor = 0
      end
    end

    local room_name
    if floor >= 0 then
      room_name = tostring(floor + 1) .. "f_" .. room
    else
      room_name = math.abs(floor) .. "b_" .. room
    end

    return "dungeon_" .. dungeon_index .. "_explored_" .. room_name
  end

  -- Returns whether a dungeon room has been explored.
  function game:has_explored_dungeon_room(dungeon_index, floor, room)

    return self:get_value(
      self:get_explored_dungeon_room_variable(dungeon_index, floor, room)
    )
  end

  -- Changes the exploration state of a dungeon room.
  function game:set_explored_dungeon_room(dungeon_index, floor, room, explored)

    if explored == nil then
      explored = true
    end

    self:set_value(
      self:get_explored_dungeon_room_variable(dungeon_index, floor, room),
      explored
    )
  end

end

return dungeon_manager

