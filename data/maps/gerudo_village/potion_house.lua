local map = ...
local game = map:get_game()

local price = 40

function potion_npc:on_interaction()

  local first_empty_bottle = game:get_first_empty_bottle()
  if first_empty_bottle == nil then
    game:start_dialog("gerudo_village.potion_house.no_bottle")
  else
    game:start_dialog("gerudo_village.potion_house.offer", price, function(answer)
      if answer == 3 then
        if game:get_money() < price then
          game:start_dialog("not_enough_money")
        else
          game:start_dialog("gerudo_village.potion_house.yes", function()
            game:remove_money(price)
            hero:start_treasure(first_empty_bottle:get_name(), 3)
          end)
        end
      end
    end)
  end
end
