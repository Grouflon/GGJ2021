-- camera.lua

CAMERA_X_AMPLITUDE = 15
CAMERA_Y_AMPLITUDE = 15

function make_camera(_player, _level)
  local _e = make_entity()
  _e.player = _player
  _e.level = _level
  _e.x = _player.body.x + 4
  _e.y = _player.body.y + 4

  _e.start = function(self)
  end

  _e.stop = function(self)
  end

  _e.update = function(self, _dt)
  end

  _e.camera = function(self)

    local _player_x, _player_y = self.player.body.x + 4, self.player.body.y + 4
    local _dx, _dy = _player_x - self.x, _player_y - self.y

    if _dx < -CAMERA_X_AMPLITUDE then
      self.x = _player_x + CAMERA_X_AMPLITUDE
    elseif _dx > CAMERA_X_AMPLITUDE then
      self.x = _player_x - CAMERA_X_AMPLITUDE
    end

    if _dy < -CAMERA_Y_AMPLITUDE then
      self.y = _player_y + CAMERA_Y_AMPLITUDE
    elseif _dy > CAMERA_Y_AMPLITUDE then
      self.y = _player_y - CAMERA_Y_AMPLITUDE
    end

    local _bounds_x_min, _bounds_y_min = self.level.x_min * 8 + 64, self.level.y_min * 8 + 64
    local _bounds_x_max, _bounds_y_max = self.level.x_max * 8 - 56, self.level.y_max * 8 - 56
    self.x = mid(_bounds_x_min, _bounds_x_max, self.x)
    self.y = mid(_bounds_y_min, _bounds_y_max, self.y)

    camera(flr(self.x - 64), flr(self.y - 64))
  end

  return _e
end
