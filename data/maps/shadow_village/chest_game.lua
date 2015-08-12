-- Chest game of the Shadow village.
local map = ...
local game = map:get_game()

local chest_game_manager = require("maps/lib/chest_game_manager")

chest_game_manager:create(map, "shadow_village_chest_game_piece_of_heart")

if not game:has_item("mudora_book") then
  -- Overwrite the chest game interaction.
  function chest_npc:on_interaction()
    game:start_dialog("shadow_village.non_understandable")
  end
end
