pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

#include lib/math.lua
#include lib/particles.lua
#include lib/physics.lua
--#include lib/perlin.lua
#include lib/entities.lua
#include lib/renderer.lua
#include lib/log.lua
#include lib/table.lua

-- ⬅️➡️⬆️⬇️ ❎🅾️

LAYER_PLAYER = 0b1
LAYER_WALLS = 0b10
LAYER_PROBE = 0b100
LAYER_SPIKES = 0b1000
LAYER_KITTEN = 0b10000

#include cat.lua
#include camera.lua
#include level.lua
#include blackout.lua
#include kitten.lua
#include game.lua

level_list = {
  { 28, 0, 43, 15 },
  { 0, 0, 26, 21 },
}

level = nil
blackout = nil
tutorial_step = 0

function _init()
  poke(0x5F5C, 255) -- set the initial delay before repeating input. 255 means never repeat.

  blackout = make_blackout()
  game.next_level = 0
  game:set_state("enter_level")
end

function _update60()
  cls()
  entity_manager.update()
  blackout:update(1)

  game:update()

  if game.current_level == 0 then
    if level.player.body.x > 290 then
      tutorial_step = 1
    end
  end
end

fade_time = 0
function _draw()

  camera()
  if game.current_level == 0 then
    color(1)
    if tutorial_step == 0 then
      print("use ⬅️/➡️ to move", 30, 30)
      print("press 🅾️ to jump", 32, 38)
    elseif tutorial_step == 1 then
      print("find all your lost kittens", 13, 30)
      print("to clear the level", 27, 38)

    end
  end
  cursor()

  level.camera:camera()



  entity_manager.draw()
  renderer.draw()

  --physics.draw(LAYER_PLAYER, 8)
  --physics.draw(LAYER_WALLS, 12)
  --physics.draw(LAYER_PROBE, 11)
  --physics.draw(LAYER_SPIKES, 15)
  --physics.draw(LAYER_KITTEN, 14)

  for _i, _k in ipairs(level.kittens) do
    if not _k.found then
      _k:draw_feedback()
    end
  end

  camera()

  blackout:draw()

  --[[for _n, _state in pairs(game.states) do
    if _state == game.current_state then
      print(_n)
    end
  end]]--

  color()
  --print(stat(0))
  --print(stat(1))

  draw_log()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000099000000000000000909000000000000000000000000000000000000000000
00000000009009000000000000000000000000000000000000000000000000000099900000c00c00000999000009090000000000000000000000000000000000
00700700009999000000000000000000000000000000000000000000000000000099909000cccc000009e90000099900000909000009090000090900000e0e00
0007700009939390009990000000000000000000000000000000000000999000009999900c6cc6c0055555550555555505555555000999000009990000eeeee0
0007700009a999a00999990000000000000000000000000000000000099999000099393906cccc60005d5d50005d5d50005d5d500009e90000099900000eee00
0070070000999900009990000009090000009090009090000009090009999000009a999a00cccc00005d5d50005d5d50005d5d500000e000000000000000e000
00000000000000000000000000090900000009090909000000090900000000000099999000000000005d5d50005d5d50005d5d50000000000000000000000000
00000000000000000000000000090900000000000000000000000000000000000090000000000000005d5d50005d5d50005d5d50000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000001000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000001000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000001005555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000001055555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000404040400000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000040000000400000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000a00000000000000000000004040000000400000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040404040404040404040404040404000000000400000404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000400000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000004000000000004000000000000000004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000404040400000404040000000000000004000000000000000004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000400000000000000000004000000000004040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000400000000000004000000100004040404040400000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040000000400000404040404000000040400000400000000000004040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000400000004040000000400000400000004040004040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004040000000400000000000004000004040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004040000000400000000000000000004040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010000000000004000000040400000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000040404040404000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004000000040400000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004000000000400000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414000000a00400000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
