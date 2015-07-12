local presentation_screen = {}

local presentation_img = sol.surface.create("menus/presentation.png")

function presentation_screen:on_draw(dst_surface)

  presentation_img:draw(dst_surface)
end

function presentation_screen:on_key_pressed(key)

  if key == "return" or key == "space" then
    sol.audio.play_sound("pause_closed")
    sol.menu.stop(presentation_screen)
  end
end

return presentation_screen
