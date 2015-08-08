local item = ...
local game = item:get_game()

local magic_needed = 4  -- Number of magic points required.

function item:on_created()

  item:set_savegame_variable("possession_ice_rod")
  item:set_assignable(true)
end

function item:on_using()
  -- TODO
end

