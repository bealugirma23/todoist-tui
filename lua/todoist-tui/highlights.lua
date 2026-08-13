local config = require("todoist-tui.config")

local M = {}

local default_links = {
  TodoistNormal = "NormalFloat",
  TodoistBorder = "FloatBorder",
  TodoistTitle = "Title", -- Fallback is Title
  TodoistPanelFocused = "Title",
  TodoistCursorLine = "CursorLine",
  TodoistProjectName = "Directory",
  TodoistProjectFavorite = "Constant",
  TodoistPriorityP1 = "DiagnosticError",
  TodoistPriorityP2 = "DiagnosticWarn",
  TodoistPriorityP3 = "DiagnosticInfo",
  TodoistPriorityP4 = "Comment",
  TodoistDueOverdue = "DiagnosticError",
  TodoistDueToday = "DiagnosticWarn",
  TodoistDueFuture = "Comment",
  TodoistCompleted = "Comment",
  TodoistLabel = "Special",
  TodoistFooterKey = "Function",
  TodoistFooterDesc = "Comment",
  TodoistSyncIdle = "Comment",
  TodoistSyncActive = "DiagnosticInfo",
  TodoistSyncError = "DiagnosticError",
}

function M.setup()
  -- Register namespace
  M.ns_id = vim.api.nvim_create_namespace("todoist_tui")
  M.apply()

  -- Reapply on ColorScheme change
  local group = vim.api.nvim_create_augroup("TodoistTuiHighlights", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      M.apply()
    end,
  })
end

function M.apply()
  local custom_links = config.options.highlights or {}

  -- Ensure FloatTitle exists (added in nvim 0.9 for border titles, fallback to Title)
  local has_float_title = vim.fn.hlexists("FloatTitle") == 1
  if has_float_title and not custom_links.TodoistTitle then
    default_links.TodoistTitle = "FloatTitle"
  end

  for group, default_link in pairs(default_links) do
    local link = custom_links[group] or default_link
    vim.api.nvim_set_hl(0, group, { link = link, default = true })
  end

  -- Completed items need strikethrough
  local completed_target = custom_links.TodoistCompleted or default_links.TodoistCompleted
  local target_hl = vim.api.nvim_get_hl(0, { name = completed_target, link = false })
  local hl_def = vim.tbl_extend("force", target_hl, { strikethrough = true, default = true })
  vim.api.nvim_set_hl(0, "TodoistCompleted", hl_def)
end

return M
