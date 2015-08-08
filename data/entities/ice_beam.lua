-- An ice beam that can unlight torches and freeze water.
local ice_beam = ...
local sprites = {}
local ice_path_sprite

local enemies_touched = {}

function ice_beam:on_created()

  ice_beam:set_size(8, 8)
  ice_beam:set_origin(4, 5)
  for i = 0, 2 do 
    sprites[#sprites + 1] = ice_beam:create_sprite("entities/ice_beam")
  end
end

-- Traversable rules.
ice_beam:set_can_traverse("crystal", true)
ice_beam:set_can_traverse("crystal_block", true)
ice_beam:set_can_traverse("hero", true)
ice_beam:set_can_traverse("jumper", true)
ice_beam:set_can_traverse("stairs", false)
ice_beam:set_can_traverse("stream", true)
ice_beam:set_can_traverse("switch", true)
ice_beam:set_can_traverse("teletransporter", true)
ice_beam:set_can_traverse_ground("deep_water", true)
ice_beam:set_can_traverse_ground("shallow_water", true)
ice_beam:set_can_traverse_ground("hole", true)
ice_beam:set_can_traverse_ground("lava", true)
ice_beam:set_can_traverse_ground("prickles", true)
ice_beam:set_can_traverse_ground("low_wall", true)
ice_beam.apply_cliffs = true

-- Hurt enemies.
ice_beam:add_collision_test("sprite", function(ice_beam, entity)

  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_ice_reaction(enemy_sprite)
    enemy:receive_attack_consequence("ice", reaction)
    ice_beam:remove()
  end
end)

function ice_beam:go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)

  -- Compute the coordinate offset of each sprite.
  local x = math.cos(angle) * 16
  local y = -math.sin(angle) * 16
  sprites[1]:set_xy(2 * x, 2 * y)
  sprites[2]:set_xy(x, y)

  sprites[1]:set_animation("1")
  sprites[2]:set_animation("2")
  sprites[3]:set_animation("3")

  movement:start(ice_beam)
end

function ice_beam:on_obstacle_reached()

  ice_beam:remove()
end

function ice_beam:on_position_changed()

  local _, _, layer = ice_beam:get_position()
  local x, y = ice_beam:get_center_position()
  local head_dx, head_dy = sprites[1]:get_xy()
  x, y = x + head_dx, y + head_dy
  local map = ice_beam:get_map()

  if map:get_ground(x, y, layer) == "deep_water" then
    -- TODO check that the whole 16x16 square is on deep water

    local snapped_x = math.floor((x + 8) / 16) * 16
    local snapped_y = math.floor((y + 8) / 16) * 16

    -- TODO create only one entity and extend it
    local ice_path = map:create_custom_entity({
      x = snapped_x,
      y = snapped_y,
      layer = layer,
      width = 16, 
      height = 16,
      direction = 0,
      ground = "ice",
    })
    ice_path:set_modified_ground("ice")
    ice_path_sprite = sol.sprite.create("entities/ice")

    function ice_path:on_post_draw()

      local x, y, width, height = ice_path:get_bounding_box()
      map:draw_sprite(ice_path_sprite, x, y)
    end
  end
end
