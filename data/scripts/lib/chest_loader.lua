-- This script parses map data files in order to determine the position of their chests.
-- It can be used to make the map menu of dungeons.
local chest_loader = {}

-- Parses the specified map data files and returns an array of their chest information.
-- Each element of the array is a table with the following fields:
-- floor, x, y, big, savegame_variable.
function chest_loader:load_chests(map_ids)

  local chests = {}
  local current_floor, current_map_x, current_map_y

  -- Here is the magic: set up a special environment to load map data files.
  local environment = {

    properties = function(map_properties)
      -- Remember the floor and the map location
      -- to be used for subsequent chests.
      current_floor = map_properties.floor
      current_map_x = map_properties.x
      current_map_y = map_properties.y
    end,

    chest = function(chest_properties)
      -- Get the info about this chest and store it into the dungeon table.
      if current_floor ~= nil then
        chests[#chests + 1] = {
          floor = current_floor,
          x = current_map_x + chest_properties.x,
          y = current_map_y + chest_properties.y,
          big = (chest_properties.sprite == "entities/big_chest"),
          savegame_variable = chest_properties.treasure_savegame_variable,
        }
      end
    end,
  }

  -- Make any other function a no-op (tile(), enemy(), block(), etc.).
  setmetatable(environment, {
    __index = function()
      return function() end
    end
  })

  for _, map_id in ipairs(map_ids) do

    -- Load the map data file as Lua.
    local chunk = sol.main.load_file("maps/" .. map_id .. ".dat")

    -- Apply our special environment (with functions properties() and chest()).
    setfenv(chunk, environment)

    -- Run it.
    chunk()
  end

  return chests
end

return chest_loader
