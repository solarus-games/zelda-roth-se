-- This script opens doors with common conditions like killing enemies,
-- based on the name of the door and of enemies.
-- Doors with prefix auto_door are automatically opened when killing
-- the last enemy with prefix auto_enemy_<door_name>.

local door_manager = {}

function door_manager:manage_map(map)

  -- Find doors with prefix auto_door.
  for door in map:get_entities("auto_door") do
    -- If there are enemies whose name matches the door, link them to the door.
    door_manager:open_when_enemies_dead(door)
  end
end

function door_manager:open_when_enemies_dead(door)

  local door_prefix = door:get_name()
  local enemy_prefix = "auto_enemy_" .. door_prefix

  local map = door:get_map()
  local enemies = {}
  local function enemy_on_dead()
    if door:is_closed() and not map:has_entities(enemy_prefix) then
      sol.audio.play_sound("secret")
      map:open_doors(door_prefix)
    end
  end

  for enemy in map:get_entities(enemy_prefix) do
    enemy.on_dead = enemy_on_dead
  end
end

return door_manager
