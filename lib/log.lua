-- log.lua

LOG_DISPLAY_TIME = 3.0 -- seconds

logs = {}

function log(_str, _c)
  _c = _c or 6
  local _log = {
    str = tostr(_str),
    c = _c,
    time = time(),
  }

  add(logs, _log)
end

function draw_log()

  local _i = #logs
  local _y = 0
  while _i > 0 do
    local _log = logs[_i]
    local _t = time() - _log.time
    if _t > LOG_DISPLAY_TIME then
      deli(logs, _i)
    else
      print(_log.str, 0, _y * 7, _log.c)
      _y = _y + 1
    end
    _i = _i - 1
  end
end
