-- renderer.lua

renderer = {
  sprites = {}
}

function renderer.spr(_n, _x, _y, _z, _w, _h, _flip_x, _flip_y)

  if _flip_x == nil then _flip_x = false end
  if _flip_y == nil then _flip_y = false end

  local _spr = {
    n = _n,
    x = _x,
    y = _y,
    z = _z or 0,
    w = _w or 1,
    h = _h or 1,
    flip_x = _flip_x,
    flip_y = _flip_y,
  }



  local _inserted = false
  for _i, _s in ipairs(renderer.sprites) do
    if _spr.z < _s.z then
      add(renderer.sprites, _spr, _i)
      _inserted = true
      break
    end
  end

  if not _inserted then
    add(renderer.sprites, _spr)
  end
end

function renderer.draw()
  for _i, _s in ipairs(renderer.sprites) do

    spr(_s.n, _s.x, _s.y, _s.w, _s.h, _s.flip_x, _s.flip_y)
  end
  renderer.sprites = {}
end

-- algorithms
function visit_line(_x0, _y0, _x1, _y1, _function)
  local _dx =  abs(_x1-_x0)
  local _sx = -1
  if _x0<_x1 then _sx = 1 end
  local _dy = -abs(_y1-_y0)
  local _sy = -1
  if _y0<_y1 then _sy = 1 end
  local _err = _dx+_dy  --/* error value e_xy */
  while true do   --/* loop */
      if not _function(_x0, _y0) then break end
      if (_x0 == _x1 and _y0 == _y1) then break end
      local _e2 = 2*_err
      if _e2 >= _dy then--/* e_xy+e_x > 0 */
          _err = _err + _dy
          _x0 = _x0 + _sx
      end
      if _e2 <= _dx then --/* e_xy+e_y < 0 */
          _err = _err + _dx
          _y0 = _y0 + _sy
      end
  end
end

function plot_line(_x0, _y0, _x1, _y1, _color)
  visit_line(_x0, _y0, _x1, _y1, function(_x, _y)
    pset(_x, _y, _color)
  end)
end
