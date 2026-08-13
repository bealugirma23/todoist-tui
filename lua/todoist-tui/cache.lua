local state = require("todoist-tui.state")
local M = {}

M.cache_path = vim.fn.stdpath("cache") .. "/todoist-tui-cache.json"

function M.save()
  local file = io.open(M.cache_path, "w")
  if file then
    local data = {
      sync_token = state.data.sync_token,
      projects = state.data.projects,
      sections = state.data.sections,
      tasks = state.data.tasks,
      labels = state.data.labels,
    }
    file:write(vim.fn.json_encode(data))
    file:close()
  end
end

function M.load()
  local file = io.open(M.cache_path, "r")
  if file then
    local content = file:read("*a")
    file:close()
    if content and content ~= "" then
      local ok, parsed = pcall(vim.fn.json_decode, content)
      if ok and parsed then
        state.data.sync_token = parsed.sync_token or "*"
        state.data.projects = parsed.projects or {}
        state.data.sections = parsed.sections or {}
        state.data.tasks = parsed.tasks or {}
        state.data.labels = parsed.labels or {}
      end
    end
  end
end

return M
