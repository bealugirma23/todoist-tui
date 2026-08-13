local config = require("todoist-tui.config")
local curl = require("plenary.curl")

local M = {}

M.base_url = "https://api.todoist.com/api/v1/"

local function request(method, path, data, callback)
  local token = config.get_token()
  if not token then
    if callback then callback(nil, "No token") end
    return
  end

  local opts = {
    headers = {
      Authorization = "Bearer " .. token,
      ["Content-Type"] = "application/json",
    },
    timeout = 10000,
    callback = function(res)
      vim.schedule(function()
        if res.status >= 200 and res.status < 300 then
          local ok, decoded = pcall(vim.fn.json_decode, res.body)
          if ok or res.body == "" then
            callback(decoded, nil)
          else
            callback(nil, "JSON decode error")
          end
        elseif res.status == 429 then
          callback(nil, "Rate limited")
        else
          callback(nil, "HTTP Error " .. tostring(res.status) .. ": " .. tostring(res.body))
        end
      end)
    end
  }

  if data then
    opts.body = vim.fn.json_encode(data)
  end

  if method == "POST" then
    curl.post(M.base_url .. path, opts)
  elseif method == "DELETE" then
    curl.delete(M.base_url .. path, opts)
  elseif method == "GET" then
    curl.get(M.base_url .. path, opts)
  end
end

function M.create_task(content, project_id, due_string, priority, labels, callback)
  local data = {
    content = content,
    project_id = project_id,
    priority = priority,
  }
  if due_string and due_string ~= "" then
    data.due_string = due_string
  end
  if labels and #labels > 0 then
    data.labels = labels
  end
  request("POST", "tasks", data, callback)
end

function M.update_task(id, data, callback)
  request("POST", "tasks/" .. id, data, callback)
end

function M.close_task(id, callback)
  request("POST", "tasks/" .. id .. "/close", nil, callback)
end

function M.reopen_task(id, callback)
  request("POST", "tasks/" .. id .. "/reopen", nil, callback)
end

function M.delete_task(id, callback)
  request("DELETE", "tasks/" .. id, nil, callback)
end

function M.create_project(name, callback)
  request("POST", "projects", { name = name }, callback)
end

function M.update_project(id, data, callback)
  request("POST", "projects/" .. id, data, callback)
end

function M.delete_project(id, callback)
  request("DELETE", "projects/" .. id, nil, callback)
end

function M.create_section(name, project_id, callback)
  request("POST", "sections", { name = name, project_id = project_id }, callback)
end

function M.create_label(name, callback)
  request("POST", "labels", { name = name }, callback)
end

return M
