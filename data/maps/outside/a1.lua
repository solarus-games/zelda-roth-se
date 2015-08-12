-- Outside A1: Desert and Gerudo Village.

local map = ...
local game = map:get_game()

local function npc_walk(npc)

  local movement = sol.movement.create("random_path")
  movement:start(npc)
end

function map:on_started()

  npc_walk(woman_npc)
  npc_walk(thief_npc)
end

function weak_wall:on_opened()

  sol.audio.play_sound("secret")
end

function bottle_merchant:on_interaction()

  if game:has_item("bottle_2") then
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
            hero:start_treasure("bottle_2")
          end)
        end
      end
    end)
  end
end
