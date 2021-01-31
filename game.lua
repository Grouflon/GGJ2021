-- game.lua

TRANSITION_TIME = 60

game = {
  states = {},
  current_state = nil,
  next_level = 0,
  current_level = 0,

  update = function(self)
    if self.current_state then
      self.current_state.update()
    end
  end,

  set_state = function(self, _state_name)
    local _target_state = self.states[_state_name]
    if _target_state ~= self.current_state then
      if self.current_state then
        self.current_state.exit()
      end
      self.current_state = _target_state
      if self.current_state then
        self.current_state.enter()
      end
    end
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
    blackout:fade_out(TRANSITION_TIME, 0)
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
          game.next_level = (game.current_level + 1) % #level_list
          game:set_state("exit_level")
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
    if death_timer > 200 or death_timer > 25 and btn(4) then
      game.next_level = game.current_level
      game:set_state("exit_level")
    end
  end,
  exit = function()
  end,
}

game.states.exit_level = {
  enter = function()
    blackout:fade_in(TRANSITION_TIME, 0)
  end,
  update = function()
    if blackout.timer == blackout.time then
      game:set_state("enter_level")
    end
  end,
  exit = function()
    entity_manager.remove(level)
    level = nil
  end,
}
