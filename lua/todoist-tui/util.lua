local M = {}

function M.get_date_hl(due)
  if not due or type(due) ~= "table" or not due.date then return nil end
  local due_date = due.date:sub(1, 10)
  local today = os.date("%Y-%m-%d")
  if due_date < today then
    return "TodoistDueOverdue"
  elseif due_date == today then
    return "TodoistDueToday"
  else
    return "TodoistDueFuture"
  end
end

function M.get_priority_icon(priority)
  if priority == 4 then return "p1"
  elseif priority == 3 then return "p2"
  elseif priority == 2 then return "p3"
  else return "p4"
  end
end

function M.get_priority_hl(priority)
  if priority == 4 then return "TodoistPriorityP1"
  elseif priority == 3 then return "TodoistPriorityP2"
  elseif priority == 2 then return "TodoistPriorityP3"
  else return "TodoistPriorityP4"
  end
end

function M.format_date(due)
  if not due or type(due) ~= "table" then return "" end
  return due.string or due.date
end

return M
