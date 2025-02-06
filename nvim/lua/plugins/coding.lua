return {
  -- Incremental rename
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = true,
  },

  -- Refactoring tool
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = false,
    config = function()
      require("refactoring").setup({
        show_success_message = true,
      })
    end,
  },
  { "mini.surround", opts = {} },
  {
    "okuuva/auto-save.nvim",
    opts = { -- See :h events
      immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" }, -- vim events that trigger an immediate save
      defer_save = false, -- vim events that trigger a deferred save (saves after `debounce_delay`) "InsertLeave", "TextChanged"
      cancel_deferred_save = false, -- vim events that cancel a pending deferred save "InsertEnter"
    },
    keys = {
      { "<leader>uN", "<cmd>ASToggle<cr>", desc = "Toggle auto-save" },
    },
  },
}
