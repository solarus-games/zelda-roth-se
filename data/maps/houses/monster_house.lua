local map = ...
local game = map:get_game()

-- This NPC gives 6 pieces of heart,
-- at 7, 14, 21, 28, 35 and 42 monster types killed.
-- There are 46 different types of monsters.
function monster_npc:on_interaction()

  local encyclopedia = game:get_item("monsters_encyclopedia")
  if encyclopedia:get_variant() == 0 then
    -- First time.
    encyclopedia:set_variant(1)
    game:start_dialog("monster_house.welcome")
  else
    local num_monsters = encyclopedia:get_num_monster_types_killed()
    if game:get_value("monster_house_piece_of_heart_6") then
      -- All rewards were obtained.
      if num_monsters >= 46 then
        game:start_dialog("monster_house.found_all")
      else
        game:start_dialog("monster_house.no_more_reward")
      end
    else
      -- Determine the next reward to obtain.
      local just_obtained_reward = false
      for i = 1, 6 do
        local reward_variable = "monster_house_piece_of_heart_" .. i
        if not game:get_value(reward_variable)
            and num_monsters >= i * 7 then
          game:start_dialog("monster_house.reward", function()
            just_obtained_reward = true
            hero:start_treasure("piece_of_heart", 1, reward_variable)
          end)
          just_obtained_reward = true
          break
        end
      end

      if not just_obtained_reward then
        -- Tell how many monster types have to be killed before the next reward.
        local remaining_before_reward = 7 - (num_monsters % 7)
        if remaining_before_reward == 1 then
          game:start_dialog("monster_house.one_remaining")
        else
          game:start_dialog("monster_house.remaining", remaining_before_reward)
        end
      end
    end
  end
end
