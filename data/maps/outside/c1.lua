-- Outside C1: Forest
local map = ...
local game = map:get_game()

function weak_wall:on_opened()

  sol.audio.play_sound("secret")
end
