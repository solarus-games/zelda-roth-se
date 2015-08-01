-- An entity the hookshot can attach to.
local hookable = ...

-- Tell the hookshot that we are a hook.
function hookable:is_hookable()
  return true
end

hookable:set_traversable_by(false)
