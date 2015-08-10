-- Outside A1: Desert
local map = ...
local game = map:get_game()

function weak_wall:on_opened()

  sol.audio.play_sound("secret")
end
