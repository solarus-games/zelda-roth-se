local item = ...

function item:on_created()
  self:set_assignable(true)
  self:set_savegame_variable("possession_bottle_3")
end

local bottle_script = require("items/bottle")
bottle_script(item)
