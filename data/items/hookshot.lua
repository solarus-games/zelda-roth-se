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
  local entities_cought = {}
  local hook
  local hooked
  local leader

  local go
  local go_back
  local fix_to_hook
  local stop

  -- Sets what can be traversed by the hookshot.
  -- Also used for the invisible leader entity used when hooked.
  local function set_can_traverse_rules(entity)
    entity:set_can_traverse("crystal", true)
    entity:set_can_traverse("hero", true)
    entity:set_can_traverse("jumper", true)
    entity:set_can_traverse("stairs", false)  -- TODO only inner stairs should be obstacle and only when on their lowest layer.
    entity:set_can_traverse("stream", true)
    entity:set_can_traverse("switch", true)
    entity:set_can_traverse("teletransporter", true)
    entity:set_can_traverse_ground("deep_water", true)
    entity:set_can_traverse_ground("shallow_water", true)
    entity:set_can_traverse_ground("hole", true)
    entity:set_can_traverse_ground("lava", true)
    entity:set_can_traverse_ground("prickles", true)
    entity:set_can_traverse_ground("low_wall", true)  -- Needed for cliffs.
    entity.apply_cliffs = true
  end

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
  -- Does nothing if the hookshot is already going back.
  function go_back()

    if going_back then
      return
    end

    local movement = sol.movement.create("straight")
    local angle = (direction + 2) * math.pi / 2
    movement:set_speed(192)
    movement:set_angle(angle)
    movement:set_smooth(false)
    movement:set_max_distance(hookshot:get_distance(hero))
    movement:set_ignore_obstacles(true)
    movement:start(hookshot)
    going_back = true

    function movement:on_position_changed()

      for _, entity in ipairs(entities_cought) do
        entity:set_position(hookshot:get_position())
      end
    end

    function movement:on_finished()
      stop()
    end
  end

  -- Attaches the hookshot to an entity and makes the hero fly there.
  function fix_to_hook(entity)

    if hooked then
      -- Already hooked.
      return
    end

    hook = entity
    hooked = true
    hookshot:stop_movement()

    -- Create a new custom entity on the hero, move that entity towards the hook
    -- and make the hero follow that custom entity.
    -- Using this intermediate custom entity rather than directly moving the hero
    -- allows to have better control on what can be traversed.
    leader = map:create_custom_entity({
      direction = direction,
      layer = layer,
      x = x,
      y = y,
      width = 16,
      height = 16,
    })
    set_can_traverse_rules(leader)
    leader.apply_cliffs = true

    local movement = sol.movement.create("straight")
    local angle = direction * math.pi / 2
    movement:set_speed(192)
    movement:set_angle(angle)
    movement:set_smooth(false)
    movement:set_max_distance(hookshot:get_distance(hero))
    movement:start(leader)

    -- Make the hero start a jump to be sure that nothing will happen
    -- if his layer is changed by a cliff or if the ground below him changes.
    -- The better solution would be a custom hero state but this is not possible yet.
    -- So we use a jump movement instead, which is close to what we want here
    -- with the hookshot (flying), and we stop that jump movement.
    hero:start_jumping(0, 100, true)
    hero:get_movement():stop()
    hero:set_animation("hookshot")
    hero:set_direction(direction)

    function movement:on_position_changed()
      -- Teletransporters, holes, etc are avoided because the hero is jumping.
      hero:set_position(leader:get_position())
    end

    -- TODO allow to fly over stairs covered by water
    function movement:on_finished()
      stop()
      -- TODO check if the position is legal
    end

  end

  -- Destroys the hookshot and restores control to the player.
  function stop()

    hero:unfreeze()
    if hookshot ~= nil then
      sound_timer:stop()
      hookshot:remove()
    end
    if leader ~= nil then
      leader:remove()
    end
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
    local hero_x, hero_y = hero:get_position()
    local x1 = hero_x + dxy[direction + 1][1]
    local y1 = hero_y + dxy[direction + 1][2]
    local x2, y2 = hookshot:get_position()
    y2 = y2 - 5
    for i = 0, num_links - 1 do
      local link_x = x1 + (x2 - x1) * i / num_links
      local link_y = y1 + (y2 - y1) * i / num_links
      map:draw_sprite(link_sprite, link_x, link_y)
    end
  end

  -- Set what can be traversed by the hookshot.
  set_can_traverse_rules(hookshot)

  -- Set up collisions.
  hookshot:add_collision_test("overlapping", function(hookshot, entity)

    local entity_type = entity:get_type()

    if entity_type == "hero" then
      -- Reaching the hero while going back: stop the hookshot.
      if going_back then
        stop()
      end

    elseif entity_type == "crystal" then
      -- Activate crystals.
      if not hooked and not going_back then
        sol.audio.play_sound("switch")
        map:change_crystal_state()
        go_back()
      end

    elseif entity_type == "switch" then
      -- Activate solid switches.
      local switch = entity
      local sprite = switch:get_sprite()
      if not hooked and
          not going_back and
          sprite ~= nil and
          sprite:get_animation_set() == "entities/solid_switch" then

        if switch:is_activated() then
          sol.audio.play_sound("sword_tapping")
        else
          sol.audio.play_sound("switch")
          switch:set_activated(true)
        end
        go_back()
      end

    elseif entity.is_catchable_with_hookshot ~= nil and entity:is_catchable_with_hookshot() then
      -- Catch the entity with the hookshot.
      if not hooked and not going_back then
        entities_cought[#entities_cought + 1] = entity
        entity:set_position(hookshot:get_position())
        go_back()
      end

    end
  end)

  -- Custom collision test: there is a collision with a hook if
  -- the facing point of the hookshot overlaps the hook's bounding box.
  -- We cannot use the built-in "facing" collision mode because
  -- it would test the facing point of the hook, not the one of
  -- of the hookshot.
  -- And we cannot reverse the test because the hook
  -- is not necessarily a custom entity.
  local function test_hook_collision(hookshot, entity)

    local dxy = {
      {  8,  0 },
      {  0, -9 },
      { -9,  0 },
      {  0,  8 },
    }
    local facing_x, facing_y = hookshot:get_center_position()
    facing_x = facing_x + dxy[direction + 1][1]
    facing_y = facing_y + dxy[direction + 1][2]
    return entity:overlaps(facing_x, facing_y)
  end

  hookshot:add_collision_test(test_hook_collision, function(hookshot, entity)

    if hooked or going_back then
      return
    end

    if entity.is_hook ~= nil and entity:is_hook() then
      -- Hook to this entity.
      fix_to_hook(entity)
    end
  end)

  hookshot:add_collision_test("sprite", function(hookshot, entity, hookshot_sprite, enemy_sprite)

    local entity_type = entity:get_type()
    if entity_type == "enemy" then
      local enemy = entity
      if hooked then
        return
      end
      local reaction = enemy:get_hookshot_reaction(enemy_sprite)
      if type(reaction) == "number" then
        enemy:hurt(reaction)
        go_back()
      elseif reaction == "immobilized" then
        enemy:immobilize()
        go_back()
      elseif reaction == "protected" then
        sol.audio.play_sound("sword_tapping")
        go_back()
      end
    end

  end)

  -- Start the movement.
  go()

  -- Tell the engine that we are no longer using the item.
  item:set_finished()
end
