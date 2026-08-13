local state = require("todoist-tui.state")

describe("state", function()
  before_each(function()
    state.data = {
      sync_token = "*",
      projects = {},
      sections = {},
      tasks = {},
      labels = {},
      ui = {
        focused_panel = "projects",
        selected_project_id = nil,
        selected_task_id = nil,
        filter = nil,
      },
      pending = {},
    }
  end)

  it("updates from sync payload correctly", function()
    local payload = {
      sync_token = "new_token",
      projects = {
        { id = "p1", name = "Project 1", is_deleted = false }
      },
      items = {
        { id = "t1", content = "Task 1", is_deleted = false }
      }
    }

    state.update_from_sync(payload)

    assert.are.equal("new_token", state.data.sync_token)
    assert.truthy(state.data.projects["p1"])
    assert.truthy(state.data.tasks["t1"])
  end)

  it("removes deleted items", function()
    state.data.tasks["t1"] = { id = "t1", content = "Task 1" }

    local payload = {
      items = {
        { id = "t1", is_deleted = true }
      }
    }

    state.update_from_sync(payload)

    assert.falsy(state.data.tasks["t1"])
  end)
end)
