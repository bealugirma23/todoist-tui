local M = {}

M.data = {
  sync_token = "*",
  projects = {},
  sections = {},
  tasks = {},
  labels = {},
  ui = {
    focused_panel = "projects", -- "projects", "tasks", "detail"
    selected_project_id = nil,  -- nil = "Today"
    selected_task_id = nil,
    filter = nil,
  },
  pending = {},
}

local listeners = {}

function M.subscribe(callback)
  table.insert(listeners, callback)
end

function M.notify()
  for _, cb in ipairs(listeners) do
    cb()
  end
end

function M.set_sync_token(token)
  M.data.sync_token = token
end

function M.update_from_sync(payload)
  if payload.projects then
    for _, p in ipairs(payload.projects) do
      if p.is_deleted then
        M.data.projects[p.id] = nil
      else
        M.data.projects[p.id] = p
      end
    end
  end

  if payload.sections then
    for _, s in ipairs(payload.sections) do
      if s.is_deleted then
        M.data.sections[s.id] = nil
      else
        M.data.sections[s.id] = s
      end
    end
  end

  if payload.items then
    for _, item in ipairs(payload.items) do
      if item.is_deleted then
        M.data.tasks[item.id] = nil
      else
        M.data.tasks[item.id] = item
      end
    end
  end

  if payload.labels then
    for _, label in ipairs(payload.labels) do
      if label.is_deleted then
        M.data.labels[label.id] = nil
      else
        M.data.labels[label.id] = label
      end
    end
  end

  if payload.sync_token then
    M.data.sync_token = payload.sync_token
  end

  M.notify()
end

function M.get_projects()
  local projects = {}
  for _, p in pairs(M.data.projects) do
    table.insert(projects, p)
  end
  table.sort(projects, function(a, b)
    return (a.child_order or 0) < (b.child_order or 0)
  end)
  return projects
end

function M.find_project_by_name(name)
  if not name then return nil end
  local lower_name = name:lower()
  for _, p in pairs(M.data.projects) do
    if p.name:lower() == lower_name then
      return p
    end
  end
  return nil
end

function M.find_label_by_name(name)
  if not name then return nil end
  local lower_name = name:lower()
  for _, l in pairs(M.data.labels) do
    if l.name:lower() == lower_name then
      return l
    end
  end
  return nil
end

function M.get_tasks(project_id)
  local tasks = {}
  for _, t in pairs(M.data.tasks) do
    if project_id == nil then
      -- Virtual "Today" logic: filter by due date today or overdue
      -- For now, return all tasks if project_id is nil for simplicity,
      -- we will refine this in virtual views later.
      if t.due and type(t.due) == "table" and t.due.date then
        -- rudimentary check for today/overdue
        local due_date = t.due.date:sub(1, 10)
        local today = os.date("%Y-%m-%d")
        if due_date <= today then
          table.insert(tasks, t)
        end
      end
    else
      if t.project_id == project_id then
        table.insert(tasks, t)
      end
    end
  end
  table.sort(tasks, function(a, b)
    return (a.child_order or 0) < (b.child_order or 0)
  end)
  return tasks
end

return M
