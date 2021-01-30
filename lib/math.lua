-- math.lua

-- vec2
vec2 = {}
vec2.__index = vec2

function vec2.new(_x, _y)
  local _v = {
    x = _x or 0,
    y = _y or 0
  }
  setmetatable(_v, vec2)
  return _v
end

function vec2:set(_x, _y)
  self.x = _x
  self.y = _y
end

function vec2:add(_v)
  return vec2.new(self.x + _v.x, self.y + _v.y)
end

function vec2:sub(_v)
  return vec2.new(self.x - _v.x, self.y - _v.y)
end

function vec2:mul(_s)
  return vec2.new(self.x * _s, self.y * _s)
end

function vec2:dot(_v)
  return self.x * _v.x + self.y * _v.y
end

function vec2:len()
  return sqrt(self.x * self.x + self.y * self.y)
end

function vec2:normalized()
  local _len = self:len()
  if _len > 0.0 then
    return vec2.new(self.x / _len, self.y / _len)
  else
    return vec2.new()
  end
end

function vec2:is_zero(_threshold)
  _threshold = _threshold or 0.01
  return abs(self.x) <= _threshold and abs(self.y) <= _threshold
end

function vec2:copy(_v)
  return vec2.new(self.x, self.y)
end

function vec2:__tostring()
  return "{"..self.x..","..self.y.."}"
end

function vec2.lerp(_a, _b, _t)
  return vec2.new(
    math.lerp(_a.x, _b.x, _t),
    math.lerp(_a.y, _b.y, _t)
  )
end

-- math
function clamp01(_v)
  return mid(0.0, 1.0, _v)
end

function lerp(_a, _b, _t)
  return _a + (_b - _a) * _t
end

function rnd(_x)
  local _flr = flr(_x)
  local _rmd = _x - _flr
  if _rmd > 0.5 then
    return ceil(_x)
  else
    return _flr
  end
end

function bool_to_sign(_b)
  if _b then
    return 1.0
  else
    return -1.0
  end
end

D2P = 1 / 360.0 -- degrees to Pico-8 angle unit
P2D = 360.0 -- Pico-8 angle unit to degrees

-- collision
collision = {}

function collision.AABB_AABB(_x_min_A, _y_min_A, _x_max_A, _y_max_A, _x_min_B, _y_min_B, _x_max_B, _y_max_B)
  return not (
     _x_max_A <= _x_min_B
  or _y_max_A <= _y_min_B
  or _x_max_B <= _x_min_A
  or _y_max_B <= _y_min_A
  )
end

-- easing {}
easing = {}

function easing.linear(_t)
  return _t
end

function easing.quad_in(_t)
  return _t * _t
end

function easing.quad_out(_t)
  return -_t * (_t - 2.0)
end

function easing.quad_inout(_t)
  if _t <= 0.5 then
    return _t * _t * 2.0;
  else
    _t = _t - 1.0;
    return 1.0 - _t * _t * 2.0
  end
end

function easing.back_in(_t)
  return _t * _t * (2.70158 * _t - 1.70158)
end

function easing.back_out(_t)
  _t = _t - 1.0;
  return 1.0 - _t * _t * (-2.701580 * _t - 1.701580)
end

function easing.back_inout(_t)
  _t = _t * 2.0;

  if _t < 1.0 then
    return _t * _t * (2.70158 * _t - 1.70158) / 2.0
  else
  	_t = _t - 2.0
  	return (1.0 - _t * _t * (-2.70158 * _t - 1.70158)) / 2.0 + 0.5
  end
end
