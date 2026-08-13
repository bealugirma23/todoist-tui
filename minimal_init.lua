-- minimal_init.lua
-- Set up a temporary directory for data and state
local root = vim.fn.fnamemodify("./.tests", ":p")
for _, name in ipairs({ "config", "data", "state", "cache" }) do
  vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- Bootstrap lazy.nvim
local lazypath = root .. "/plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  {
    dir = vim.fn.getcwd(), -- Load the plugin from the current directory
    config = function()
      require("todoist-tui").setup()
    end,
  },
}, {
  root = root .. "/plugins",
})
