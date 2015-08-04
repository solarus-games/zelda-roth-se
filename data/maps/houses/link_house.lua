local map = ...
local game = map:get_game()

local night_overlay = sol.surface.create(map:get_size())
local alpha = 192
night_overlay:fill_color({0, 0, 64, alpha})

function map:on_started(destination)

  if destination ~= from_intro then
    snores:remove()
    night_overlay:clear()  -- No night.
    return
  end

  -- The intro scene is playing.
  -- Let the hero sleep for two second.
  game:set_pause_allowed(false)
  snores:get_sprite():set_ignore_suspend(true)
  bed:get_sprite():set_animation("hero_sleeping")
  hero:freeze()
  hero:set_visible(false)
  sol.timer.start(map, 2000, function()
    -- Show Zelda's message.
    game:start_dialog("link_house.zelda_message", function()
      sol.timer.start(map, 1000, function()
        -- Wake up.
        snores:remove()
        bed:get_sprite():set_animation("hero_waking")
        sol.timer.start(map, 500, function()
          -- Jump from the bed.
          hero:set_visible(true)
          hero:start_jumping(0, 24, true)
          game:set_pause_allowed(true)
          game:set_hud_enabled(true)
          bed:get_sprite():set_animation("empty_open")
          sol.audio.play_sound("hero_lands")

          -- Start the savegame from outside the bed next time.
          game:set_starting_location(map:get_id(), "from_savegame")

          -- Make the sun rise.
          sol.timer.start(map, 20, function()
            alpha = alpha - 1
            if alpha <= 0 then
              alpha = 0
            end
            night_overlay:clear()
            night_overlay:fill_color({0, 0, 64, alpha})

            -- Continue the timer if there is still night.
            return alpha > 0  
          end)

        end)
      end)
    end)
  end)
end

-- Show the night overlay.
function map:on_draw(dst_surface)

  night_overlay:draw(dst_surface)
end

