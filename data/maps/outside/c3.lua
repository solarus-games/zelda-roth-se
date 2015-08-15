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
  npc_walk(little_tree)

  -- Move the cemetary watcher.
  if game:get_value("shadow_village_cemetary_watcher_moved") then
    bully:set_position(464, 493)
    bully:get_sprite():set_direction(0)
  end
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

function pink_ball:on_interaction()

  if game:has_item("mudora_book") then
    game:start_dialog("outside_c3.pink_ball")
  else
    game:start_dialog("shadow_village.non_understandable")
  end
end

function frog:on_interaction()

  if game:has_item("mudora_book") then
    game:start_dialog("outside_c3.frog")
  else
    game:start_dialog("shadow_village.non_understandable")
  end
end

function little_tree:on_interaction()

  if game:has_item("mudora_book") then
    game:start_dialog("outside_c3.little_tree")
  else
    game:start_dialog("shadow_village.non_understandable")
  end
end

-- Cemetary entrance watcher.
function bully:on_interaction()

  if not game:has_item("mudora_book") then
    game:start_dialog("shadow_village.non_understandable")
  elseif not game:get_value("shadow_village_can_go_cemetary") then
    game:start_dialog("outside_c3.cemetary.dont_pass")
  elseif not game:get_value("shadow_village_cemetary_watcher_moved") then
    game:start_dialog("outside_c3.cemetary.leader_allowed_to_pass", function()
      game:set_value("shadow_village_cemetary_watcher_moved", true)
      local movement = sol.movement.create("path")
      movement:set_speed(32)
      movement:set_path({4,4})
      movement:start(bully, function()
        bully:get_sprite():set_direction(0)
      end)
    end)
  else
    game:start_dialog("outside_c3.cemetary.go_away")
  end
end


















