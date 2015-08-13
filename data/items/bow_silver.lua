local item = ...
local game = item:get_game()
local bow

function item:on_created()

  self:set_savegame_variable("possession_bow_silver")
  self:set_amount_savegame_variable("amount_bow")
  self:set_assignable(true)

  self:set_max_amount(30)
end

function item:on_using()

  -- Call the normal bow code.
  game:get_item("bow").on_using(item)
end

function item:on_amount_changed(amount)

  -- Call the normal bow code.
  game:get_item("bow").on_amount_changed(item, amount)
end

function item:on_obtaining(variant, savegame_variable)

  -- If the old bow was assigned to a game command, assign the new one.
  if game:get_item_assigned(1) == game:get_item("bow") then
    game:set_item_assigned(1, item)
  end
  if game:get_item_assigned(2) == game:get_item("bow") then
    game:set_item_assigned(2, item)
  end
end

function item:get_force()

  return 5
end

function item:get_arrow_sprite_id()

  return "entities/arrow_silver"
end
