local config = {}

local defaults = {
  token = nil,
  token_env = "TODOIST_API_TOKEN",
  icons = {
    project = "",
    inbox = "",
    today = "",
    upcoming = "",
    task_open = "",
    task_completed = "",
    priority = {
      p1 = "🔴",
      p2 = "🟠",
      p3 = "🔵",
      p4 = "⚪",
    }
  },
  keymaps = {
    toggle_panel = "<Tab>",
    add_task = "a",
    toggle_complete = "c",
    edit_task = "cc",
    delete_task = "dd",
    cycle_priority = "p",
    reschedule = "r",
    move_task = "m",
    yank_task = "yy",
    add_project = "a",
    rename_project = "e",
    delete_project = "dd",
    add_section = "S",
    open_detail = "<CR>",
    sync = "R",
    quit = "q",
    help = "g?",
    search = "/",
    move_up = "k",
    move_down = "j",
    move_top = "gg",
    move_bottom = "G",
    back = "<Esc>",
  },
  highlights = {},
}

config.defaults = defaults
config.options = vim.deepcopy(defaults)

function config.setup(opts)
  config.options = vim.tbl_deep_extend("force", config.options, opts or {})
end

local token_file = vim.fn.stdpath("data") .. "/todoist-tui-token"

local saved_token_cache = nil

function config.get_saved_token()
  if saved_token_cache then return saved_token_cache end

  local file = io.open(token_file, "r")
  if file then
    local content = file:read("*a")
    file:close()
    if content then
      content = content:gsub("^%s*(.-)%s*$", "%1")
      if content ~= "" then
        saved_token_cache = content
        return content
      end
    end
  end
  return nil
end

function config.save_token(token)
  local file = io.open(token_file, "w")
  if file then
    file:write(token)
    file:close()
    saved_token_cache = token
    return true
  end
  return false
end

function config.get_token()
  return config.options.token or vim.env[config.options.token_env] or config.get_saved_token()
end

return config
