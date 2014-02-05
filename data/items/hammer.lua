local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_hammer")
  item:set_assignable(true)
end

function item:on_using()

  local hero = game:get_hero()
  hero:set_animation("hammer", function()
    hero:unfreeze()
  end)

  -- TODO detect collision with hammer stakes

  sol.audio.play_sound("hammer")  -- TODO play "hammer_stake" instead if success
 
end

