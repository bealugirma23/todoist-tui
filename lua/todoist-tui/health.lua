local config = require("todoist-tui.config")

local M = {}

function M.check()
  vim.health.start("todoist-tui")

  -- Check plenary
  local has_plenary, _ = pcall(require, "plenary")
  if has_plenary then
    vim.health.ok("plenary.nvim installed")
  else
    vim.health.error("plenary.nvim is missing. It is required for todoist-tui to work.")
  end

  -- Check Token
  local token = config.get_token()
  if token and token ~= "" then
    local masked = string.sub(token, 1, 4) .. string.rep("*", #token - 8) .. string.sub(token, -4)
    vim.health.ok("Todoist API Token found: " .. masked)
  else
    vim.health.error("Todoist API Token not found.", {
      "Set config.token in setup()",
      "OR export TODOIST_API_TOKEN in your environment"
    })
  end
end

return M
