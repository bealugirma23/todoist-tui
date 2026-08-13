local layout = require("todoist-tui.ui.layout")
local config = require("todoist-tui.config")
local actions = require("todoist-tui.actions")
local input = require("todoist-tui.ui.input")
local state = require("todoist-tui.state")

local M = {}

local function map(buf, mode, lhs, rhs)
  if not lhs or lhs == "" then return end
  -- For keys with '/', we only want to map them if they are an exact key like "j/k", wait, "j/k" is not a key.
  -- The UI prompt says "j/k move", so "j/k" is for display. But the mapping itself needs to map both keys individually!
  -- Actually, the existing code mapped `km.move_down` and `km.move_up` in the config as individual keys. We just display "j/k".
  -- For our mappings list, we should define what the keys actually are for mapping.
  vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, noremap = true })
end

M.get_mappings = function()
  local km = config.options.keymaps
  return {
    global = {
      { key = km.move_down .. "/" .. km.move_up, desc = "move" },
      { key = km.move_top .. "/" .. km.move_bottom, desc = "top/bottom" },
      { key = km.toggle_panel, desc = "panel", fn = function() layout.cycle_panel() end },
      { key = km.search, desc = "search" },
      { key = km.help, desc = "help", fn = function() require("todoist-tui.ui.help_panel").toggle() end },
      { key = km.quit, desc = "quit", fn = function() layout.close() end },
      { key = "<Esc>", fn = function() layout.close() end },
      { key = km.sync, fn = function() require("todoist-tui.api.sync").sync(true) end },
    },
    projects = {
      { key = km.open_detail, desc = "open", fn = function() layout.focus_panel("tasks") end },
      { key = km.add_project, desc = "add", fn = function()
          input.open("Add Project: ", function(text)
            if text and text ~= "" then actions.add_project(text) end
          end)
      end },
      { key = km.rename_project, desc = "rename", fn = function()
          local p_id = state.data.ui.selected_project_id
          if not p_id then return end
          local p = state.data.projects[p_id]
          if p then
            input.open("Rename Project: ", function(text)
              if text and text ~= "" then actions.rename_project(p.id, text) end
            end, p.name)
          end
      end },
      { key = km.delete_project, desc = "delete", fn = function()
          local p_id = state.data.ui.selected_project_id
          if p_id then actions.delete_project(p_id) end
      end },
      { key = km.add_section, desc = "add section", fn = function()
          local p_id = state.data.ui.selected_project_id
          if not p_id then return end
          input.open("Add Section: ", function(text)
            if text and text ~= "" then actions.add_section(p_id, text) end
          end)
      end },
    },
    tasks = {
      { key = km.open_detail, desc = "detail", fn = function() layout.focus_panel("detail") end },
      { key = km.add_task, desc = "add", fn = function()
          input.open("Add Task: ", function(text)
            if text and text ~= "" then actions.add_task_from_text(text, state.data.ui.selected_project_id) end
          end)
      end },
      { key = km.edit_task, desc = "edit", fn = function()
          local t = require("todoist-tui.ui.tasks_panel").get_selected_task()
          if t then
            input.open("Edit Task: ", function(text)
              if text and text ~= "" then actions.edit_task(t.id, text) end
            end, t.content)
          end
      end },
      { key = km.toggle_complete, desc = "toggle", fn = function()
          local t = require("todoist-tui.ui.tasks_panel").get_selected_task()
          if t then actions.toggle_complete(t.id) end
      end },
      { key = km.delete_task, desc = "delete", fn = function()
          local t = require("todoist-tui.ui.tasks_panel").get_selected_task()
          if t then actions.delete_task(t.id) end
      end },
      { key = km.cycle_priority, desc = "priority", fn = function()
          local t = require("todoist-tui.ui.tasks_panel").get_selected_task()
          if t then actions.cycle_priority(t.id) end
      end },
      { key = km.reschedule, desc = "reschedule", fn = function()
          local t = require("todoist-tui.ui.tasks_panel").get_selected_task()
          if t then
            input.open("Reschedule (e.g. 'today', 'tomorrow', 'next week'): ", function(text)
              if text and text ~= "" then actions.reschedule(t.id, text) end
            end)
          end
      end },
      { key = km.move_task, desc = "move", fn = function()
          local t = require("todoist-tui.ui.tasks_panel").get_selected_task()
          if t then actions.move_task(t.id) end
      end },
      { key = km.yank_task, desc = "yank", fn = function()
          local t = require("todoist-tui.ui.tasks_panel").get_selected_task()
          if t then actions.yank_task(t.id) end
      end },
    },
    detail = {
      { key = km.edit_task, desc = "edit", fn = function()
          local t_id = state.data.ui.selected_task_id
          if t_id then
            local t = state.data.tasks[t_id]
            if t then
              input.open("Edit Task: ", function(text)
                if text and text ~= "" then actions.edit_task(t.id, text) end
              end, t.content)
            end
          end
      end },
      { key = km.reschedule, desc = "reschedule", fn = function()
          local t_id = state.data.ui.selected_task_id
          if t_id then
            input.open("Reschedule: ", function(text)
              if text and text ~= "" then actions.reschedule(t_id, text) end
            end)
          end
      end },
      { key = km.cycle_priority, desc = "priority", fn = function()
          local t_id = state.data.ui.selected_task_id
          if t_id then actions.cycle_priority(t_id) end
      end },
      { key = km.back, desc = "back", fn = function() layout.focus_panel("tasks") end },
    },
  }
end

function M.setup_all()
  local mappings = M.get_mappings()

  for panel, buf in pairs(layout.bufs) do
    if buf and vim.api.nvim_buf_is_valid(buf) then
      -- Global keymaps (explicit mappings for ones that don't have multiple keys in a single string)
      for _, m in ipairs(mappings.global) do
        -- Skip the display-only combined keys like "j/k", we'll map them manually below, or they are just for display.
        -- But wait, if they have `fn`, we should map them. For combined keys, we don't map them using the display string.
        if m.fn and not string.find(m.key, "/") and m.key ~= "<Esc>" then
          map(buf, "n", m.key, m.fn)
        end
      end

      local km = config.options.keymaps
      -- explicitly map the ones that were combined for display
      map(buf, "n", km.quit, function() layout.close() end)
      map(buf, "n", "<Esc>", function() layout.close() end)

      -- Panel specific movement & actions
      if panel == "projects" then
        vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = buf,
          callback = function() require("todoist-tui.ui.projects_panel").on_cursor_moved() end,
        })
        for _, m in ipairs(mappings.projects) do
          if m.fn then map(buf, "n", m.key, m.fn) end
        end
      elseif panel == "tasks" then
        vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = buf,
          callback = function() require("todoist-tui.ui.tasks_panel").on_cursor_moved() end,
        })
        for _, m in ipairs(mappings.tasks) do
          if m.fn then map(buf, "n", m.key, m.fn) end
        end
      elseif panel == "detail" then
        for _, m in ipairs(mappings.detail) do
          if m.fn then map(buf, "n", m.key, m.fn) end
        end
      end
    end
  end
end

return M
