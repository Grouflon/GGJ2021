-- entities.lua

entity = {}
entity.__index = entity

function make_entity()
  local _e = {
    start = entity_start,
    update = entity_update,
    draw = entity_draw,
    stop = entity_stop
  }
  return _e
end

function entity_start(self) end
function entity_update(self, _dt) end
function entity_draw(self) end
function entity_stop(self) end

-- manager
entity_manager = {
  entities_to_add = {},
  entities = {},
}

function entity_manager.add(_entity)
  add(entity_manager.entities_to_add, _entity)
end

function entity_manager.remove(_entity)
  local _result = del(entity_manager.entities_to_add, _entity)
  if _result == nil then
    _entity.to_remove = true
  end
end

function entity_manager.update(_dt)
  _dt = _dt or 1
  -- add new
  for _e in all(entity_manager.entities_to_add) do
    add(entity_manager.entities, _e)
    _e:start()
  end
  entity_manager.entities_to_add = {}

  -- update
  for _e in all(entity_manager.entities) do
    _e:update(_dt)
  end

  -- clear removed
  local _i = 1
  while entity_manager.entities[_i] ~= nil do
    local _e = entity_manager.entities[_i]
    if _e.to_remove then
      _e:stop()
      deli(entity_manager.entities, _i)
    else
      _i = _i + 1
    end
  end
end

function entity_manager.draw()
  for _e in all(entity_manager.entities) do
    _e:draw()
  end
end
