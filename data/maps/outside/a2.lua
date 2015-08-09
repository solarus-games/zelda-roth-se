-- Outside A2: Castle

local map = ...
local game = map:get_game()

function crystals_required_sensor:on_activated()

  -- Check if the player has the 7 crystals.
  if not game:has_all_crystals() then
    sol.audio.play_sound("warp")
    hero:teleport(map:get_id(), "from_crystals_required")
  end
end
