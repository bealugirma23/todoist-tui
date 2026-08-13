local layout = require("todoist-tui.ui.layout")
local state = require("todoist-tui.state")
local hl = require("todoist-tui.highlights")
local keymaps = require("todoist-tui.keymaps")
local M = {}

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_idx = 1
local spinner_timer = nil

function M._sync_status_text()
  if state.data.ui.sync_status == "syncing" then
    return spinner_frames[spinner_idx] .. " syncing…"
  elseif state.data.ui.sync_status == "error" then
    return "sync failed"
  else
    return ""
  end
end

function M._sync_status_hl()
  if state.data.ui.sync_status == "syncing" then
    return "TodoistSyncActive"
  elseif state.data.ui.sync_status == "error" then
    return "TodoistSyncError"
  else
    return "TodoistSyncIdle"
  end
end

function M.render()
  local buf = layout.bufs.footer
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  if state.data.ui.sync_status == "syncing" then
    if not spinner_timer then
      spinner_timer = vim.uv.new_timer()
      spinner_timer:unref()
    end
    if not spinner_timer:is_active() then
      spinner_timer:start(0, 250, vim.schedule_wrap(function()
        spinner_idx = (spinner_idx % #spinner_frames) + 1
        M.render()
      end))
    end
  else
    if spinner_timer and spinner_timer:is_active() then
      spinner_timer:stop()
    end
  end

  local focused = state.data.ui.focused_panel or "tasks"
  local mappings = keymaps.get_mappings()

  local tips = {}
  -- Add panel specific tips
  for _, m in ipairs(mappings[focused] or {}) do
    if m.key and m.desc then
      table.insert(tips, m.key)
      table.insert(tips, m.desc)
    end
  end
  -- Add global tips
  for _, m in ipairs(mappings.global or {}) do
    if m.key and m.desc then
      table.insert(tips, m.key)
      table.insert(tips, m.desc)
    end
  end

  local parts, extmarks, col = {}, {}, 0
  for i = 1, #tips, 2 do
    local key, desc = tips[i], tips[i + 1]
    if key and desc then
      table.insert(parts, key)
      table.insert(extmarks, { col_start = col, col_end = col + #key, hl_group = "TodoistFooterKey" })
      col = col + #key + 1
      table.insert(parts, desc)
      table.insert(extmarks, { col_start = col, col_end = col + #desc, hl_group = "TodoistFooterDesc" })
      col = col + #desc + 1
    end
  end

  local sync_text = M._sync_status_text()
  local width = vim.api.nvim_win_get_width(layout.wins.footer)

  local function fits(p)
    local len = 0
    for _, str in ipairs(p) do len = len + #str end
    return len + #p - 1 + #sync_text + 1 <= width
  end

  while #parts > 0 and not fits(parts) do
    table.remove(parts)
    table.remove(parts)
    table.remove(extmarks)
    table.remove(extmarks)
  end

  local line = table.concat(parts, " ")
  local padding = math.max(1, width - #line - #sync_text - 1)
  line = line .. string.rep(" ", padding) .. sync_text

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_buf_clear_namespace(buf, hl.ns_id, 0, -1)
  for _, em in ipairs(extmarks) do
    vim.api.nvim_buf_set_extmark(buf, hl.ns_id, 0, em.col_start, { end_col = em.col_end, hl_group = em.hl_group })
  end

  if sync_text ~= "" then
    local sync_start = #line - #sync_text
    vim.api.nvim_buf_set_extmark(buf, hl.ns_id, 0, sync_start, { end_col = #line, hl_group = M._sync_status_hl() })
  end
end

return M
