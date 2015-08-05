local item = ...
local game = item:get_game()

function item:on_created()

  item:set_shadow("small")
  item:set_can_disappear(true)
  item:set_brandish_when_picked(false)
end

function item:on_started()

  -- Disable pickable magic jars if the player has no magic bar.
  -- We cannot do this from on_created() because we don't know if the magic bar
  -- is already created there.
  item:set_obtainable(game:has_item("magic_bar"))
end

function item:on_obtaining(variant, savegame_variable)

  local max_magic = game:get_max_magic()
  local amounts = { max_magic / 8, max_magic / 4 }
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'magic_flask'")
  end
  game:add_magic(amount)
end

