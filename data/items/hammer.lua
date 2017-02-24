local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_hammer")
  item:set_assignable(true)
  item:set_pushed_stake(false)
end

function item:on_using()

  local map = game:get_map()
  local hero = map:get_hero()

  -- Enable collisions after a few frames.
  item.hammer_active = false
  sol.timer.start(map, 150, function()
    item.hammer_active = true
  end)

  -- Handle stakes.
  item:set_pushed_stake(false)
  sol.timer.start(map, 200, function()
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

  local hammer = map:create_custom_entity{
    x = x,
    y = y,
    layer = layer,
    width = 8,
    height = 8,
    direction = 0,
  }
  local entities_touched = { }
  hammer:set_origin(4, 5)
  hammer:add_collision_test("overlapping", function(hammer, entity)

    if not item:is_hammer_active() then
      return
    end

    -- Hurt enemies.
    if entity:get_type() == "enemy" then
      local enemy = entity
      if entities_touched[enemy] then
        -- If protected we don't want to play the sound repeatedly.
        return
      end
      entities_touched[enemy] = true
      local reaction = enemy:get_hammer_reaction(enemy_sprite)
      enemy:receive_attack_consequence("hammer", reaction)

    -- Activate crystals.
    elseif entity:get_type() == "crystal" then
      if entities_touched[entity] then
        -- Don't activate it repeatedly.
        return
      end
      entities_touched[entity] = true

      sol.audio.play_sound("switch")
      map:change_crystal_state()

    -- Activate solid switches.
    elseif entity_type == "switch" then
      local switch = entity
      local sprite = switch:get_sprite()
      if sprite ~= nil and
         sprite:get_animation_set() == "entities/solid_switch" then

        if not switch:is_activated() then
          sol.audio.play_sound("switch")
          switch:set_activated(true)
        end
      end
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

function item:is_hammer_active()
  return item.hammer_active
end

-- Initialize the metatable of appropriate entities to work with the hammer.
local function initialize_meta()

  -- Add Lua hammer properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_hammer_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.hammer_reaction = 3  -- 3 life points by default.
  enemy_meta.hammer_reaction_sprite = {}
  function enemy_meta:get_hammer_reaction(sprite)

    if sprite ~= nil and self.hammer_reaction_sprite[sprite] ~= nil then
      return self.hammer_reaction_sprite[sprite]
    end
    return self.hammer_reaction
  end

  function enemy_meta:set_hammer_reaction(reaction, sprite)

    self.hammer_reaction = reaction
  end

  function enemy_meta:set_hammer_reaction_sprite(sprite, reaction)

    self.hammer_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the hammer.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_hammer_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_hammer_reaction_sprite(sprite, "ignored")
  end

end

initialize_meta()
