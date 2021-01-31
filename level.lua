-- level.lua

function make_wall(_x, _y, _sprite)
  local _w = make_entity()
  _w.sprite = _sprite
  _w.width = 1
  _w.start = function(self)
    self.body = collider.new(_x, _y, 0, 0, 8 * self.width, 8, LAYER_WALLS, _w)
    physics.register(self.body)
  end
  _w.stop = function(self)
    physics.unregister(self.body)
    self.body = nil
  end
  _w.draw = function(self)
    for _i = 0, self.width - 1 do
      spr(_sprite, self.body.x + _i * 8, self.body.y)
    end
  end
  return _w
end

function make_spike(_x, _y)
  local _e = make_entity()
  _e.body = collider.new(_x, _y, 0, 6, 8, 8, LAYER_SPIKES, _w)
  _e.start = function(self)
    physics.register(self.body)
  end
  _e.stop = function(self)
    physics.unregister(self.body)
  end
  _e.draw = function(self)
    spr(65, self.body.x, self.body.y)
  end
  return _e
end

function make_level(_x_min, _y_min, _x_max, _y_max)
  local _e = make_entity()
  _e.player = nil
  _e.kittens = {}
  _e.entities = {}
  _e.x_min, _e.y_min = _x_min, _y_min
  _e.x_max, _e.y_max = _x_max, _y_max

  -- generate entities
  local _current_wall = nil
  for _y = _y_min, _y_max do
    for _x = _x_min, _x_max do
      local _spr = mget(_x, _y)
      local _px, _py = _x * 8, _y * 8

      if fget(_spr, 0) == true then -- wall
        if _current_wall then
          _current_wall.width = _current_wall.width + 1
        else
          _current_wall = make_wall(_px, _py, _spr)
        end
      else
        if _current_wall then
          add(_e.entities, _current_wall)
          _current_wall = nil
        end

        local _entity = nil
        if _spr == 0 then
          -- nop
        elseif _spr == 1 then -- cat
          _e.player = make_cat(_px, _py)
        elseif _spr == 65 then
          _entity = make_spike(_px, _py)
        elseif _spr >= 10 and _spr <= 12 then
          _entity = make_kitten(_px, _py)
          add(_e.kittens, _entity)
        end

        if _entity ~= nil then
          add(_e.entities, _entity)
        end
      end
    end
    if _current_wall then
      add(_e.entities, _current_wall)
      _current_wall = nil
    end
  end

  add(_e.entities, _e.player) -- we add player after all the LD to control update order

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
