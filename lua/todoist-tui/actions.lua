-- luacheck: ignore 212/res
local rest = require("todoist-tui.api.rest")
local state = require("todoist-tui.state")

local M = {}

local function generate_temp_id()
  return "temp_" .. tostring(math.random(100000, 999999))
end

function M.toggle_complete(task_id)
  local task = state.data.tasks[task_id]
  if not task then return end
  -- Cannot complete a temp task
  if tostring(task_id):match("^temp_") then
    vim.notify("Wait for task to be created before completing.", vim.log.levels.WARN)
    return
  end

  local was_completed = task.is_completed
  task.is_completed = not was_completed
  state.notify()

  local callback = function(res, err)
    if err then
      vim.notify("Failed to toggle task: " .. tostring(err), vim.log.levels.ERROR)
      if state.data.tasks[task_id] then
        state.data.tasks[task_id].is_completed = was_completed
        state.notify()
      end
    end
  end

  if task.is_completed then
    rest.close_task(task_id, callback)
  else
    rest.reopen_task(task_id, callback)
  end
end

function M.add_task(content, project_id, due_string, labels, priority)
  local temp_id = generate_temp_id()

  local p = priority or 1

  local new_task = {
    id = temp_id,
    content = content,
    project_id = project_id,
    is_completed = false,
    priority = p,
    child_order = 0,
    due = due_string and { string = due_string, date = due_string } or nil,
    labels = labels or {},
  }

  state.data.tasks[temp_id] = new_task
  state.notify()

  rest.create_task(content, project_id, due_string, p, labels, function(res, err)
    if err then
      vim.notify("Failed to add task: " .. tostring(err), vim.log.levels.ERROR)
      state.data.tasks[temp_id] = nil
      state.notify()
    elseif res and res.id then
      state.data.tasks[temp_id] = nil
      -- Map properties correctly since REST format might differ slightly
      res.project_id = res.project_id
      state.data.tasks[res.id] = res
      state.notify()
    end
  end)
end

function M.edit_task(task_id, new_content)
  local task = state.data.tasks[task_id]
  if not task then return end
  if tostring(task_id):match("^temp_") then
    vim.notify("Wait for task to be created before editing.", vim.log.levels.WARN)
    return
  end

  local old_content = task.content
  task.content = new_content
  state.notify()

  rest.update_task(task_id, { content = new_content }, function(res, err)
    if err then
      vim.notify("Failed to edit task: " .. tostring(err), vim.log.levels.ERROR)
      if state.data.tasks[task_id] then
        state.data.tasks[task_id].content = old_content
        state.notify()
      end
    end
  end)
end

function M.delete_task(task_id)
  local task = state.data.tasks[task_id]
  if not task then return end
  if tostring(task_id):match("^temp_") then
    vim.notify("Wait for task to be created before deleting.", vim.log.levels.WARN)
    return
  end

  vim.ui.select({ "Yes", "No" }, { prompt = "Delete task '" .. task.content .. "'?" }, function(choice)
    if choice == "Yes" then
      state.data.tasks[task_id] = nil
      state.notify()

      rest.delete_task(task_id, function(res, err)
        if err then
          vim.notify("Failed to delete task: " .. tostring(err), vim.log.levels.ERROR)
          state.data.tasks[task_id] = task
          state.notify()
        end
      end)
    end
  end)
end

function M.cycle_priority(task_id)
  local task = state.data.tasks[task_id]
  if not task then return end
  if tostring(task_id):match("^temp_") then
    return
  end

  local old_priority = task.priority
  -- Todoist priorities are 1-4. 4 is highest priority in UI (p1), 1 is lowest (p4).
  local new_priority = old_priority + 1
  if new_priority > 4 then new_priority = 1 end

  task.priority = new_priority
  state.notify()

  rest.update_task(task_id, { priority = new_priority }, function(res, err)
    if err then
      vim.notify("Failed to update priority: " .. tostring(err), vim.log.levels.ERROR)
      if state.data.tasks[task_id] then
        state.data.tasks[task_id].priority = old_priority
        state.notify()
      end
    end
  end)
end

function M.move_task(task_id)
  local task = state.data.tasks[task_id]
  if not task then return end
  if tostring(task_id):match("^temp_") then
    vim.notify("Wait for task to be created before moving.", vim.log.levels.WARN)
    return
  end

  local projects = state.get_projects()
  local items = {}
  for _, p in ipairs(projects) do
    table.insert(items, p)
  end

  vim.ui.select(items, {
    prompt = "Move task to project:",
    format_item = function(item)
      return item.name
    end
  }, function(choice)
    if choice then
      local old_project_id = task.project_id
      task.project_id = choice.id
      state.notify()

      rest.update_task(task_id, { project_id = choice.id }, function(res, err)
        if err then
          vim.notify("Failed to move task: " .. tostring(err), vim.log.levels.ERROR)
          if state.data.tasks[task_id] then
            state.data.tasks[task_id].project_id = old_project_id
            state.notify()
          end
        end
      end)
    end
  end)
end

function M.yank_task(task_id)
  local task = state.data.tasks[task_id]
  if task then
    vim.fn.setreg('"', task.content)
    vim.notify("Yanked: " .. task.content)
  end
end

function M.reschedule(task_id, due_string)
  local task = state.data.tasks[task_id]
  if not task then return end
  if tostring(task_id):match("^temp_") then
    return
  end

  local old_due = task.due
  task.due = due_string and { string = due_string, date = due_string } or nil
  state.notify()

  rest.update_task(task_id, { due_string = due_string }, function(res, err)
    if err then
      vim.notify("Failed to reschedule task: " .. tostring(err), vim.log.levels.ERROR)
      if state.data.tasks[task_id] then
        state.data.tasks[task_id].due = old_due
        state.notify()
      end
    elseif res and res.due then
      if state.data.tasks[task_id] then
        state.data.tasks[task_id].due = res.due
        state.notify()
      end
    end
  end)
end

function M.add_project(name)
  local temp_id = generate_temp_id()
  local new_project = {
    id = temp_id,
    name = name,
    child_order = 9999,
  }
  state.data.projects[temp_id] = new_project
  state.notify()

  rest.create_project(name, function(res, err)
    if err then
      vim.notify("Failed to add project: " .. tostring(err), vim.log.levels.ERROR)
      state.data.projects[temp_id] = nil
      state.notify()
    elseif res and res.id then
      state.data.projects[temp_id] = nil
      state.data.projects[res.id] = res
      state.notify()
    end
  end)
end

function M.rename_project(project_id, new_name)
  local project = state.data.projects[project_id]
  if not project then return end
  if tostring(project_id):match("^temp_") then return end

  local old_name = project.name
  project.name = new_name
  state.notify()

  rest.update_project(project_id, { name = new_name }, function(res, err)
    if err then
      vim.notify("Failed to rename project: " .. tostring(err), vim.log.levels.ERROR)
      if state.data.projects[project_id] then
        state.data.projects[project_id].name = old_name
        state.notify()
      end
    end
  end)
end

function M.delete_project(project_id)
  local project = state.data.projects[project_id]
  if not project then return end
  if tostring(project_id):match("^temp_") then return end

  vim.ui.select({ "Yes", "No" }, { prompt = "Delete project '" .. project.name .. "'?" }, function(choice)
    if choice == "Yes" then
      state.data.projects[project_id] = nil
      state.notify()

      rest.delete_project(project_id, function(res, err)
        if err then
          vim.notify("Failed to delete project: " .. tostring(err), vim.log.levels.ERROR)
          state.data.projects[project_id] = project
          state.notify()
        end
      end)
    end
  end)
end

function M.add_section(project_id, name)
  local temp_id = generate_temp_id()
  local new_section = {
    id = temp_id,
    name = name,
    project_id = project_id,
  }
  state.data.sections[temp_id] = new_section
  state.notify()

  rest.create_section(name, project_id, function(res, err)
    if err then
      vim.notify("Failed to add section: " .. tostring(err), vim.log.levels.ERROR)
      state.data.sections[temp_id] = nil
      state.notify()
    elseif res and res.id then
      state.data.sections[temp_id] = nil
      state.data.sections[res.id] = res
      state.notify()
    end
  end)
end

local parser = require("todoist-tui.parser")

local function run_after_all(tasks, on_complete)
  local count = #tasks
  if count == 0 then
    on_complete()
    return
  end

  local completed = 0
  local has_error = false

  for _, task in ipairs(tasks) do
    task(function(err)
      if has_error then return end
      if err then
        has_error = true
        on_complete(err)
        return
      end
      completed = completed + 1
      if completed == count then
        on_complete()
      end
    end)
  end
end

function M.add_task_from_text(text, focused_project_id)
  local parsed = parser.parse(text)

  if not parsed.content or parsed.content == "" then
    return
  end

  local target_project_id = focused_project_id
  local target_label_ids = {}
  local target_priority = 1
  if parsed.priority then
    if parsed.priority == 1 then target_priority = 4
    elseif parsed.priority == 2 then target_priority = 3
    elseif parsed.priority == 3 then target_priority = 2
    elseif parsed.priority == 4 then target_priority = 1
    end
  end
  local pending_creates = {}

  if parsed.project then
    local p = state.find_project_by_name(parsed.project)
    if p then
      target_project_id = p.id
    else
      table.insert(pending_creates, function(done)
        rest.create_project(parsed.project, function(res, err)
          if err then
            done("Failed to create project '" .. parsed.project .. "': " .. tostring(err))
          elseif res and res.id then
            state.data.projects[res.id] = res
            target_project_id = res.id
            done()
          else
            done("Unknown error creating project")
          end
        end)
      end)
    end
  end

  for _, tag in ipairs(parsed.tags) do
    local l = state.find_label_by_name(tag)
    if l then
      table.insert(target_label_ids, l.id)
    else
      table.insert(pending_creates, function(done)
        rest.create_label(tag, function(res, err)
          if err then
            done("Failed to create label '" .. tag .. "': " .. tostring(err))
          elseif res and res.id then
            state.data.labels[res.id] = res
            table.insert(target_label_ids, res.id)
            done()
          else
            done("Unknown error creating label")
          end
        end)
      end)
    end
  end

  run_after_all(pending_creates, function(err)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end
    M.add_task(parsed.content, target_project_id, nil, target_label_ids, target_priority)
  end)
end

return M
