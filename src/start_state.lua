function require_start_state()
    local start_state = {
        on_start = function()
            printh('hello', 'log');
        end,

        on_stop = function()

        end,

        update = function()

        end,

        draw = function()

        end
    }

    return start_state
end
