local layout = require("todoist-tui.ui.layout")
local plugin = require("todoist-tui")

describe("plugin", function()
  before_each(function()
    plugin.setup()
    -- Ensure closed before test
    if layout.is_open() then
      layout.close()
    end
  end)

  after_each(function()
    if layout.is_open() then
      layout.close()
    end
  end)

  it("can toggle open and close without errors", function()
    -- It should initially be closed
    assert.falsy(layout.is_open())

    -- Toggle to open
    plugin.toggle()

    -- In headless environment, windows are still valid
    assert.truthy(layout.is_open())

    -- Verify that the panels exist
    assert.is_not_nil(layout.wins.projects)
    assert.is_not_nil(layout.wins.tasks)

    -- Toggle to close
    plugin.toggle()

    assert.falsy(layout.is_open())
  end)
end)
