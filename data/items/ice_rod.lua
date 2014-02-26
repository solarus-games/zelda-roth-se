local item = ...

function item:on_created()

  self:set_savegame_variable("possession_ice_rod")
  self:set_assignable(true)
end

function item:on_using()
  -- TODO
end

