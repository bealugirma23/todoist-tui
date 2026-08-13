local layout = require("todoist-tui.ui.layout")
local plugin = require("todoist-tui")

describe("layout", function()
  before_each(function()
    plugin.setup()
    if layout.is_open() then
      layout.close()
    end
  end)

  after_each(function()
    if layout.is_open() then
      layout.close()
    end
  end)

  it("ensures footer window stays within the screen on short terminals", function()
    -- Set terminal size to 80x20
    vim.o.columns = 80
    vim.o.lines = 20

    plugin.toggle()
    assert.truthy(layout.is_open())

    -- Verify footer is on-screen (row should be < vim.o.lines)
    local footer_win = layout.wins.footer
    assert.truthy(footer_win)
    local pos = vim.api.nvim_win_get_position(footer_win)
    assert.truthy(pos[1] < vim.o.lines, "Footer row " .. pos[1] .. " should be < " .. vim.o.lines)
  end)

  it("re-renders footer with correct hints when switching panels", function()
    -- Reset to a decent size
    vim.o.columns = 200
    vim.o.lines = 50

    plugin.toggle()

    local footer_buf = layout.bufs.footer
    local function get_footer_text()
      return vim.api.nvim_buf_get_lines(footer_buf, 0, -1, false)[1]
    end

    -- Initial focus is 'projects', check for add project hint 'a add'
    local text_projects = get_footer_text()
    assert.truthy(text_projects:find("add")) -- a add project

    -- Switch focus to 'detail' panel, which shouldn't have 'add' but should have 'back'
    layout.focus_panel("detail")
    local text_detail = get_footer_text()
    assert.truthy(text_detail, "text_detail should not be nil")
    assert.truthy(text_detail:find("back"), "Expected 'back' in footer, got: " .. text_detail)
    assert.falsy(text_detail:find("add section"))
  end)

  it("footer does not crash with a partial keymaps override", function()
    -- Setup with a partial keymaps table (missing some keys)
    plugin.setup({
      keymaps = {
        move_down = "j",
        move_up = nil, -- Missing!
      }
    })

    -- It shouldn't error when toggling
    plugin.toggle()
    assert.truthy(layout.is_open())

    local footer_buf = layout.bufs.footer
    local lines = vim.api.nvim_buf_get_lines(footer_buf, 0, -1, false)
    assert.truthy(lines[1])
  end)
end)
