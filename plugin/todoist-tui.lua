if vim.g.loaded_todoist_tui then
  return
end
vim.g.loaded_todoist_tui = true

vim.api.nvim_create_user_command("Todoist", function()
  require("todoist-tui").toggle()
end, { desc = "Toggle Todoist TUI" })

vim.api.nvim_create_user_command("TodoistSync", function()
  require("todoist-tui").sync()
end, { desc = "Force Todoist Sync" })

vim.api.nvim_create_user_command("TodoistTokenAdd", function(opts)
  require("todoist-tui").add_token(opts.args)
end, { nargs = "?", desc = "Add and save a Todoist API Token" })
