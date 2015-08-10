-- Outside B3: Lake
local map = ...

function weak_wall_a:on_opened()

  sol.audio.play_sound("secret")
end

function weak_wall_b:on_opened()

  sol.audio.play_sound("secret")
end
