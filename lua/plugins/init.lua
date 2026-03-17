return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {"christoomey/vim-tmux-runner"},

  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      require("smart-splits").setup({
        -- Multiplexer integration: tmux
        multiplexer_integration = "tmux",
      })
      -- Navigasi pane: Ctrl+h/j/k/l (override nvim default, extend ke tmux)
      vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left,  { desc = "move to left split/pane" })
      vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down,  { desc = "move to lower split/pane" })
      vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up,    { desc = "move to upper split/pane" })
      vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "move to right split/pane" })
      -- Resize pane: Alt+arrow
      vim.keymap.set("n", "<A-Left>",  require("smart-splits").resize_left,  { desc = "resize left" })
      vim.keymap.set("n", "<A-Down>",  require("smart-splits").resize_down,  { desc = "resize down" })
      vim.keymap.set("n", "<A-Up>",    require("smart-splits").resize_up,    { desc = "resize up" })
      vim.keymap.set("n", "<A-Right>", require("smart-splits").resize_right, { desc = "resize right" })
    end,
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      terminal = { enabled = true },
      notifier = { enabled = true },
    },
  },

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    lazy = false,
    config = function()
      require("claudecode").setup({
        terminal = {
          provider = "snacks",
          snacks_win_opts = {
            position = "float",
            width = 0.99,
            height = 0.99,
            border = "none",
          },
        },
      })
    end,
  },
}
