local M = {}

-- simple fallback if nui is not present, though plan suggested nui.Input.
-- using vim.ui.input is native and often wrapped by Dressing.nvim which looks good
function M.open(prompt, on_submit, default_text)
  vim.ui.input({ prompt = prompt, default = default_text }, function(input)
    if on_submit then
      on_submit(input)
    end
  end)
end

return M
