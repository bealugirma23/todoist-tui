local config = require("todoist-tui.config")
local layout = require("todoist-tui.ui.layout")
local sync = require("todoist-tui.api.sync")
local cache = require("todoist-tui.cache")

local M = {}

M.setup = function(opts)
  config.setup(opts)
  require("todoist-tui.highlights").setup()
  -- Pre-load cache so it's ready when the user opens the UI
  cache.load()
end

M.toggle = function()
  if layout.is_open() then
    layout.close()
  else
    layout.open()
    sync.sync(false) -- incremental sync on open
  end
end

M.sync = function()
  sync.sync(true) -- force full sync
end

M.add_token = function(token)
  if not token or token == "" then
    vim.ui.input({ prompt = "Todoist API Token: ", secret = true }, function(input)
      if input and input ~= "" then
        M.add_token(input)
      end
    end)
    return
  end

  -- temporarily set token for the test request
  local old_token = config.options.token
  config.options.token = token

  vim.notify("Testing Todoist token...", vim.log.levels.INFO)

  local client = require("todoist-tui.api.client")
  client.post("sync", { sync_token = "*", resource_types = {"user"} }, function(_, err)
    if err then
      config.options.token = old_token -- revert
      vim.notify("TodoistTokenAdd failed: " .. tostring(err), vim.log.levels.ERROR)
    else
      if config.save_token(token) then
        vim.notify("TodoistTokenAdd successful!", vim.log.levels.INFO)
      else
        config.options.token = old_token
        vim.notify("TodoistTokenAdd failed: Could not write token to disk", vim.log.levels.ERROR)
      end
    end
  end)
end

return M
