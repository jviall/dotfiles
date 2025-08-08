-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
--  See `:help lua-guide-autocommands`
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.wo.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  buffer = 0,
  callback = function()
    vim.lsp.buf.signature_help()
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  -- stylua: ignore
  callback = function()
    -- disable default go-to keymaps
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = { "gd", false }
    keys[#keys + 1] = { "gD", false }
    keys[#keys + 1] = { "gr", false }
    keys[#keys + 1] = { "gI", false }
    keys[#keys + 1] = { "gy", false }
  end,
})
