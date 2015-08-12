-- Implement a basic chest game to find a piece of heart.
-- There must be some chests named chest_1, chest_2, etc and an NPC called chest_npc.

local chest_game_manager = {}

function chest_game_manager:create(map, savegame_variable)

  local game = map:get_game()
  local playing = false
  local good_chest_index
  local num_chests = 0

  local chest_npc = map:get_entity("chest_npc")

  function chest_npc:on_interaction()

    if game:get_value(savegame_variable) then
      -- Already won.
      game:start_dialog("chest_game.already_done")
    elseif playing then
      -- Already playing.
      game:start_dialog("chest_game.go_chest")
    else
      -- Propose to play.
      game:start_dialog("chest_game.rules", function(answer)
        if answer == 3 then
          -- Yes.
          if game:get_money() < 10 then
            game:start_dialog("not_enough_money")
          else
            game:start_dialog("chest_game.thanks", function()
              game:remove_money(10)
              good_chest_index = math.random(num_chests)
              for i = 1, num_chests do
                local chest = map:get_entity("chest_" .. i)
                chest:set_open(false)
              end
              playing = true
            end)
          end
        end
      end)
    end
  end

  local function chest_opening(chest)

    local hero = game:get_hero()
    if not playing then
      if game:get_value(savegame_variable) then
        game:start_dialog("chest_game.already_done", function()
          chest:set_open(false)
        end)
      else
        game:start_dialog("chest_game.pay_first", function()
          chest:set_open(false)
        end)
      end
      hero:unfreeze()
    else
      playing = false
      if chest:get_name() == "chest_" .. good_chest_index then
        hero:start_treasure("piece_of_heart", 1, savegame_variable)
      else
        game:start_dialog("chest_game.lost")
        hero:unfreeze()
      end
    end
  end

  for chest in map:get_entities("chest_") do
    if chest:get_type() == "chest" then
      chest.on_empty = chest_opening
      num_chests = num_chests + 1
      if game:get_value(savegame_variable) then
        chest:set_open(true)
      end
    end
  end

end

return chest_game_manager
