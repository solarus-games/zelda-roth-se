local stake = ...

local function test_collision_with_hero_hammer(stake, entity)

  if entity:get_type() ~= "hero" then
    -- Ignore collisions with entities other than the hero.
    return false
  end

  if hero:get_animation() ~= "hammer" then
    -- Don't bother testing collisions if the hero is not currently
    -- using the hammer.
    return false
  end

  -- The hero is using the hammer. Determine the exact point to test.
  local hero_direction = entity:get_direction()
  local x, y = entity:get_center_position()
  if hero_direction == 0 then
    -- Right.
    x = x + 16
  elseif hero_direction == 1 then
    -- Up.
    y = y - 16
  elseif hero_direction == 2 then
    -- Left.
    x = x - 16
  else
    -- Down.
    y = y + 16
  end

  -- Test if this point overlaps the stake.
  -- TODO add a function entity:get_bounding_box()
  -- TODO add a function entity:overlaps(x, y, [width, height])
  -- and then just do: return stake:overlaps(x, y)
  local stake_x, stake_y = stake:get_position()
  local stake_origin_x, stake_origin_y = stake:get_origin()
  local stake_top_left_x, stake_top_left_y = stake_x - stake_origin_x, stake_y - stake_origin_y
  local stake_width, stake_height = stake:get_size()

  return x >= stake_top_left_x and x < stake_top_left_x + stake_width
      and y >= stake_top_left_y and y < stake_top_left_y + stake_height
end

stake:add_collision_test(test_collision_with_hero_hammer, function(stake, entity)

  -- Change the animation to down.
  stake:get_sprite():set_animation("down")

  -- Tell the hammer it has just successfully pushed something.
  game:get_item("hammer"):set_pushed_stake(true)
end)

