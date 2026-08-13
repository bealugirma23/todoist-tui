local config = require("todoist-tui.config")
local curl = require("plenary.curl")

local M = {}

M.base_url = "https://api.todoist.com/api/v1/"

local function urlencode(str)
  if str then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

function M.post(path, data, callback)
  local token = config.get_token()
  if not token then
    vim.notify("Todoist API token not found. Please set it in config or $TODOIST_API_TOKEN", vim.log.levels.ERROR)
    if callback then callback(nil, "No token") end
    return
  end

  local body_str
  local content_type

  if path == "sync" then
    content_type = "application/x-www-form-urlencoded"
    local parts = {}
    for k, v in pairs(data) do
      if type(v) == "table" then
        v = vim.fn.json_encode(v)
      end
      table.insert(parts, urlencode(k) .. "=" .. urlencode(tostring(v)))
    end
    body_str = table.concat(parts, "&")
  else
    content_type = "application/json"
    body_str = vim.fn.json_encode(data)
  end

  curl.post(M.base_url .. path, {
    headers = {
      Authorization = "Bearer " .. token,
      ["Content-Type"] = content_type,
    },
    body = body_str,
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
  })
end

return M
