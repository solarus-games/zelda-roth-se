local item = ...

function item:on_created()

  item:set_savegame_variable("possession_hookshot")
  item:set_assignable(true)
end

-- Function called when the hero uses the hookshot item.
-- Creates a hookshot entity and sets up the movement.
function item:on_using()

  local going_back = false
  local sound_timer
  local direction
  local map = item:get_map()
  local hero = map:get_hero()
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  local hookshot 
  local hookshot_sprite
  local link_sprite

  local go
  local go_back
  local stop

  -- Starts the hookshot movement from the hero.
  function go()

    local movement = sol.movement.create("straight")
    local angle = direction * math.pi / 2
    movement:set_speed(192)
    movement:set_angle(angle)
    movement:set_smooth(false)
    movement:set_max_distance(120)
    movement:start(hookshot)

    function movement:on_obstacle_reached()
      sol.audio.play_sound("sword_tapping")
      go_back()
    end

    function movement:on_finished()
      go_back()
    end

    -- Play a repeated sound.
    sound_timer = sol.timer.start(map, 150, function()
      sol.audio.play_sound("hookshot")
      return true  -- Repeat the timer.
    end)

  end

  -- Makes the hookshot come back to the hero.
  function go_back()

    local movement = sol.movement.create("straight")
    local angle = (direction + 2) * math.pi / 2
    movement:set_speed(192)
    movement:set_angle(angle)
    movement:set_smooth(false)
    movement:set_max_distance(120)
    movement:set_ignore_obstacles(true)
    movement:start(hookshot)
    going_back = true

    function movement:on_finished()
      stop()
    end
  end

  -- Destroys the hookshot and restores control to the player.
  function stop()

    sound_timer:stop()
    hero:unfreeze()
    hookshot:remove()
  end

  hero:freeze()  -- Block the hero.
  hero:set_animation("hookshot")

  -- Create the hookshot.
  hookshot = map:create_custom_entity({
    direction = direction,
    layer = layer,
    x = x,
    y = y,
    width = 16,
    height = 16,
  })
  hookshot:set_origin(8, 13)
  hookshot:set_drawn_in_y_order(true)

  -- Set up hookshot sprites.
  hookshot_sprite = hookshot:create_sprite("entities/hookshot")
  hookshot_sprite:set_direction(direction)
  link_sprite = sol.sprite.create("entities/hookshot")
  link_sprite:set_animation("link")
  function hookshot:on_pre_draw()

    -- Draw the links.
    local num_links = 7
    local dxy = {
      {  16,  -5 },
      {   0, -13 },
      { -16,  -5 },
      {   0,   7 }
    }
    local x1 = x + dxy[direction + 1][1]
    local y1 = y + dxy[direction + 1][2]
    local x2, y2 = hookshot:get_position()
    y2 = y2 - 5
    for i = 0, num_links - 1 do
      local link_x = x1 + (x2 - x1) * i / num_links
      local link_y = y1 + (y2 - y1) * i / num_links
      map:draw_sprite(link_sprite, link_x, link_y)
    end
  end

  -- Set what can be traversed by the hookshot.
  hookshot:set_can_traverse("crystal", true)
  hookshot:set_can_traverse("hero", true)
  hookshot:set_can_traverse("jumper", true)
  hookshot:set_can_traverse("stairs", false)  -- TODO only inner stairs should be obstacle and only when on their lowest layer.
  hookshot:set_can_traverse("stream", true)
  hookshot:set_can_traverse("switch", true)
  hookshot:set_can_traverse("teletransporter", true)

  -- Set up collisions.
  hookshot:add_collision_test("overlapping", function(hookshot, entity)

    local type = entity:get_type()
    if type == "hero" then
      if going_back then
        -- Reaching the hero when going back: stop the hookshot.
        stop()
      end
    end

  end)

  hookshot:add_collision_test("sprite", function(hookshot, entity, hookshot_sprite, enemy_sprite)

    local type = entity:get_type()
    if type == "enemy" then
      local enemy = entity
      if enemy:get_attack_consequence_sprite(enemy_sprite, "hookshot") == "immobilized" then
        enemy:immobilize()
        if not going_back then
          go_back()
        end
      end
    end

  end)

  -- Start the movement.
  go()

  -- Tell the engine that we are no longer using the item.
  item:set_finished()
end
