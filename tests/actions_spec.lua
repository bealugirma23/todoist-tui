local state = require("todoist-tui.state")

-- Mock rest before requiring actions
local mock_rest = {
  create_task_args = nil,
  create_project_args = nil,
  create_label_args = {},
}

mock_rest.create_task = function(content, project_id, _, priority, labels, cb)
  mock_rest.create_task_args = {
    content = content,
    project_id = project_id,
    labels = labels,
    priority = priority,
  }
  cb({ id = "task_1", content = content, project_id = project_id, labels = labels, priority = priority })
end

mock_rest.create_project = function(name, cb)
  mock_rest.create_project_args = { name = name }
  cb({ id = "proj_" .. name, name = name })
end

mock_rest.create_label = function(name, cb)
  table.insert(mock_rest.create_label_args, { name = name })
  cb({ id = "lbl_" .. name, name = name })
end

package.loaded["todoist-tui.api.rest"] = mock_rest
local actions = require("todoist-tui.actions")

describe("actions.add_task_from_text", function()
  before_each(function()
    mock_rest.create_task_args = nil
    mock_rest.create_project_args = nil
    mock_rest.create_label_args = {}

    state.data.projects = {
      ["existing_proj"] = { id = "existing_proj", name = "existing" }
    }
    state.data.labels = {
      ["existing_lbl"] = { id = "existing_lbl", name = "existing" }
    }
    state.data.tasks = {}
  end)

  it("uses existing project and label", function()
    actions.add_task_from_text("do work @existing #existing", "default_proj")

    assert.is_nil(mock_rest.create_project_args)
    assert.are.same({}, mock_rest.create_label_args)
    assert.are.same({
      content = "do work",
      project_id = "existing_proj",
      labels = { "existing_lbl" },
      priority = 1
    }, mock_rest.create_task_args)
  end)

  it("creates missing project and label", function()
    actions.add_task_from_text("do work @newlbl #newproj", "default_proj")

    assert.are.same({ name = "newproj" }, mock_rest.create_project_args)
    assert.are.same({{ name = "newlbl" }}, mock_rest.create_label_args)
    assert.are.same({
      content = "do work",
      project_id = "proj_newproj",
      labels = { "lbl_newlbl" },
      priority = 1
    }, mock_rest.create_task_args)
  end)

  it("falls back to focused project if no project specified", function()
    actions.add_task_from_text("do work", "focused_proj")

    assert.is_nil(mock_rest.create_project_args)
    assert.are.same({
      content = "do work",
      project_id = "focused_proj",
      labels = {},
      priority = 1
    }, mock_rest.create_task_args)
  end)

  it("maps p1 to priority 4", function()
    actions.add_task_from_text("urgent p1", "focused_proj")
    assert.are.same({
      content = "urgent",
      project_id = "focused_proj",
      labels = {},
      priority = 4
    }, mock_rest.create_task_args)
  end)

  it("maps p3 to priority 2", function()
    actions.add_task_from_text("low p3", "focused_proj")
    assert.are.same({
      content = "low",
      project_id = "focused_proj",
      labels = {},
      priority = 2
    }, mock_rest.create_task_args)
  end)
end)
