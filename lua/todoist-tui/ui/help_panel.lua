local config = require("todoist-tui.config")

local M = {}

M.win = nil
M.buf = nil

function M.toggle()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
    M.buf = nil
    return
  end

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  M.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.buf })

  M.win = vim.api.nvim_open_win(M.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    border = "rounded",
    title = " Help ",
    style = "minimal"
  })

  vim.api.nvim_set_option_value("winhl", "Normal:TodoistNormal,FloatBorder:TodoistBorder,FloatTitle:TodoistTitle", { win = M.win })

  local km = config.options.keymaps

  local help_text = {
    "Global",
    "  " .. km.move_down .. "/" .. km.move_up .. "         Move selection",
    "  " .. km.move_top .. "/" .. km.move_bottom .. "        Move to top/bottom",
    "  " .. km.toggle_panel .. "     Cycle focused panel",
    "  " .. km.search .. "         Search/Filter (Not implemented)",
    "  " .. km.help .. "        Toggle this help",
    "  " .. km.quit .. "         Quit",
    "",
    "Projects Panel",
    "  " .. km.open_detail .. "      Open selected project's tasks",
    "  " .. km.add_project .. "         Add project",
    "  " .. km.rename_project .. "         Rename project",
    "  " .. km.delete_project .. "        Delete project",
    "  " .. km.add_section .. "         Add section",
    "",
    "Tasks Panel",
    "  " .. km.open_detail .. "      Open task details",
    "  " .. km.add_task .. "         Add task (@tag #project p1)",
    "  " .. km.edit_task .. "        Edit task content",
    "  " .. km.toggle_complete .. "         Toggle complete",
    "  " .. km.delete_task .. "        Delete task",
    "  " .. km.cycle_priority .. "         Cycle priority (p1 -> p4)",
    "  " .. km.reschedule .. "         Reschedule (natural language)",
    "  " .. km.move_task .. "         Move to project",
    "  " .. km.yank_task .. "        Yank task text",
    "",
    "Detail Panel",
    "  " .. km.edit_task .. "        Edit task content",
    "  " .. km.reschedule .. "         Reschedule (natural language)",
    "  " .. km.cycle_priority .. "         Cycle priority (p1 -> p4)",
    "  " .. km.back .. "     Back to Tasks",
  }

  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, help_text)
  vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf })

  vim.keymap.set("n", "q", M.toggle, { buffer = M.buf, silent = true, noremap = true })
  vim.keymap.set("n", "<Esc>", M.toggle, { buffer = M.buf, silent = true, noremap = true })
  vim.keymap.set("n", km.help, M.toggle, { buffer = M.buf, silent = true, noremap = true })
end

return M
