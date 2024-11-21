Similar to https://github.com/alexghergh/nvim-tmux-navigation, but with the ability to hook actions in when you reach the last pane on a side.

I use it with the following lazy.nvim config:

```lua
M = {
    'SanderMeij/NeovimTmuxNavigator',
    opts = {
        bottom_reached = function()
            os.execute("tmux split-window -l 10")
        end,
        left_reached = function()
            vim.cmd("vsplit")
        end,
        right_reached = function()
            vim.cmd("vsplit")
        end
    },
    keys = {
        { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
        { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
        { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
        { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
    }
}

return M
```
This enables me to always execute commands in the window context with a single key press `<c-j>`
