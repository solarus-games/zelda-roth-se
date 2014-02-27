local item = ...

function item:on_created()

  self:set_savegame_variable("i1129")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the sword determines the built-in ability "sword".
  self:get_game():set_ability("sword", variant)
end

function item:on_obtaining(variant)

  -- Obtaining the shield increases the force.
  local game = item:get_game()
  local force = game:get_value("force")
  if variant == 1 then
    force = 1
  elseif variant == 2 then
    force = 3
  else
    force = 5  -- TODO check this
  end
  game:set_value("force", force)
end

