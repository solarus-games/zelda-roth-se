local item = ...

function item:on_created()

  self:set_savegame_variable("possession_hookshot")
  self:set_assignable(true)
end

function item:on_using()
  self:get_map():get_entity("hero"):start_hookshot()
  self:set_finished()
end

