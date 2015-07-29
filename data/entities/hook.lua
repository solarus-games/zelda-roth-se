-- An entity the hookshot can attach to.
local hook = ...

-- Tell the hookshot that we are a hook.
function hook:is_hook()
  return true
end

hook:set_traversable_by(false)
