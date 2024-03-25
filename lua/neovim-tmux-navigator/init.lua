local M = {}

local inspect = require('vim.inspect')
local tmux = require('neovim-tmux-navigator.tmux')

local function get_window_layout(window)
    position = vim.api.nvim_win_get_position(window)
    return {
        window = window,
        width = vim.api.nvim_win_get_width(window),
        height = vim.api.nvim_win_get_height(window),
        x = position[2],
        y = position[1],
    }
end

local function switches (current_layout, cursor_position, direction)
    local coordinate = 'x'
    local length = 'width'
    local opposite_coordinate = 'y'
    local opposite_length = 'height'
    if direction == 'up' or direction == 'down' then
        coordinate, opposite_coordinate = opposite_coordinate, coordinate
        length, opposite_length = opposite_length, length
    end

    local can_switch = (direction == 'up' or direction == 'left') and
        function(layout) return current_layout[coordinate] - 1 == layout[coordinate] + layout[length] end or
        function(layout) return current_layout[coordinate] + current_layout[length] + 1 == layout[coordinate] end

    return function(layout)
        return can_switch(layout)
            -- and cursor_position[opposite_coordinate] >= layout[opposite_coordinate]
            -- and cursor_position[opposite_coordinate] <= layout[opposite_coordinate] + layout[opposite_length]
    end
end

local function switch_pane(direction, end_reached)
    local utils = require('neovim-tmux-navigator.utils')
    local current_window = vim.api.nvim_get_current_win()
    local current_layout = get_window_layout(current_window)

    local cursorY, cursorX = vim.api.nvim_win_get_cursor(current_window)
    local cursor_position = { x = cursorX, y = cursorY }

    local can_switch = switches(current_layout, cursor_position, direction)

    local windows = vim.api.nvim_tabpage_list_wins(0)
    local switched = false
    for _, window in ipairs(windows) do
        local layout = get_window_layout(window)
        if can_switch(layout) then
            vim.api.nvim_set_current_win(window)
            switched = true
            break
        end
    end
    if not switched then
        if tmux.query_flag("window_zoomed_flag") then
           tmux.execute('resize-pane -Z')
        end
        if tmux.end_reached(direction) then
            if end_reached ~= nil then
                end_reached()
            end
        else
            tmux.select_pane(direction)
        end
    end
end

function M.setup(opts)
    opts = opts or {}

    vim.api.nvim_create_user_command("TmuxNavigateDown" , function() switch_pane('down', opts['bottom_reached']) end, {})
    vim.api.nvim_create_user_command("TmuxNavigateLeft" , function() switch_pane('left', opts['left_reached']) end, {})
    vim.api.nvim_create_user_command("TmuxNavigateRight" , function() switch_pane('right', opts['right_reached']) end, {})
    vim.api.nvim_create_user_command("TmuxNavigateUp" , function() switch_pane('up', opts['top_reached']) end, {})
end

return M
