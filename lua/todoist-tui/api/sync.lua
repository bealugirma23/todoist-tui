local client = require("todoist-tui.api.client")
local state = require("todoist-tui.state")
local cache = require("todoist-tui.cache")

local M = {}

M.status = "idle"

function M.sync(force)
  if M.is_syncing then return end
  M.is_syncing = true
  M.status = "active"
  state.data.ui.sync_status = "syncing"
  state.notify()

  local sync_token = force and "*" or state.data.sync_token

  local data = {
    sync_token = sync_token,
    resource_types = { "projects", "items", "sections", "labels" },
  }

  client.post("sync", data, function(res, err)
    M.is_syncing = false
    if err then
      M.status = "error"
      state.data.ui.sync_status = "error"
      vim.notify("Todoist Sync Error: " .. tostring(err), vim.log.levels.ERROR)
      state.notify()
      return
    end

    M.status = "idle"
    state.data.ui.sync_status = "idle"
    if res then
      state.update_from_sync(res)
      cache.save()
    end
  end)
end

return M
