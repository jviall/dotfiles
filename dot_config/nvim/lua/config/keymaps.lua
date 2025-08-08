-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyLazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end
local unmap = vim.keymap.del
local opts = { noremap = true, silent = true }

-- move buffers
unmap("n", "<S-h>")
unmap("n", "<S-l>")
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })

-- Split window
map("n", "ss", ":split<Return>", opts)
map("n", "sv", ":vsplit<Return>", opts)
-- Larger window resize increments
map("n", "<leader>w+", ":resize +15<Return>", { desc = "Increase height +15" })
map("n", "<leader>w-", ":resize -15<Return>", { desc = "Decrease height +15" })
map("n", "<leader>w>", ":vertical resize +15<Return>", { desc = "Increase width +15" })
map("n", "<leader>w<", ":vertical resize -15<Return>", { desc = "Decrease width +15" })

-- Disable move-lines
unmap("n", "<A-j>")
unmap("n", "<A-k>")
unmap("i", "<A-j>")
unmap("i", "<A-k>")
unmap("v", "<A-j>")
unmap("v", "<A-k>")

-- Refactoring
-- stylua: ignore 
vim.keymap.set({ "n", "x" }, "<leader>rbb", function() return require('refactoring').refactor('Extract Block') end, { expr = true, desc = "Extract Block" })
-- stylua: ignore 
vim.keymap.set({ "n", "x" }, "<leader>rbf", function() return require('refactoring').refactor('Extract Block To File') end, { expr = true, desc = "Extract Block To File" })
