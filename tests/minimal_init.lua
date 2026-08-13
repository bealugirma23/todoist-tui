-- tests/minimal_init.lua
local is_windows = vim.fn.has("win32") == 1
local slash = is_windows and "\\" or "/"

local tmp_dir = vim.fn.stdpath("cache") .. slash .. "todoist_tui_tests"
local pack_dir = tmp_dir .. slash .. "site" .. slash .. "pack"
local vendor_dir = pack_dir .. slash .. "vendor" .. slash .. "start"
local plenary_dir = vendor_dir .. slash .. "plenary.nvim"

local function install_plenary()
  if vim.fn.isdirectory(plenary_dir) == 1 then
    return
  end

  print("Installing plenary.nvim...")
  vim.fn.mkdir(vendor_dir, "p")

  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/nvim-lua/plenary.nvim",
    plenary_dir,
  }

  local res = vim.fn.system(clone_cmd)
  if vim.v.shell_error ~= 0 then
    error("Failed to clone plenary.nvim: " .. res)
  end

  local checkout_cmd = {
    "git",
    "-C",
    plenary_dir,
    "checkout",
    "74b06c6c75e4eeb3108ec01852001636d85a932b"
  }

  res = vim.fn.system(checkout_cmd)
  if vim.v.shell_error ~= 0 then
    error("Failed to checkout pinned commit: " .. res)
  end
end

install_plenary()

vim.opt.packpath = pack_dir
vim.opt.runtimepath:append(pack_dir)
vim.opt.runtimepath:append(plenary_dir)
vim.opt.runtimepath:append(vim.fn.getcwd())


