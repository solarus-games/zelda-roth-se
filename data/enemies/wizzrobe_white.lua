-- A wizard who shoots magic beams.

local enemy = ...

function enemy:on_created()

  enemy:set_life(3)
  enemy:set_damage(4)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_invincible()
end

local function shoot()

  local map = enemy:get_map()
  local hero = map:get_hero()
  if not enemy:is_in_same_region(hero) then
    return true  -- Repeat the timer.
  end

  local sprite = enemy:get_sprite()
  local x, y, layer = enemy:get_position()
  local direction = sprite:get_direction()

  -- Where to start the fire from.
  local dxy = {
    {  0, -5 },
    {  0, -5 },
    {  0, -5 },
    {  0, -5 },
  }

  local beam = enemy:create_enemy({
    breed = "wizzrobe_beam",
    x = dxy[direction + 1][1],
    y = dxy[direction + 1][2],
  })

  if not map.wizzrobe_recent_sound then
    sol.audio.play_sound("zora")
    -- Avoid loudy simultaneous sounds if there are several wizzrobes.
    map.wizzrobe_recent_sound = true
    sol.timer.start(map, 200, function()
      map.wizzrobe_recent_sound = false
    end)
  end
  beam:go(direction)

  return true  -- Repeat the timer.
end

function enemy:on_restarted()

  sol.timer.start(enemy, 200, function()

    local hero = enemy:get_map():get_hero()
    local direction = enemy:get_direction4_to(hero)
    local sprite = enemy:get_sprite()
    sprite:set_direction(direction)
    return true
  end)

  -- Shoot every 2400 ms, but first wait helf a cycle
  -- to have sprite animations synchronized with the shooting.
  sol.timer.start(enemy, 1200, function()
    shoot()
    sol.timer.start(enemy, 2400, shoot)
  end)
end
