-- cat.lua

JUMP_CURVE = { -4, -4, -4, -3, -3, -3, -2, -2, -1, 0, 0, 0 }
SEGMENT_COUNT = 4

function make_animation_state(_cat)
  local _s = {}
  _s.cat = _cat
  _s.segments = {}
  for _i = 1, SEGMENT_COUNT do
    add(_s.segments, { _cat.body.x, _cat.body.y })
  end
  _s.active = false
  _s.timer = 0.0
  _s.time = 0.0

  _s.ratio = function(self)
    if self.time == 0.0 then
      if self.active then
        return 1.0
      else
        return 0.0
      end
    else
      return self.timer / self.time
    end
  end
  return _s
end

function make_cat(_x, _y)
  local _e = make_entity()
  _e.body = collider.new(_x, _y, 2, 0, 6, 8, LAYER_PLAYER, _e)
  _e.ground_probe = collider.new(0, 0, 2, 0, 6, 1, LAYER_PROBE, _e)
  _e.flip = false
  _e.grounded = false
  _e.jump_curve_dir = -1
  _e.jump_curve_index = #JUMP_CURVE

  _e.animation = {
    states = {
      idle = make_animation_state(_e),
      trail = make_animation_state(_e),
    },

    update = function(self, _dt)
      for _id, _state in pairs(self.states) do
        if _state.active then
          _state.timer = min(_state.timer + _dt, _state.time)
        else
          _state.timer = max(_state.timer - _dt, 0.0)
        end

        local _ratio = _state:ratio()
        if _ratio > 0.0 then
          _state:update(_dt)
        end
      end
    end,

    get_segments = function(self)
      local _segments = {}
      for _i = 1, SEGMENT_COUNT do
        add(_segments, { 0, 0 })
      end

      for _id, _state in pairs(self.states) do
        local _ratio = _state:ratio()
        if _ratio > 0.0 then
          for _i = 1, SEGMENT_COUNT do
            _segments[_i][1] = _segments[_i][1] + _ratio * _state.segments[_i][1]
            _segments[_i][2] = _segments[_i][2] + _ratio * _state.segments[_i][2]
          end
        end
      end

      return _segments
    end,

    set_state = function(self, _name, _time)
      if self.states[_name] == nil then return end
      for _id, _state in pairs(self.states) do
        local _ratio = _state:ratio()
        _state.active = _id == _name
        _state.time = _time
        _state.timer = _time * _ratio
      end
    end,
  }

  _e.animation.states.idle.update = function(self, _dt)
    local _cat = self.cat
    local _sign = bool_to_sign(_cat.flip)
    for _i = 1, SEGMENT_COUNT do
      self.segments[_i][1] = _cat.body.x + flr(_i * 1 * _sign)
      self.segments[_i][2] = _cat.body.y
    end
  end

  _e.animation.states.trail.update = function(self, _dt)
    local _cat = self.cat
    local _sign = bool_to_sign(_cat.flip)
    for _i = 1, SEGMENT_COUNT do
      local _index = min(_i, #_cat.pos_samples)
      local _x, _y = _cat.pos_samples[_index][1], _cat.pos_samples[_index][2]
      local _dx = _x - _cat.body.x
      local _min_dx = flr(_i * 0.5* _sign)
      if _cat.flip then
        _x = _cat.body.x + max(_dx, _min_dx)
      else
        _x = _cat.body.x + min(_dx, _min_dx)
      end
      self.segments[_i][1] = _x
      self.segments[_i][2] = _y
    end
  end

  _e.animation:set_state("trail", 0.0)

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
      self.jump_curve_dir = 1
      self.jump_curve_index = 1
      self.grounded = false
      --log("jump")
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

    if not _previous_grounded and self.grounded then
    end

    if _previous_grounded and not self.grounded then
      self.jump_curve_dir = -1
      self.jump_curve_index = #JUMP_CURVE
    end

    add(self.pos_samples, { self.body.x, self.body.y }, 1)
    while (#self.pos_samples > 20) do
      deli(self.pos_samples)
    end

    if self.grounded then
      self.animation:set_state("idle", 5)
    else
      self.animation:set_state("trail", 5)
    end

    self.animation:update(_dt)
  end


  _e.draw = function(self)
    local _b = self.body
    local _sign = bool_to_sign(self.flip)

    -- segments
    local _segments = self.animation:get_segments()
    for _i, _segment in ipairs(_segments) do
      renderer.spr(2, _segment[1], _segment[2], 0, 1, 1, self.flip)
    end
    local _last_segment = last(_segments)

    -- tail
    local _tail_offset = 1
    if not self.flip then _tail_offset = -2 end
    local _tail_base_x, _tail_base_y = _last_segment[1] + 4 + _tail_offset, _last_segment[2] + 2
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
    renderer.spr(3, _last_segment[1] + 2 * _sign, _last_segment[2], 0, 1, 1, self.flip)
    renderer.spr(3, _b.x, _b.y, 0, 1, 1, self.flip)

    -- head
    renderer.spr(1, _b.x, _b.y, 0, 1, 1, self.flip)
  end

  return _e
end
