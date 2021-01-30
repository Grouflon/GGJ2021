-- level.lua

function make_wall(_x, _y, _sprite)
  local _w = make_entity()
  _w.body = collider.new(_x, _y, 0, 0, 8, 8, LAYER_WALLS, _w)
  _w.sprite = _sprite
  _w.start = function(self)
    physics.register(self.body)
  end
  _w.stop = function(self)
    physics.unregister(self.body)
  end
  _w.draw = function(self)
    spr(_sprite, self.body.x, self.body.y)
  end
  return _w
end

function make_level(_x_min, _y_min, _x_max, _y_max)
  local _e = make_entity()
  _e.player = nil
  _e.entities = {}
  _e.x_min, _e.y_min = _x_min, _y_min
  _e.x_max, _e.y_max = _x_max, _y_max

  -- generate entities
  for _y = _y_min, _y_max do
  for _x = _x_min, _x_max do
    local _spr = mget(_x, _y)
    if _spr == 0 then
      -- nop
    elseif _spr == 1 then -- cat
      _e.player = make_cat(_x * 8, _y * 8)
      add(_e.entities, _e.player)
    elseif fget(_spr, 0) == true then -- wall
      local _w = make_wall(_x * 8, _y * 8, _spr)
      add(_e.entities, _w)
    end
  end
  end

  --bounds walls
  local _left = _x_min * 8
  local _top = _y_min * 8
  local _right = (_x_max + 1) * 8
  local _bottom = (_y_max + 1) * 8
  local _width = _right - _left
  local _height = _bottom - _top
  _e.bounds = {}
  add(_e.bounds, collider.new(_left, _top, 0, -8, _width, 0, LAYER_WALLS, _e)) -- top
  add(_e.bounds, collider.new(_left, _top, -8, 0, 0, _height, LAYER_WALLS, _e)) -- left
  add(_e.bounds, collider.new(_right, _bottom, -_width, 0, 0, 8, LAYER_WALLS, _e)) -- bottom
  add(_e.bounds, collider.new(_right, _bottom, 0, -_height, 8, 0, LAYER_WALLS, _e)) -- right

  -- camera
  _e.camera = make_camera(_e.player, _e)
  add(_e.entities, _e.camera)

  _e.start = function(self)
    for _, _entity in ipairs(self.entities) do
      entity_manager.add(_entity)
    end

    for _, _collider in ipairs(self.bounds) do
      physics.register(_collider)
    end
  end

  _e.stop = function(self)
    for _, _collider in ipairs(self.bounds) do
      physics.unregister(_collider)
    end

    for _, _entity in ipairs(self.entities) do
      entity_manager.remove(_entity)
    end
  end
  return _e
end
