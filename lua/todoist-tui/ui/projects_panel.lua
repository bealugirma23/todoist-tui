local layout = require("todoist-tui.ui.layout")
local state = require("todoist-tui.state")
local config = require("todoist-tui.config")
local hl = require("todoist-tui.highlights")

local M = {}

M.lines_map = {} -- line_num -> item

function M.render()
  local buf = layout.bufs.projects
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local lines = {}
  local extmarks = {}
  M.lines_map = {}

  -- Virtual views
  local today_idx = #lines + 1
  local today_text = config.options.icons.today .. " Today"
  table.insert(lines, today_text)
  M.lines_map[today_idx] = { id = nil, type = "virtual", name = "Today" }
  table.insert(extmarks, { line = today_idx - 1, col_start = 0, col_end = #today_text, hl_group = "TodoistProjectFavorite" })

  table.insert(lines, "")
  table.insert(lines, "Projects:")

  local projects = state.get_projects()
  for _, p in ipairs(projects) do
    local indent = ""
    local text = indent .. config.options.icons.project .. " " .. p.name
    table.insert(lines, text)
    M.lines_map[#lines] = { id = p.id, type = "project", data = p }

    local hl_group = p.is_favorite and "TodoistProjectFavorite" or "TodoistProjectName"
    table.insert(extmarks, { line = #lines - 1, col_start = 0, col_end = #text, hl_group = hl_group })
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

  -- Adjust cursor if out of bounds
  local win = layout.wins.projects
  if win and vim.api.nvim_win_is_valid(win) then
    local cursor = vim.api.nvim_win_get_cursor(win)
    if cursor[1] > #lines then
      vim.api.nvim_win_set_cursor(win, { math.max(1, #lines), 0 })
    end
  end
end

function M.on_cursor_moved()
  local win = layout.wins.projects
  if not win or not vim.api.nvim_win_is_valid(win) then return end

  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]

  local item = M.lines_map[line]
  if item then
    state.data.ui.selected_project_id = item.id
    require("todoist-tui.ui.tasks_panel").render()
  end
end

return M
