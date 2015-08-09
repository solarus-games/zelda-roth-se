local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

local music

function map:on_opening_transition_finished(destination)

  if destination == from_outside then
    game:start_dialog("dungeon_8.welcome")
  end
  music = sol.audio.get_music()
end

local fighting_boss = false

function map:on_started()

  if boss ~= nil then
    boss:set_enabled(false)
  end
  map:set_doors_open("boss_door", true)
end

function start_boss_sensor:on_activated()

  if boss ~= nil and not fighting_boss then
    hero:freeze()
    map:close_doors("boss_door")
    sol.audio.stop_music()
    sol.timer.start(1000, function()
      boss:set_enabled(true)
      hero:unfreeze()
      sol.audio.play_music("boss")
      fighting_boss = true
    end)
  end
end

if boss ~= nil then
  function boss:on_dead()
    fighting_boss = false
    map:open_doors("boss_door")
    sol.audio.play_music(music)
  end
end

function map:on_obtaining_treasure(item, variant, savegame_variable)

  if item:get_name() == "sword" then
    -- Also give an additional heart container.
    game:add_max_life(2)
    game:set_life(game:get_max_life())
  end
end
