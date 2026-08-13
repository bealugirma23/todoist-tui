local state = require("todoist-tui.state")

local M = {}

M.wins = {
	projects = nil,
	tasks = nil,
	detail = nil,
	footer = nil,
}

M.bufs = {
	projects = nil,
	tasks = nil,
	detail = nil,
	footer = nil,
}

local function create_win(buf, opts)
	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_set_option_value(
		"winhl",
		"Normal:TodoistNormal,FloatBorder:TodoistBorder,FloatTitle:TodoistTitle",
		{ win = win }
	)
	vim.api.nvim_set_option_value("wrap", false, { win = win })
	vim.api.nvim_set_option_value("cursorline", true, { win = win })
	vim.api.nvim_set_option_value("cursorlineopt", "both", { win = win })
	-- wait, cursorline hl is global/window, but we can set winhl CursorLine:TodoistCursorLine
	local current_winhl = vim.api.nvim_get_option_value("winhl", { win = win })
	vim.api.nvim_set_option_value("winhl", current_winhl .. ",CursorLine:TodoistCursorLine", { win = win })
	return win
end

local function setup_buffer(name)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("filetype", "todoist_" .. name, { buf = buf })
	return buf
end

function M.open()
	if M.is_open() then
		return
	end

	local width = math.floor(vim.o.columns * 0.8)
	local total_height = math.floor(vim.o.lines * 0.8)
	local max_height = math.max(10, vim.o.lines - 5)
	total_height = math.min(total_height, max_height)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - total_height) / 2)

	local p_width = math.floor(width * 0.3)
	local t_width = width - p_width

	-- total_height must cover: top block border(2) + detail block border(2) + footer(1, no border)
	local content_height = total_height - 5
	local top_height = math.floor(content_height * 0.7)
	local bottom_height = content_height - top_height

	-- Projects
	M.bufs.projects = setup_buffer("projects")
	M.wins.projects = create_win(M.bufs.projects, {
		relative = "editor",
		width = p_width,
		height = top_height,
		col = col,
		row = row,
		border = "rounded",
		title = " Projects ",
		style = "minimal",
	})

	-- Tasks
	M.bufs.tasks = setup_buffer("tasks")
	M.wins.tasks = create_win(M.bufs.tasks, {
		relative = "editor",
		width = t_width,
		height = top_height,
		col = col + p_width + 2,
		row = row,
		border = "rounded",
		title = " Tasks ",
		style = "minimal",
	})

	-- Detail — starts immediately below the top block's bottom border row
	local detail_row = row + top_height + 2
	M.bufs.detail = setup_buffer("detail")
	M.wins.detail = create_win(M.bufs.detail, {
		relative = "editor",
		width = width + 2,
		height = bottom_height,
		col = col,
		row = detail_row,
		border = "rounded",
		title = " Detail ",
		style = "minimal",
	})

	-- Footer — starts immediately below the detail block's bottom border row
	local footer_row = detail_row + bottom_height + 2
	M.bufs.footer = setup_buffer("footer")
	M.wins.footer = create_win(M.bufs.footer, {
		relative = "editor",
		width = width + 2,
		height = 1,
		col = col,
		row = footer_row,
		border = "none",
		style = "minimal",
	})
	vim.api.nvim_set_option_value("cursorline", false, { win = M.wins.footer })

	M.focus_panel(state.data.ui.focused_panel)

	require("todoist-tui.keymaps").setup_all()

	require("todoist-tui.ui.projects_panel").render()
	require("todoist-tui.ui.tasks_panel").render()
	require("todoist-tui.ui.detail_panel").render()
	require("todoist-tui.ui.footer").render()

	state.subscribe(M.render_all)
end

function M.render_all()
	if not M.is_open() then
		return
	end
	require("todoist-tui.ui.projects_panel").render()
	require("todoist-tui.ui.tasks_panel").render()
	require("todoist-tui.ui.detail_panel").render()
	require("todoist-tui.ui.footer").render()
end

function M.close()
	if not M.is_open() then
		return
	end
	for _, win in pairs(M.wins) do
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	M.wins = {}
	M.bufs = {}
end

function M.is_open()
	return M.wins.projects and vim.api.nvim_win_is_valid(M.wins.projects)
end

function M.focus_panel(panel_name)
	if not M.is_open() then
		return
	end

	-- Reset all windows to normal border
	for name, win in pairs(M.wins) do
		if name ~= "footer" and win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_option_value(
				"winhl",
				"Normal:TodoistNormal,FloatBorder:TodoistBorder,FloatTitle:TodoistTitle,CursorLine:TodoistCursorLine",
				{ win = win }
			)
		end
	end

	local win = M.wins[panel_name]
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
		state.data.ui.focused_panel = panel_name
		-- Apply focused border to active window
		vim.api.nvim_set_option_value(
			"winhl",
			"Normal:TodoistNormal,FloatBorder:TodoistPanelFocused,FloatTitle:TodoistPanelFocused,CursorLine:TodoistCursorLine",
			{ win = win }
		)

		-- Re-render footer to update context-sensitive hints
		require("todoist-tui.ui.footer").render()
	end
end

function M.cycle_panel()
	if not M.is_open() then
		return
	end
	local order = { "projects", "tasks", "detail" }
	local current = state.data.ui.focused_panel
	local next_idx = 1
	for i, p in ipairs(order) do
		if p == current then
			next_idx = (i % #order) + 1
			break
		end
	end
	M.focus_panel(order[next_idx])
end

return M
