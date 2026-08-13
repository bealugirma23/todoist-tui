local layout = require("todoist-tui.ui.layout")
local state = require("todoist-tui.state")
local hl = require("todoist-tui.highlights")
local util = require("todoist-tui.util")

local M = {}

function M.render()
  local buf = layout.bufs.detail
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local lines = {}
  local extmarks = {}
  local task_id = state.data.ui.selected_task_id
  local task = task_id and state.data.tasks[task_id] or nil

  if task then
    local project_name = state.data.projects[task.project_id] and state.data.projects[task.project_id].name or "Unknown"
    local due_str = task.due and type(task.due) == "table" and (task.due.string or task.due.date or "") or ""
    local priority_str = util.get_priority_icon(task.priority)

    local line1 = string.format("Due: %s · Priority: %s · Project: %s", due_str, priority_str, project_name)
    table.insert(lines, line1)

    -- Highlight Due
    if due_str ~= "" then
      local due_hl = util.get_date_hl(task.due)
      if due_hl then
        local due_start = 5
        local due_end = due_start + vim.fn.strlen(due_str)
        table.insert(extmarks, { line = 0, col_start = due_start, col_end = due_end, hl_group = due_hl })
      end
    end

    -- Highlight Priority
    local p_start = vim.fn.stridx(line1, priority_str)
    if p_start ~= -1 then
      table.insert(extmarks, { line = 0, col_start = p_start, col_end = p_start + vim.fn.strlen(priority_str), hl_group = util.get_priority_hl(task.priority) })
    end

    -- Highlight Project
    local prj_start = vim.fn.stridx(line1, project_name)
    if prj_start ~= -1 then
      table.insert(extmarks, { line = 0, col_start = prj_start, col_end = prj_start + vim.fn.strlen(project_name), hl_group = "TodoistProjectName" })
    end

    table.insert(lines, task.description or "")
  else
    table.insert(lines, "No task selected.")
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  vim.api.nvim_buf_clear_namespace(buf, hl.ns_id, 0, -1)
  for _, em in ipairs(extmarks) do
    vim.api.nvim_buf_set_extmark(buf, hl.ns_id, em.line, em.col_start, {
      end_col = em.col_end,
      hl_group = em.hl_group,
    })
  end
end

return M
