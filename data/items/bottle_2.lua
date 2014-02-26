local item = ...

function item:on_created()
  self:set_assignable(true)
  self:set_savegame_variable("possession_bottle_2")
end

sol.main.load_file("items/bottle")(item)

