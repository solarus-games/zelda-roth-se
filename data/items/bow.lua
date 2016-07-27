-- The bow has two variants: without arrows or with arrows.
-- This is necessary to allow it to have different icons in both cases.
-- Therefore, the silver bow is implement as another item (bow_silver),
-- and calls code from this bow.
-- It could be simpler if it was possible to change the icon of items dynamically.

local item = ...
local game = item:get_game()

function item:on_created()

  self:set_savegame_variable("possession_bow")
  self:set_amount_savegame_variable("amount_bow")
  self:set_assignable(true)

  self:set_max_amount(30)
end

-- Using the bow.
-- This function can also be called by the silver bow.
function item:on_using()

  -- item is the normal bow, self is the normal or the silver one.

  local map = game:get_map()
  local hero = map:get_hero()

  if self:get_amount() == 0 then
    sol.audio.play_sound("wrong")
    self:set_finished()
  else
    hero:set_animation("bow")

    sol.timer.start(map, 290, function()
    sol.audio.play_sound("bow")
      self:remove_amount(1)
      self:set_finished()

      local x, y = hero:get_center_position()
      local _, _, layer = hero:get_position()
      local arrow = map:create_custom_entity({
        x = x,
        y = y,
        layer = layer,
        width = 16,
        height = 16,
        direction = hero:get_direction(),
        model = "arrow",
      })

      arrow:set_force(self:get_force())
      arrow:set_sprite_id(self:get_arrow_sprite_id())
      arrow:go()
    end)
  end
end

-- Function called when the amount changes.
-- This function also works for the silver bow.
function item:on_amount_changed(amount)

  if self:get_variant() ~= 0 then
    -- update the icon (with or without arrow).
    if amount == 0 then
      self:set_variant(1)
    else
      self:set_variant(2)
    end
  end
end

function item:on_obtaining(variant, savegame_variable)

  local arrow = game:get_item("arrow")

  if variant > 0 then
    self:set_max_amount(30)
    -- Variant 1: bow without arrow.
    -- Variant 2: bow with arrows.
    if variant > 1 then
      self:set_amount(self:get_max_amount())
    end
    arrow:set_obtainable(true)
  else
    -- Variant 0: no bow and arrows are not obtainable.
    self:set_max_amount(0)
    arrow:set_obtainable(false)
  end
end

function item:get_force()

  return 2
end

function item:get_arrow_sprite_id()

  return "entities/arrow"
end

-- Initialize the metatable of appropriate entities to work with custom arrows.
local function initialize_meta()

  -- Add Lua arrow properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_arrow_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.arrow_reaction = "force"
  enemy_meta.arrow_reaction_sprite = {}
  function enemy_meta:get_arrow_reaction(sprite)

    if sprite ~= nil and self.arrow_reaction_sprite[sprite] ~= nil then
      return self.arrow_reaction_sprite[sprite]
    end

    if self.arrow_reaction == "force" then
      -- Replace by the current force value.
      local game = self:get_game()
      if game:has_item("bow_silver") then
        return game:get_item("bow_silver"):get_force()
      end
      return game:get_item("bow"):get_force()
    end

    return self.arrow_reaction
  end

  function enemy_meta:set_arrow_reaction(reaction, sprite)

    self.arrow_reaction = reaction
  end

  function enemy_meta:set_arrow_reaction_sprite(sprite, reaction)

    self.arrow_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account arrows.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_arrow_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_arrow_reaction_sprite(sprite, "ignored")
  end
end

initialize_meta()
