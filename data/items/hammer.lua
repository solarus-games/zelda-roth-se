local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_hammer")
  item:set_assignable(true)
  item:set_pushed_stake(false)

  -- Add hammer properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  enemy_meta.vulnerable_to_hammer = true  -- Vulnerable by default.
  function enemy_meta:is_vulnerable_to_hammer()
    return self.vulnerable_to_hammer
  end

  function enemy_meta:set_vulnerable_to_hammer(vulnerable)
    self.vulnerable_to_hammer = vulnerable
  end
end

function item:on_using()

  local hero = game:get_hero()

  -- Handle stakes.
  item:set_pushed_stake(false)
  sol.timer.start(item, 50, function()
    if item:has_pushed_stake() then
      sol.audio.play_sound("hammer_stake")  -- Successfully pushed a stake.
    else
      sol.audio.play_sound("hammer")  -- No stake was pushed.
    end
    item:set_pushed_stake(false)
  end)
 
  -- Detect enemies with an invisible custom entity.
  local x, y, layer = hero:get_position()
  local direction4 = hero:get_direction()
  if direction4 == 0 then x = x + 12
  elseif direction4 == 1 then y = y - 12
  elseif direction4 == 2 then x = x - 12
  else y = y + 12
  end

  local hammer = game:get_map():create_custom_entity{
    x = x,
    y = y,
    layer = layer,
    width = 8,
    height = 8,
    direction = 0,
  }
  hammer:set_origin(4, 5)
  hammer:add_collision_test("overlapping", function(hammer, entity)

    if entity:get_type() ~= "enemy" then
      return
    end

    if entity:is_vulnerable_to_hammer() then
      entity:hurt(3)
    end
  end)

  -- Start the animation.
  hero:set_animation("hammer", function()
    hero:unfreeze()
    hammer:remove()
  end)
end

function item:has_pushed_stake()
  return item.pushed_stake
end

function item:set_pushed_stake(pushed_stake)
  item.pushed_stake = pushed_stake
end

