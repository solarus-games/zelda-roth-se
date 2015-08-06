-- This script opens doors with common conditions like killing enemies.

local door_manager = {}

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
