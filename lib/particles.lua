-- particles.lua

-- setting
setting = {}
setting.__index = setting

function setting.new(_val, _dev)
  local _s = { val = _val, dev = _dev }
  setmetatable(_s, setting)
  return _s
end

function setting:compute_random()
  return self.val + rnd(self.dev * 2.0) - self.dev
end

-- emitter
emitter = {}
emitter.__index = emitter

function emitter.new()
  local _e = {}
  setmetatable(_e, emitter)

  _e.active = false
  _e.to_spawn = 0
  _e.settings = {
    angle = setting.new( 0.0, 360.0 ),
    distance = {
      start = setting.new( 0.0, 0.0 ),
      stop = setting.new( 1.0, 0.0 )
    },
    life = setting.new( 10.0, 0.0 ),
    rate = setting.new( 1.0, 0.0 ),
    size = {
      start = setting.new( 1.0, 0.0 ),
      stop = setting.new( 1.0, 0.0 )
    },
    color = { 7, 6, 13, 5, 0 },
    easing = easing.linear,
    type = 0 -- 0 is rect, 1 is circle
  }

  _e._particles = {}
  _e._next_spawn = 0.0

  return _e
end

function emitter:update(_x, _y, _dt)
  _dt = _dt or 1.0

  local _spawn_time = _dt
  for _i, _p in ipairs(self._particles) do
    if _p.current_life >= 0.0 then
      _p.current_life = _p.current_life + _dt
      if _p.current_life >= _p.life then
        -- come back to the pool
        _p.current_life = -1.0
      end
    end


    if self.active or self.to_spawn > 0 then
      -- insert new particles in the free spots
      if _p.current_life < 0.0 and _spawn_time >= self._next_spawn then
        local _p = self:emit(_x, _y)
        self._particles[_i] = _p


        _p.current_life = _spawn_time
        _spawn_time = _spawn_time - self._next_spawn
        self._next_spawn = self.settings.rate:compute_random()
        self.to_spawn = max(0, self.to_spawn - 1)
      end
    end
  end

  if self.active or self.to_spawn > 0 then
    while _spawn_time >= self._next_spawn do
      local _p = self:emit(_x, _y)
      add(self._particles, _p)

      _p.current_life = _spawn_time
      _spawn_time = _spawn_time - self._next_spawn
      self._next_spawn = self.settings.rate:compute_random()
      self.to_spawn = max(0, self.to_spawn - 1)
    end

    self._next_spawn = self._next_spawn - _spawn_time
  end
end

function emitter:emit(_x, _y)
  local _life = self.settings.life:compute_random()
  local _angle = self.settings.angle:compute_random() * D2P
  local _dir = vec2.new(cos(_angle), sin(_angle))
  local _dist_start = self.settings.distance.start:compute_random()
  local _dist_stop = self.settings.distance.stop:compute_random()
  local _size = {
    start = self.settings.size.start:compute_random(),
    stop = self.settings.size.stop:compute_random(),
  }
  local _color = self.settings.color
  local _easing = self.settings.easing
  local _type = self.settings.type
  return particle.new(_x, _y, _life, _dir, _dist_start, _dist_stop, _size, _color, _easing, _type)
end

function emitter:draw()
  for _i, _p in ipairs(self._particles) do
    if _p.current_life >= 0.0 then
      _p:draw()
    end
  end
end

-- particle
particle = {}
particle.__index = particle
function particle.new(_x, _y, _life, _direction, _distance_start, _distance_stop, _size, _color, _easing, _type)
  local _p = {
    pos = vec2.new(_x, _y),
    current_life = 0.0,
    life = _life,
    direction = _direction:copy(),
    distance = {_distance_start, _distance_stop},
    size = _size,
    color = _color,
    easing = _easing,
    type = _type
  }
  setmetatable(_p, particle)
  return _p
end

function particle:draw()
  local _t = self.easing(clamp01(self.current_life / self.life))
  local _dist = lerp(self.distance[1], self.distance[2], _t)
  local _pos = self.pos:add(self.direction:mul(_dist))
  local _size = lerp(self.size.start, self.size.stop, _t)
  local _color_count = #self.color
  local _color = self.color[mid(1, _color_count, ceil(_t * _color_count))]

  local _half_size = _size * 0.5
  if self.type == 0 then
    rectfill(_pos.x - _half_size, _pos.y - _half_size, _pos.x + _half_size, _pos.y + _half_size, _color)
  elseif self.type == 1 then
    circfill(_pos.x, _pos.y, _half_size, _color)
  end
end
