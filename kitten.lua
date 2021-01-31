-- kitten.lua

KITTEN_ANIMATION = {
  12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
  11, 11,
  10, 10, 10, 10, 10, 10, 10, 10, 10,
  11, 11,
}

KITTEN_FEEDBACK_ANIMATION = {
  14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
  13, 13, 13, 13, 13, 13
}

function make_kitten(_x, _y)
  local _e = make_entity()
  _e.body = collider.new(_x, _y, 0, 2, 8, 8, LAYER_KITTEN, _e)
  _e.animation_index = 0
  _e.feedback_animation_index = 0
  _e.found = false

  _e.start = function(self)
    physics.register(self.body)
  end
  _e.stop = function(self)
    physics.unregister(self.body)
  end
  _e.update = function(self, _dt)
    self.animation_index = (self.animation_index + 0.25) % #KITTEN_ANIMATION
    self.feedback_animation_index = (self.feedback_animation_index + 0.25) % #KITTEN_FEEDBACK_ANIMATION
  end
  _e.draw = function(self)
    local _b = self.body
    if self.found then
      renderer.spr(15, _b.x, _b.y - 8, -1)
      renderer.spr(10, _b.x, _b.y, -1)
    else
      renderer.spr(KITTEN_ANIMATION[flr(self.animation_index) + 1], _b.x, _b.y, -1)
    end
  end
  _e.draw_feedback = function(self)
    local _cam = level.camera
    local _c_l = _cam.x - 64
    local _c_r = _cam.x + 64
    local _c_t = _cam.y - 64
    local _c_b = _cam.y + 64

    local _screen_segments = {
      { _c_l, _c_t, _c_r, _c_t },
      { _c_r, _c_t, _c_r, _c_b },
      { _c_r, _c_b, _c_l, _c_b },
      { _c_l, _c_b, _c_l, _c_t },
    }

    local _ray_start_x, _ray_start_y = level.player.body.x + 4, level.player.body.y + 4
    local _ray_stop_x, _ray_stop_y = self.body.x + 4, self.body.y + 4

    for _i, _s in ipairs(_screen_segments) do
      local _result, _x, _y = collision.segment_segment(
        _ray_start_x, _ray_start_y,
        _ray_stop_x, _ray_stop_y,
        _s[1], _s[2],
        _s[3], _s[4]
      )
      if _result then
        local _intersection = vec2.new(_x, _y)
        local _to_kitten_dir = vec2.new(_ray_stop_x - _ray_start_x, _ray_stop_y - _ray_start_y):normalized()

        local _origin = _intersection:sub(_to_kitten_dir:mul(10)):flr()
        local _origin2 = _intersection:sub(_to_kitten_dir:mul(5)):flr()
        --log(tostring(_origin).." "..tostring(_origin2))
        local _total_len = _origin:sub(_origin2):len()
        local _final_radius = 4
        local _color = 13

        --[[visit_line(_origin2.x, _origin2.y, _origin.x, _origin.y, function(__x, __y)
          local _l = vec2.new(__x,__y):sub(_origin2):len()
          local _radius = flr((_l / _total_len) * _final_radius)
          --log(tostring(_p).." "..tostring(_origin2))
          --log(_l.." ".._total_len)
          --log(vec2.new(__x,__y):sub(_origin2))
          if _radius > 0 then
            circfill(__x, __y, _radius, _color)
          end
          return true
        end)]]--

        circfill(_origin.x, _origin.y, _final_radius, _color)
        spr(KITTEN_FEEDBACK_ANIMATION[flr(self.feedback_animation_index) + 1], _origin.x - 4, _origin.y - 3)

        --circfill(_origin.x, _origin.x, _final_radius, _color)

        break
      end
    end
  end
  return _e
end
