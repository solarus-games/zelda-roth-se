-- Outside A3: Ruins
local map = ...
local game = map:get_game()

function map:on_started()

  if game:get_value("outside_a3_dungeon_6_entrance") then
    turtle_rock_entrance:set_enabled(false)
  end
end

function turtle_rock_entrance:on_pushed()

  sol.audio.play_sound("secret")
  game:set_value("outside_a3_dungeon_6_entrance", true)
end

function weak_wall:on_opened()

  sol.audio.play_sound("secret")
end
