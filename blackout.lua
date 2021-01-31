-- blackout.lua

--[[BLACKOUT_PATTERN_1 = {
  0b1111111111111111.1,
  0b1111111111011111.1,
  0b1111100110011111.1,
  0b1001000000001001.1,
  0b0000000000000000.1,
}]]--

BLACKOUT_PATTERN_2 = {
  0b1111111111111111.1,
  0b1110111111111111.1,
  0b1100111011111111.1,
  0b1000110011101111.1,
  0b0000100011001110.1,
  0b0000000010001100.1,
  0b0000000000001000.1,
  0b0000000000000000.1,
}

--[[BLACKOUT_PATTERN_3 = {
  0b1111111111111111.1,
  0b1111101111111111.1,
  0b1111100111111111.1,
  0b1111100111011111.1,
  0b1111100110011111.1,
  0b1111100100011111.1,
  0b1111000100011111.1,
  0b0111000100011111.1,
  0b0011000100011111.1,
  0b0001000100011111.1,
  0b0000000100011111.1,
  0b0000000000011111.1,
  0b0000000000001111.1,
  0b0000000000001110.1,
  0b0000000000001100.1,
  0b0000000000001000.1,
  0b0000000000000000.1,
}]]--


function make_blackout()
  local _e = make_entity()

  _e.timer = 0.0
  _e.time = 0.0
  _e.color = 0
  _e.direction = 0
  _e.fade_length = 32
  _e.easing = easing.linear

  _e.fade_in = function(self, _time, _color)
    self.time = _time
    self.direction = 1
    self.timer = 0
    self.color = _color
  end

  _e.fade_out = function(self, _time, _color)
    self.time = _time
    self.direction = -1
    self.timer = _time
    self.color = _color
  end

  _e.update = function(self, _dt)
    self.timer = mid(0, self.timer + _dt * self.direction, self.time)
  end
  _e.draw = function(self)

      local _f = function (_x, _y, _t, _length)
        _y = 128 - _y
        local _i = sqrt(_x*_x + _y*_y)
        local _l = 181 + _length
        return clamp01((_length - (_i + _length - _t * _l)) / _length)
      end

      local _t = 0
      if self.time > 0 then
        _t = self.easing(self.timer / self.time)
      end

      for _my = 0, 15 do
      for _mx = 0, 15 do
        local _x, _y = _mx * 8, _my * 8
        local _r = _f(_x, _y, _t, self.fade_length)
        if _r > 0 then
          fillp(BLACKOUT_PATTERN_2[flr(_r * #BLACKOUT_PATTERN_2) + 1])
          rectfill(_x, _y, _x+8, _y+8, self.color)
        end
      end
      end
      fillp()
  end
  return _e
end
