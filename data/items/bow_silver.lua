local item = ...
local game = item:get_game()
local bow

function item:on_created()

  self:set_savegame_variable("possession_bow_silver")
  self:set_amount_savegame_variable("amount_bow")
  self:set_assignable(true)
end

function item:on_using()

  -- Call the normal bow code.
  game:get_item("bow").on_using(item)
end

function item:on_amount_changed(amount)

  -- Call the normal bow code.
  game:get_item("bow").on_amount_changed(item, amount)
end

function item:get_force()

  return 2
end

function item:get_arrow_sprite_id()

  return "entities/arrow"
end
