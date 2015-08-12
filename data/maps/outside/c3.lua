-- Outside C3: Shadow Village and Cemetary.

local map = ...
local game = map:get_game()

local function npc_walk(npc)

  local movement = sol.movement.create("random_path")
  movement:start(npc)
end

function map:on_started()

  npc_walk(running_man)
  npc_walk(pink_ball)
  npc_walk(frog)
end

function bottle_merchant:on_interaction()

  if game:has_item("bottle_3") then
    game:start_dialog("bottle_merchant.done")
  else
    game:start_dialog("bottle_merchant.offer", function(answer)
      if answer == 4 then  -- No.
        game:start_dialog("bottle_merchant.no")
      else  -- Yes.
        if game:get_money() < 100 then
          game:start_dialog("not_enough_money")
        else
          game:start_dialog("bottle_merchant.yes", function()
            game:remove_money(100)
            hero:start_treasure("bottle_3")
          end)
        end
      end
    end)
  end
end
