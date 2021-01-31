-- game.lua

TRANSITION_TIME = 60

blackout_color = 0

--override_level_start = 6
level_list = {
  { 28, 0, 43, 15 }, -- move tuto
  { 45, 0, 60, 15 }, -- gaps tuto
  { 60, 0, 75, 23 }, -- wall jump tuto
  { 75, 0, 112, 20 }, -- tri-kitten
  { 60, 23, 75, 38 }, -- platform tuto
  { 27, 15, 60, 30 }, -- platform 2 floors
  { 112, 0, 127, 20 }, -- hard platform stuff

  --{ 0, 0, 26, 21 }, -- debug level
}

game = {
  states = {},
  current_state = nil,
  next_level = 0,
  current_level = -1,

  update = function(self)
    if self.current_state then
      self.current_state:update()
    end
  end,

  draw = function(self)
    if self.current_state and self.current_state.draw then
      self.current_state:draw()
    end
  end,

  set_state = function(self, _state_name)
    local _target_state = self.states[_state_name]
    if _target_state ~= self.current_state then
      if self.current_state then
        self.current_state:exit()
      end
      self.current_state = _target_state
      if self.current_state then
        self.current_state:enter()
      end
    end
  end,
}

game.states.splash_screen = {

  advancing = false,

  enter = function(self)
    game.current_level = -1
    self.advancing = false
    blackout:fade_out(100, blackout_color)
  end,
  update = function(self)
    if not self.advancing then
      if blackout.timer <= 0 then
        if btnp(4) then
          blackout_color = 0
          self.advancing = true
          blackout:fade_in(100, blackout_color)
        end
      end
    else
      if blackout.timer >= blackout.time then
        game.next_level = start_level
        game:set_state("enter_level")
      end
    end
  end,
  draw = function()

    rect(5, 5, 121, 121, 1)

    local _title_x, _title_y = 24, 44
    print("yet another cat game" , _title_x, _title_y, 1)
    print("yet another cat game" , _title_x + 1, _title_y + 1, 2)
    print("yet another cat game" , _title_x + 2, _title_y + 2, 9)
    print("press 🅾️ to start" , 31, 80, 1)
    color()
  end,
  exit = function()
  end,
}

game.states.end_screen = {

  advancing = false,

  enter = function(self)
    game.current_level = -1
    self.advancing = false
    blackout:fade_out(100, blackout_color)
  end,
  update = function(self)
    if not self.advancing then
      if blackout.timer <= 0 then
        if btnp(4) then
          self.advancing = true
          blackout_color = 0
          blackout:fade_in(100, blackout_color)
        end
      end
    else
      if blackout.timer >= blackout.time then
        game:set_state("splash_screen")
      end
    end
  end,
  draw = function()

    rect(5, 5, 121, 121, 1)

    color(9)
    print("the end" , 51, 30)
    print("a game by remi bismuth" , 20, 50)
    print("made in 48h for ggj2021" , 18, 58)
    print("press 🅾️ to continue" , 24, 85)
    color()
  end,
  exit = function()
  end,
}

game.states.enter_level = {
  enter = function()
    local _l = level_list[game.next_level + 1]
    assert(_l ~= nil)
    game.current_level = game.next_level
    level = make_level(_l[1], _l[2], _l[3], _l[4])
    level.player.can_move = false
    entity_manager.add(level)
    blackout:fade_out(TRANSITION_TIME, blackout_color)
    tutorial_step = 0
  end,
  update = function()
    if blackout.timer <= 0 then
      game:set_state("game")
    end
  end,
  exit = function()
  end,
}

game.states.game = {
  enter = function()
    level.player.can_move = true
  end,
  update = function()
    local _player = level.player
    if _player.dead then
      game:set_state("dead")
    else
      if #level.kittens > 0 then -- if no kitten in the level, you just can't win
        local _found_all_kittens = true
        for _i, _k in ipairs(level.kittens) do
          if not _k.found then
            _found_all_kittens = false
            break
          end
        end

        if _found_all_kittens then
          game.next_level = game.current_level + 1
          blackout_color = 14

          if game.next_level >= #level_list then
            blackout_color = 9
            game.next_level = -1 --end game
          end
          game:set_state("victory")
        end
      end
    end
  end,
  exit = function()
    level.player.can_move = false
  end,
}

game.states.dead = {
  enter = function()
    death_timer = 0
  end,
  update = function()
    death_timer = death_timer + 1
    local _skip_wanted = btn(4) or btn(0) or btn(1)
    if death_timer > 200 or death_timer > 25 and _skip_wanted then
      game.next_level = game.current_level
      blackout_color = 0
      game:set_state("exit_level")
    end
  end,
  exit = function()
  end,
}

game.states.victory = {
  enter = function()
    jingle_timer = 0
    sfx(0, -2)
    sfx(2)
  end,
  update = function()
    jingle_timer = jingle_timer + 1
    if jingle_timer > 92 then
      sfx(1)
      game:set_state("exit_level")
    end
  end,
  exit = function()
  end,
}

game.states.exit_level = {
  enter = function()
    blackout:fade_in(TRANSITION_TIME, blackout_color)
  end,
  update = function()
    if blackout.timer == blackout.time then
      if game.next_level < 0 then
        game:set_state("end_screen")
      else
        game:set_state("enter_level")
      end
    end
  end,
  exit = function()
    entity_manager.remove(level)
    level = nil
  end,
}
