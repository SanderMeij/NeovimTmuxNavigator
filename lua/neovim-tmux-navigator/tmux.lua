M = {}

local directions = {
    left = "L",
    right = "R",
    up = "U",
    down = "D",
}

local ends = {
    left = "left",
    right = "right",
    up = "top",
    down = "bottom",
}

M.query_flag = function(flag)
    local cmd = string.format("echo $(tmux display-message -p '#{%s}')", flag)
    local handle = io.popen(cmd)
    if handle == nil then
        return 0
    end
    local pane_at_bottom = handle:read("*a")
    handle:close()
    return pane_at_bottom == "1\n"
end

M.end_reached = function(direction)
    return M.query_flag("pane_at_" .. ends[direction])
end

M.execute = function(cmd)
    os.execute("tmux " .. cmd)
end

M.select_pane = function(direction)
    M.execute("select-pane -" .. directions[direction])
end

return M
