local item = ...

function item:on_created()

  self:set_savegame_variable("possession_sword")
  self:set_sound_when_brandished(nil)
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the sword determines the built-in ability "sword".
  self:get_game():set_ability("sword", variant)
end

function item:on_obtaining(variant)

  -- Obtaining the sword increases the force.
  local game = item:get_game()
  local map = game:get_map()
  local force = game:get_value("force")
  if variant == 1 then
    force = 1
    sol.audio.play_sound("treasure")
  elseif variant == 2 then
    force = 3
    sol.audio.play_sound("treasure")
  else
    force = 5
    local old_music = sol.audio.get_music()
    sol.audio.play_music("excalibur")
    sol.timer.start(map, 8000, function()
      sol.audio.play_music(old_music)
    end)
  end
  game:set_value("force", force)
end
