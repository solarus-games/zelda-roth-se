-- Kakariko shop.
local map = ...
local game = map:get_game()

function map:on_started()

  -- Move everything to the right once the bow is purchased.
  if game:get_value("kakariko_shop_bow") then
    if shop_heart ~= nil then
      shop_heart:set_position(48, 64)
    end
    if shop_small_magic_flask ~= nil then
      shop_small_magic_flask:set_position(96, 64)
    end
    if shop_big_magic_flask ~= nil then
      shop_big_magic_flask:set_position(144, 64)
    end
    if shop_arrow ~= nil then
      shop_arrow:set_position(192, 64)
    end
    if shop_bomb ~= nil then
      shop_bomb:set_position(240, 64)
    end
  else
    if game:get_value("kakariko_shop_bow_reduced_price") then
      -- Reduced price on the bow.
      shop_bow_1000:set_enabled(false)
    else
      -- Bow of 1000 rupees.
      shop_bow:set_enabled(false)
    end
  end
end

function merchant:on_interaction()

  if not game:get_value("kakariko_shop_bow_reduced_price") and game:get_value("kakariko_leader_first_dialog") then
    game:start_dialog("kakariko.shop.reduced_bow", function()
      shop_bow:set_enabled(true)
      shop_bow_1000:set_enabled(false)
      game:set_value("kakariko_shop_bow_reduced_price", true)
    end)
  else
    game:start_dialog("shop.choose")
  end
end
