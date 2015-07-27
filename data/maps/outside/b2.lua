-- Kakariko village.

local map = ...
local game = map:get_game()

local function npc_walk(npc)

  local movement = sol.movement.create("random_path")
  movement:start(npc)
end

function map:on_started()

  npc_walk(welcome_npc)
end

function bottle_merchant:on_interaction()

  game:start_dialog("outside_b2.bottle_merchant.offer")
end
