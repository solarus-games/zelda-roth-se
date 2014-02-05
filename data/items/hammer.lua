local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_hammer")
  item:set_assignable(true)
  item:set_pushed_stake(false)
end

function item:on_using()

  local hero = game:get_hero()
  hero:set_animation("hammer", function()
    hero:unfreeze()
  end)

  item:set_pushed_stake(false)
  sol.timer.start(item, 50, function()
    if item:has_pushed_stake() then
      sol.audio.play_sound("hammer_stake")  -- Successfully pushed a stake.
    else
      sol.audio.play_sound("hammer")  -- Nothing was pushed.
    end
    item:set_pushed_stake(false)
  end)
 
end

function item:has_pushed_stake()
  return item.pushed_stake
end

function item:set_pushed_stake(pushed_stake)
  item.pushed_stake = pushed_stake
end

