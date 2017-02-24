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

    sol.timer.start(ice_beam, 200, function()
      ice_beam:remove()
    end)
  end
end)

-- Create an ice square at the specified place if there is deep water.
local function check_square(x, y)

  local map = ice_beam:get_map()
  local _, _, layer = ice_beam:get_position()

  -- Top-left corner of the candidate 16x16 square.
  x = math.floor(x / 16) * 16
  y = math.floor(y / 16) * 16

  -- Check that the four corners of the 16x16 square are on deep water.
  if map:get_ground(      x,      y, layer) ~= "deep_water" or
      map:get_ground(x + 15,      y, layer) ~= "deep_water" or
      map:get_ground(     x, y + 15, layer) ~= "deep_water" or
      map:get_ground(x + 15, y + 15, layer) ~= "deep_water" then
    return
  end

  local ice_path = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = 0,
  })
  ice_path:set_origin(0, 0)
  ice_path:set_modified_ground("ice")
  ice_path:create_sprite("entities/ice")
end

-- Create ice on two squares around the specified place if there is deep water.
local function check_two_squares(x, y)

  local movement = ice_beam:get_movement()
  if movement == nil then
    return
  end
  local direction4 = movement:get_direction4()
  local horizontal = (direction4 % 2) == 0
  if horizontal then
    check_square(x, y - 8)
    check_square(x, y + 8)
  else
    check_square(x - 8, y)
    check_square(x + 8, y)
  end
end

function ice_beam:go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_max_distance(320)
  movement:set_smooth(false)

  -- Compute the coordinate offset of each sprite.
  local x = math.cos(angle) * 16
  local y = -math.sin(angle) * 16
  sprites[1]:set_xy(2 * x, 2 * y)
  sprites[2]:set_xy(x, y)
  sprites[3]:set_xy(0, 0)

  sprites[1]:set_animation("1")
  sprites[2]:set_animation("2")
  sprites[3]:set_animation("3")

  movement:start(ice_beam)

  -- The head of the beam will be used to determine candidate squares,
  -- so make sure we don't forget the first squares.
  local ice_beam_x, ice_beam_y = ice_beam:get_position()
  local dx, dy = sprites[2]:get_xy()
  check_two_squares(ice_beam_x + dx, ice_beam_y + dy)
  dx, dy = sprites[1]:get_xy()
  check_two_squares(ice_beam_x + dx, ice_beam_y + dy)
end

function ice_beam:on_obstacle_reached()

  ice_beam:remove()
end

function ice_beam:on_movement_finished()
  ice_beam:remove()
end

function ice_beam:on_position_changed()

  if sprites[1] == nil then
    -- Not initialized yet.
    return
  end

  -- Create ice if there is deep water on the leading two squares.
  local x, y = ice_beam:get_center_position()
  local head_dx, head_dy = sprites[1]:get_xy()
  x, y = x + head_dx, y + head_dy

  check_two_squares(x, y)
end
