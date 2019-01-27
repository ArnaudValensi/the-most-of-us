function require_change_state()
    local function change_state(to_state, options)
    cls()
    state.on_stop()
    state = to_state
    to_state.on_start(options)
    to_state.update()
  end

  return change_state
end
