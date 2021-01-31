-- level.lua

function make_wall(_x, _y, _sprite)
  local _e = make_entity()
  _e.sprite = _sprite
  _e.width = 1
  _e.start = function(self)
    self.body = collider.new(_x, _y, 0, 0, 8 * self.width, 8, LAYER_WALLS, _e)
    physics.register(self.body)
  end
  _e.stop = function(self)
    physics.unregister(self.body)
    self.body = nil
  end
  _e.draw = function(self)
    for _i = 0, self.width - 1 do
      spr(_sprite, self.body.x + _i * 8, self.body.y)
    end
  end
  return _e
end

function make_spike(_x, _y)
  local _e = make_entity()
  _e.body = collider.new(_x, _y, 0, 6, 8, 8, LAYER_SPIKES, _e)
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

function make_moving_wall(_x, _y, _width, _height, _x_start, _y_start, _x_stop, _y_stop)
  local _e = make_entity()
  _e.body = collider.new(_x, _y, 0, 0, _width * 8, _height * 8, LAYER_WALLS, _e)
  _e.width = _width
  _e.height = _height
  _e.x_start, _e.y_start = _x_start, _y_start
  _e.x_stop, _e.y_stop = _x_stop, _y_stop
  _e.speed = 0.5
  _e.direction = 1
  _e.attached_cats = {}

  _e.start = function(self)
    physics.register(self.body)


  end
  _e.stop = function(self)
    physics.unregister(self.body)
  end
  _e.update = function(self, _dt)
    local _b = self.body
    local _initial_x, _initial_y = _b.x, _b.y

    local _x_stop = max(self.x_stop - (self.width - 1) * 8, self.x_start)
    local _y_stop = max(self.y_stop - (self.height - 1) * 8, self.y_start)

    _b.x = mid(_b.x + self.direction * self.speed, self.x_start, _x_stop)
    _b.y = mid(_b.y + self.direction * self.speed, self.y_start, _y_stop)

    if _b.x == _x_stop and _b.y == _y_stop then
      self.direction = -1
    elseif _b.x == self.x_start and _b.y == self.y_start then
      self.direction = 1
    end

    local _dx, _dy = _b.x - _initial_x, _b.y - _initial_y
    for _, _cat in ipairs(self.attached_cats) do
      _cat.body.x = _cat.body.x + _dx
      _cat.body.y = _cat.body.y + _dy
    end
    self.attached_cats = {}
  end
  _e.draw = function(self)
    local _b_x, _b_y = flr(_e.body.x), flr(_e.body.y)
    for _y = 0, self.height - 1 do
    for _x = 0, self.width - 1 do
      spr(66, _b_x + _x * 8, _b_y + _y * 8)
    end
    end
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

      if _spr == 64 then -- wall
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
        elseif (_spr >= 66 and _spr <= 68) or (_spr >= 70 and _spr <= 72) then
          local _width = 1
          local _height = 1
          if _spr >= 70 then
            _height = _spr - 69
          else
            _width = _spr - 65
          end

          local _x_start = _x
          for _i = _x - 1, _x_min, -1 do
            local _spr2 = mget(_i, _y)
            if _spr2 == 69 then
              _x_start = _i
              break
            elseif _spr2 ~= 0 then
              break
            end
          end
          local _x_stop = _x
          for _i = _x + 1, _x_max, 1 do
            local _spr2 = mget(_i, _y)
            if _spr2 == 69 then
              _x_stop = _i
              break
            elseif _spr2 ~= 0 then
              break
            end
          end
          local _y_start = _y
          for _i = _y - 1, _y_min, -1 do
            local _spr2 = mget(_x, _i)
            if _spr2 == 69 then
              _y_start = _i
              break
            elseif _spr2 ~= 0 then
              break
            end
          end
          local _y_stop = _y
          for _i = _y + 1, _y_max, 1 do
            local _spr2 = mget(_x, _i)
            if _spr2 == 69 then
              _y_stop = _i
              break
            elseif _spr2 ~= 0 then
              break
            end
          end

          _entity = make_moving_wall(_px, _py, _width, _height, _x_start * 8, _y_start * 8, _x_stop * 8, _y_stop * 8)
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
