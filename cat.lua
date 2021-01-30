-- cat.lua

JUMP_CURVE = { -4, -4, -4, -3, -3, -3, -2, -2, -1, 0, 0, 0 }

function make_cat(_x, _y)
  local _e = make_entity()
  _e.body = collider.new(_x, _y, 1, 0, 7, 8, LAYER_PLAYER, _e)
  _e.ground_probe = collider.new(0, 0, 1, 0, 7, 1, LAYER_PROBE, _e)
  _e.x = _x
  _e.y = _y
  _e.flip = false
  _e.grounded = false
  _e.jump_curve_dir = -1
  _e.jump_curve_index = #JUMP_CURVE
  _e.segment_count = 5
  _e.segments = {}
  for _i = 0, _e.segment_count -  1 do
    add(_e.segments, { _x, _y })
  end
  _e.pos_samples = {}

  _e.start = function(self)
    physics.register(self.body)
    physics.register(self.ground_probe)
  end

  _e.stop = function(self)
    physics.unregister(self.ground_probe)
    physics.unregister(self.body)
  end

  _e.update = function(self, _dt)
    local _dir_x, _dir_y = 0, 0
    if btn(0) then _dir_x = _dir_x - 1 end
    if btn(1) then _dir_x = _dir_x + 1 end

    if _dir_x < 0 then
      self.flip = true
    elseif _dir_x > 0 then
      self.flip = false
    end

    if self.grounded and btnp(4) then
      --log(self.grounded)
      self.jump_curve_dir = 1
      self.jump_curve_index = 1
      self.grounded = false
    end

    if not self.grounded then
      _dir_y = _dir_y + JUMP_CURVE[self.jump_curve_index] * self.jump_curve_dir
      self.jump_curve_index = mid(self.jump_curve_index + self.jump_curve_dir, 1, #JUMP_CURVE)
      if self.jump_curve_index == #JUMP_CURVE then
        self.jump_curve_dir = -1
      end
    end

    physics.move(_e.body, _dir_x, _dir_y, LAYER_WALLS)

    self.ground_probe.x = self.body.x
    self.ground_probe.y = self.body.y + 8
    local _previous_grounded = self.grounded
    self.grounded = physics.test(self.ground_probe, LAYER_WALLS)

    if _previous_grounded and not self.grounded then
      self.jump_curve_dir = -1
      self.jump_curve_index = #JUMP_CURVE
    end

    add(self.pos_samples, { self.body.x, self.body.y }, 1)
    while (#self.pos_samples > 20) do
      deli(self.pos_samples)
    end

    for _i = 1, self.segment_count do
      local _index = min(_i, #self.pos_samples)
      local _x, _y = self.pos_samples[_index][1], self.pos_samples[_index][2]
      self.segments[_i][1] = _x
      self.segments[_i][2] = _y
    end
  end


  _e.draw = function(self)
    local _b = self.body

    local _sign = 1
    if self.flip then _sign = -1 end

    -- segments
    for _i, _segment in ipairs(self.segments) do
      renderer.spr(2, _segment[1], _segment[2], 0, 1, 1, self.flip)
    end
    local _last_segment = last(self.segments)

    -- tail
    local _tail_base_x, _tail_base_y = _last_segment[1] + 4 - 1 * _sign, _last_segment[2] + 1
    local _px, _py = _tail_base_x, _tail_base_y
    local _tail_length = 5
    for _ty = 0, _tail_length do
      local _x_ratio = _ty / _tail_length
      local _tx = _x_ratio * sin(time() * 1.0 + _ty * 0.1) * 3

      local _nx = _tail_base_x + rnd(_tx)
      local _ny = _tail_base_y - _ty
      plot_line(_px, _py, _nx, _ny, 9)
      _px = _nx
      _py = _ny
    end

    -- legs
    renderer.spr(3, _last_segment[1], _last_segment[2], 0, 1, 1, self.flip)
    renderer.spr(3, _b.x, _b.y, 0, 1, 1, self.flip)

    -- head
    renderer.spr(1, _b.x, _b.y, 0, 1, 1, self.flip)
  end

  return _e
end
