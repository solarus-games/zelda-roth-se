local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

function map:on_opening_transition_finished(destination)

  if destination == from_outside then
    game:start_dialog("dungeon_9.welcome")
  end
end

local fighting_boss = false

function map:on_started(destination)

  if boss ~= nil then
    boss:set_enabled(false)
  end
  map:set_doors_open("boss_door", true)

  medusa_1:set_shooting(false)
  medusa_2:set_shooting(false)
end

function start_boss_sensor:on_activated()

  if boss ~= nil and not fighting_boss then
    hero:freeze()
    map:close_doors("boss_door")
    sol.audio.stop_music()
    sol.timer.start(1000, function()
      boss:set_enabled(true)
      hero:unfreeze()
      sol.audio.play_music("ganon_battle")
      fighting_boss = true

      medusa_1:set_shooting(true)
      medusa_2:set_shooting(true)
    end)
  end
end

if boss ~= nil then
  function boss:on_dead()
    fighting_boss = false
    sol.audio.play_music(music)
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)

  if item:get_name() == "triforce" then
    -- The end.
    game:set_value("game_finished", true)
    game:save()  -- To get the ranks.
    hero:teleport("ending")
  end
end

if boss ~= nil then
  function boss:on_dying()
    -- Stop shooting fire during the cutscene.
    medusa_1:set_shooting(false)
    medusa_2:set_shooting(false)
  end

end

function to_boss_shortcut:on_activated()
  -- Debug the ending sequence.
  if boss ~= nil then
    sol.timer.start(1100, function()
      boss:hurt(1000)
    end)
  end
end
