-- Blacksmith's house.

-- - Needs 2 crystals to accept to do anything
-- - Can improve sword 1 to sword 2
-- - Can improve glove 1 to glove 2
-- - Can improve the silver to the silver bow when all crystals are found

local map = ...
local game = map:get_game()

local sprite = blacksmith:get_sprite()
local offer_index = 1

local function restart_sound()

  sprite:set_frame(0)

  -- Repeat a sound synchronized with the sprite.
  sol.timer.stop_all(blacksmith)
  sol.timer.start(blacksmith, 750, function()
    sol.audio.play_sound("sword_tapping")
    sol.timer.start(blacksmith, 1000, function()
      sol.audio.play_sound("sword_tapping")
      return true
    end)
  end)
end

function map:on_opening_transition_finished()

  restart_sound()
end

local function offer_sword()

  game:start_dialog("gerudo_village.blacksmith.offer_sword", function(answer)
    if answer == 3 then
      hero:start_treasure("sword", 2)
    end
  end)
end

local function offer_glove()

  game:start_dialog("gerudo_village.blacksmith.offer_glove", function(answer)
    if answer == 3 then
      hero:start_treasure("glove", 2)
    end
  end)
end

local function offer_bow()

  game:start_dialog("gerudo_village.blacksmith.offer_bow", function(answer)
    if answer == 3 then
      hero:start_treasure("bow_silver", 2)  -- 2 to have the variant with arrows on the icon.
    end
  end)
end

function blacksmith:on_interaction()

  local num_crystals = game:get_num_crystals()
  local sword = game:get_item("sword")
  local glove = game:get_item("glove")

  restart_sound()

  if num_crystals < 2 then
    game:start_dialog("gerudo_village.blacksmith.not_now")
    return
  end

  local offers = { offer_sword, offer_glove, offer_bow }

  local allowed = {
    sword:get_variant() == 1,
    glove:get_variant() == 1,
    game:has_item("bow") and not game:has_item("bow_silver") and game:has_all_crystals()
  }

  for i = 1, #offers do
    if allowed[offer_index] then
      offers[offer_index]()
      offer_index = (offer_index % 3 + 1)
      return
    end
    offer_index = (offer_index % 3 + 1)
  end

  -- No item can improved now: show a default dialog.
  game:start_dialog("gerudo_village.blacksmith.hello")
  return

end
