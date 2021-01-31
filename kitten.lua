-- kitten.lua

KITTEN_ANIMATION = {
  12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
  11, 11,
  10, 10, 10, 10, 10, 10, 10, 10, 10,
  11, 11,
}

function make_kitten(_x, _y)
  local _e = make_entity()
  _e.body = collider.new(_x, _y, 2, 2, 7, 8, LAYER_KITTEN, _e)
  _e.animation_index = 0
  _e.found = false

  _e.start = function(self)
    physics.register(self.body)
  end
  _e.stop = function(self)
    physics.unregister(self.body)
  end
  _e.update = function(self, _dt)
    self.animation_index = (self.animation_index + 0.25) % #KITTEN_ANIMATION
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
  end
  return _e
end
