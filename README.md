![screenshot](https://cdn.phototourl.com/free/2026-08-13-b909a79a-c42f-4811-9965-5fb885f861b1.png)

# todoist-tui.nvim

A sleek, floating terminal user interface (TUI) for managing your [Todoist](https://todoist.com) tasks directly from Neovim.

![CI](https://github.com/yourusername/todoist-tui.nvim/actions/workflows/ci.yml/badge.svg)

## ✨ Features

- **Floating Panels:** Clean, visually distinct panels for Projects, Tasks, and Task Details.
- **Async Syncing:** Built on `plenary.curl`, syncs in the background without blocking your editor.
- **Contextual Keymaps:** Vim-native bindings (`j`/`k`, `dd`, `a`) that adapt to whichever panel you are focused on, with a dynamic tips bar at the bottom.
- **Full CRUD:** Add, edit, complete, delete, prioritize, and reschedule tasks directly via the Todoist REST API.

## 📦 Prerequisites

- **Neovim** >= `0.10.0`
- **[plenary.nvim](https://github.com/nvim-lua/plenary.nvim)**
- A **Todoist API Token** (Grab yours from [Todoist Developer Settings](https://todoist.com/app/settings/integrations/developer))

## 🚀 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua

{
  "bealugirma23/todoist-tui", -- Correct user and repo name
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "Todoist", "TodoistSync", "TodoistTokenAdd" },
  opts = {},
}

```

## 🔑 Authentication

You must provide your Todoist API token for the plugin to work. There are three ways to do this:

1. **Interactive Command (Recommended):**
   Open Neovim and run `:TodoistTokenAdd`. Paste your token when prompted. It will securely save to your Neovim `data` directory and persist across sessions.
2. **Environment Variable:**
   Export it in your shell profile (`.bashrc`, `.zshrc`, etc.):

   ```bash
   export TODOIST_API_TOKEN="your_token_here"
   ```

3. **Lua Configuration:**
   Pass it directly to the `setup()` function (not recommended for dotfiles tracked in git):

   ```lua
   require("todoist-tui").setup({
     token = "your_token_here"
   })
   ```

## ⌨️ Usage & Commands

- `:Todoist` — Toggles the UI.
- `:TodoistSync` — Forces a background sync with the Todoist API.
- `:TodoistTokenAdd <token>` — Adds and securely stores your API token.
- `:checkhealth todoist-tui` — Verifies your configuration and ensures the token is loaded.

### Quick Add Syntax
When pressing `a` to add a new task, you can use Todoist's natural quick-add syntax to assign tags, projects, and priorities on the fly:
- `@tag` will assign the task to the given label (and create it if it doesn't exist).
- `#project` will assign the task to the given project (and create it if it doesn't exist).
- `p1`, `p2`, `p3`, `p4` will set the task's priority level (p1 is highest/urgent, p4 is normal).

*Example:* `fix the splash not opening @fix #work p1`

### Default Keymaps

You can navigate between the different panels using `<Tab>`. The tips bar at the bottom of the window will dynamically update to show you the available bindings for your currently focused panel.

| Action                    | Key            | Context          |
| ------------------------- | -------------- | ---------------- |
| **Cycle Panel Focus**     | `<Tab>`        | Global           |
| **Move Up / Down**        | `k` / `j`      | Global           |
| **Move Top / Bottom**     | `gg` / `G`     | Global           |
| **Sync**                  | `R`            | Global           |
| **Toggle Help**           | `g?`           | Global           |
| **Quit**                  | `q` or `<Esc>` | Global           |
| **Open Tasks / Detail**   | `<CR>`         | Projects / Tasks |
| **Back to Tasks**         | `<Esc>`        | Detail           |
| **Add Task / Project**    | `a`            | Tasks / Projects |
| **Complete Task**         | `c`            | Tasks            |
| **Edit Task / Project**   | `cc` / `e`     | Tasks / Projects |
| **Delete Task / Project** | `dd`           | Tasks / Projects |
| **Change Priority**       | `p`            | Tasks / Detail   |
| **Reschedule**            | `r`            | Tasks / Detail   |
| **Add Section**           | `S`            | Projects         |

## ⚙️ Configuration

`todoist-tui.nvim` comes with sensible defaults. You can override any of these by passing a table into `setup()`.

Here is the default configuration:

```lua
require("todoist-tui").setup({
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
  highlights = {}, -- Override default highlight groups here
})
```

## 🛠️ Contributing

Contributions are welcome!

To run the test suite locally:

1. The suite uses a standalone test harness that will automatically download a pinned version of `plenary.nvim`.
2. Run the tests via headless Neovim:

   ```bash
   nvim --headless -u tests/minimal_init.lua
   ```
