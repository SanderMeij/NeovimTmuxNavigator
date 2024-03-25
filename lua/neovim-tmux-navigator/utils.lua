local M = {}

M.get_window_layouts = function()
    local windows = vim.api.nvim_tabpage_list_wins(0)
    local result = {}
    for _, winid in ipairs(windows) do
        result[winid] = {
            width = vim.api.nvim_win_get_width(winid),
            height = vim.api.nvim_win_get_height(winid),
            position = vim.api.nvim_win_get_position(winid),
        } 
    end
    return result
end

return M
