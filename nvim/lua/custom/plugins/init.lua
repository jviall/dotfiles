-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'craftzdog/solarized-osaka.nvim',
    branch = 'osaka',
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent = true,
      }
    end,
  },
  { import = 'lazyvim.plugins.extras.linting.eslint' },
  { import = 'lazyvim.plugins.extras.formatting.prettier' },
  { import = 'lazyvim.plugins.extras.lang.typescript' },
  { import = 'lazyvim.plugins.extras.lang.json' },
  { import = 'lazyvim.plugins.extras.lang.rust' },
  { import = 'lazyvim.plugins.extras.lang.tailwind' },
  { import = 'lazyvim.plugins.extras.coding.copilot' },
  { import = 'lazyvim.plugins.extras.util.mini-hipatterns' },
}
