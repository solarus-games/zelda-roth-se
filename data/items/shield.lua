local item = ...

function item:on_created()

  self:set_savegame_variable("possession_shield")
end

function item:on_variant_changed(variant)

  -- The possession state of the shield determines the built-in ability "shield".
  self:get_game():set_ability("shield", variant)
end

function item:on_obtaining(variant)

  -- Obtaining the shield increases the defense level of 1 point.
  local game = item:get_game()
  local defense = game:get_value("defense")
  defense = defense + 1
  game:set_value("defense", defense)
end

