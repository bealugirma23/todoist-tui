local layout = require("todoist-tui.ui.layout")
local state = require("todoist-tui.state")
local util = require("todoist-tui.util")
local hl = require("todoist-tui.highlights")

local M = {}

M.lines_map = {}

function M.render()
  local buf = layout.bufs.tasks
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local lines = {}
  local extmarks = {}
  M.lines_map = {}

  local project_id = state.data.ui.selected_project_id
  local tasks = state.get_tasks(project_id)

  if #tasks == 0 then
    table.insert(lines, "No tasks here.")
  else
    for _, t in ipairs(tasks) do
      local checkbox = t.is_completed and "●" or "○"
      local priority_icon = util.get_priority_icon(t.priority)
      local date_str = util.format_date(t.due)

      -- Format: checkbox p1 content        date
      -- Calculate right alignment for date
      local win_width = vim.api.nvim_win_get_width(layout.wins.tasks)
      local base_str = string.format("%s %s %s", checkbox, priority_icon, t.content)

      local line_str = base_str
      if date_str ~= "" then
        local padding = math.max(1, win_width - vim.fn.strdisplaywidth(base_str) - vim.fn.strdisplaywidth(date_str) - 2)
        line_str = base_str .. string.rep(" ", padding) .. date_str
      end

      table.insert(lines, line_str)
      M.lines_map[#lines] = t

      local line_idx = #lines - 1

      -- Priority highlight
      local pri_start = vim.fn.strlen(checkbox) + 1
      local pri_end = pri_start + vim.fn.strlen(priority_icon)
      table.insert(extmarks, { line = line_idx, col_start = pri_start, col_end = pri_end, hl_group = util.get_priority_hl(t.priority) })

      -- Date highlight
      if date_str ~= "" then
        local date_hl = util.get_date_hl(t.due)
        if date_hl then
          local date_start = vim.fn.strlen(line_str) - vim.fn.strlen(date_str)
          table.insert(extmarks, { line = line_idx, col_start = date_start, col_end = vim.fn.strlen(line_str), hl_group = date_hl })
        end
      end

      -- Completed highlight (strikethrough on content)
      if t.is_completed then
        table.insert(extmarks, { line = line_idx, col_start = 0, col_end = vim.fn.strlen(line_str), hl_group = "TodoistCompleted" })
      end
    end
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

  local win = layout.wins.tasks
  if win and vim.api.nvim_win_is_valid(win) then
    local cursor = vim.api.nvim_win_get_cursor(win)
    if cursor[1] > #lines then
      vim.api.nvim_win_set_cursor(win, { math.max(1, #lines), 0 })
    end
    M.on_cursor_moved()
  end
end

function M.on_cursor_moved()
  local win = layout.wins.tasks
  if not win or not vim.api.nvim_win_is_valid(win) then return end

  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]

  local task = M.lines_map[line]
  if task then
    state.data.ui.selected_task_id = task.id
  else
    state.data.ui.selected_task_id = nil
  end
  require("todoist-tui.ui.detail_panel").render()
end

function M.get_selected_task()
  local win = layout.wins.tasks
  if not win or not vim.api.nvim_win_is_valid(win) then return nil end
  local cursor = vim.api.nvim_win_get_cursor(win)
  return M.lines_map[cursor[1]]
end

return M
