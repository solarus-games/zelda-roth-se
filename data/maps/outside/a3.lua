-- Outside A3: Ruins
local map = ...
local game = map:get_game()

function weak_wall:on_opened()

  sol.audio.play_sound("secret")
end

function turtle_rock_entrance:on_pushed()

  sol.audio.play_sound("secret")
end
