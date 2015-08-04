-- Configuration of the hookshot.
-- Feel free to change these values.

local config = {

  -- Range of the hookshot in pixels.
  distance = 208,

  -- Speed in pixels per second.
  speed = 256,

  -- What types of entities can be cought.
  -- Additionally, all entities that have a method "is_catchable_with_hookshot"
  -- returning true will be catchable.
  catchable_entity_types = { "pickable" },

  -- What types of entities the hookshot can attach to.
  -- Additionally, all entities that have a method "is_hookable"
  -- returning true will be hookable.
  hookable_entity_types = {},

}

return config
