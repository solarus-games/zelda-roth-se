local item = ...
local game = item:get_game()

local magic_needed = 4  -- Number of magic points required.

function item:on_created()

  item:set_savegame_variable("possession_ice_rod")
  item:set_assignable(true)
end

-- Shoots some ice on the map.
function item:shoot()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()

  local x, y, layer = hero:get_position()
  local ice_beam = map:create_custom_entity({
    model = "ice_beam",
    x = x,
    y = y,
    layer = layer,
    direction = direction,
  })

  local angle = direction * math.pi / 2
  ice_beam:go(angle)
end

function item:on_using()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
  hero:set_animation("rod")

  -- Give the hero the animation of using the ice rod.
  local x, y, layer = hero:get_position()
  local ice_rod = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    direction = direction,
    sprite = "hero/ice_rod",
  })

  -- Shoot ice if there is enough magic.
  if game:get_magic() >= magic_needed then
    sol.audio.play_sound("ice")
    game:remove_magic(magic_needed)
    item:shoot()
  end

  -- Make sure that the ice rod stays on the hero.
  -- Even if he is using this item, he can move
  -- because of holes or ice.
  sol.timer.start(ice_rod, 10, function()
    ice_rod:set_position(hero:get_position())    
    return true
  end)

  -- Remove the ice rod and restore control after a delay.
  sol.timer.start(hero, 300, function()
    ice_rod:remove()
    item:set_finished()
  end)
end

-- Initialize the metatable of appropriate entities to work with the ice beam.
local function initialize_meta()

  -- Add Lua ice beam properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_ice_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.ice_reaction = 3  -- 3 life points by default.
  enemy_meta.ice_reaction_sprite = {}
  function enemy_meta:get_ice_reaction(sprite)

    if sprite ~= nil and self.ice_reaction_sprite[sprite] ~= nil then
      return self.ice_reaction_sprite[sprite]
    end
    return self.ice_reaction
  end

  function enemy_meta:set_ice_reaction(reaction, sprite)

    self.ice_reaction = reaction
  end

  function enemy_meta:set_ice_reaction_sprite(sprite, reaction)

    self.ice_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the ice.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_ice_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_ice_reaction_sprite(sprite, "ignored")
  end

end
initialize_meta()
