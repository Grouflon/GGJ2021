-- physics.lua

-- collider
collider = {}
collider.__index = collider

function collider.new(_x, _y, _min_x, _min_y, _max_x, _max_y, _layer_mask, _entity)
  local _c = {
    x = _x or 0,
    y = _y or 0,
    min_x = _min_x or 0,
    min_y = _min_y or 0,
    max_x = _max_x or 0,
    max_y = _max_y or 0,
    entity = _entity,

    layer_mask = _layer_mask,
  }
  setmetatable(_c, collider)
  return _c
end

function collider:center()
  local _x = self.x + self.min_x + (self.max_x - self.min_x) * 0.5
  local _y = self.y + self.min_y + (self.max_y - self.min_y) * 0.5
  return _x, _y
end

function collider:min(_x, _y)
  _x = _x or self.x
  _y = _y or self.y
  return _x + self.min_x, _y + self.min_y
end

function collider:max(_x, _y)
  _x = _x or self.x
  _y = _y or self.y
  return _x + self.max_x, _y + self.max_y
end

function collider:draw(_color)
  color(_color)
  local _min_x, _min_y = self:min()
  local _max_x, _max_y = self:max()
  rect(
    _min_x,
    _min_y,
    _max_x - 1,
    _max_y - 1
  )
end

-- physics

physics = {
  colliders = {}
}

function physics.register(_collider)
  add(physics.colliders, _collider)
end

function physics.unregister(_collider)
  del(physics.colliders, _collider)
end

function physics.test(_collider, _layer_mask, _out_hit_colliders)
  local _result = false
  for _i, _c in ipairs(physics.colliders) do
    if band(_layer_mask, _c.layer_mask) ~= 0 then
      local _min_x_A, _min_y_A = _collider:min()
      local _max_x_A, _max_y_A = _collider:max()
      local _min_x_B, _min_y_B = _c:min()
      local _max_x_B, _max_y_B = _c:max()

      if collision.AABB_AABB(
        _min_x_A, _min_y_A, _max_x_A, _max_y_A,
        _min_x_B, _min_y_B, _max_x_B, _max_y_B
      )
      then
        if _out_hit_colliders ~= nil then
          add(_out_hit_colliders, _c)
        end
        _result = true
      end
    end
  end
  return _result
end

function physics.move(_collider, _delta_x, _delta_y, _layer_mask, _sweep)
  _sweep = _sweep or false
  if _sweep then
  else
    -- X
    if _delta_x ~= 0 then
      _collider.x = _collider.x + _delta_x

      for _i, _c in ipairs(physics.colliders) do
        if band(_layer_mask, _c.layer_mask) ~= 0 then
          local _min_x_A, _min_y_A = _collider:min()
          local _max_x_A, _max_y_A = _collider:max()
          local _min_x_B, _min_y_B = _c:min()
          local _max_x_B, _max_y_B = _c:max()

          if collision.AABB_AABB(
            _min_x_A, _min_y_A, _max_x_A, _max_y_A,
            _min_x_B, _min_y_B, _max_x_B, _max_y_B
          )
          then
            -- collision
            local _1 = _max_x_B - _min_x_A
            local _2 = _min_x_B - _max_x_A
            local _delta = 0
            if (abs(_1) < abs(_2)) then
              _delta = _1
            else
              _delta = _2
            end
            _collider.x = _collider.x + _delta
          end
        end
      end
    end

    -- Y
    if _delta_Y ~= 0 then
      _collider.y = _collider.y + _delta_y

      for _i, _c in ipairs(physics.colliders) do
        if band(_layer_mask, _c.layer_mask) ~= 0 then
          local _min_x_A, _min_y_A = _collider:min()
          local _max_x_A, _max_y_A = _collider:max()
          local _min_x_B, _min_y_B = _c:min()
          local _max_x_B, _max_y_B = _c:max()

          if collision.AABB_AABB(
            _min_x_A, _min_y_A, _max_x_A, _max_y_A,
            _min_x_B, _min_y_B, _max_x_B, _max_y_B
          )
          then
            -- collision
            local _1 = _max_y_B - _min_y_A
            local _2 = _min_y_B - _max_y_A
            local _delta = 0
            if (abs(_1) < abs(_2)) then
              _delta = _1
            else
              _delta = _2
            end
            _collider.y = _collider.y + _delta
          end
        end
      end
    end
  end
end

function physics.draw(_layer_mask, _color)
  for _i, _c in ipairs(physics.colliders) do
    if band(_layer_mask, _c.layer_mask) ~= 0 then
      _c:draw(_color)
    end
  end
end
