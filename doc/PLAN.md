# todoist-tui.nvim — Implementation Plan

## 1. Goal

A lazygit-style floating-window TUI, native to Neovim (pure Lua, no external
binary), for managing Todoist tasks without leaving the editor. Multi-panel
layout, keyboard-driven, optimistic updates, async everywhere.

## 2. Tech stack

| Concern            | Choice                                            |
|---------------------|----------------------------------------------------|
| Language            | Lua (Neovim 0.9+, uses `vim.system` fallback to `plenary.job`) |
| HTTP / async         | plenary.nvim (`plenary.curl`, `plenary.async`)     |
| Popups / layout      | nui.nvim (`Popup`, `Layout`, `Input`) — optional but recommended |
| Todoist API           | Unified API v1 — `https://api.todoist.com/api/v1/` |
| Auth                 | Personal API token (Bearer), from Todoist → Settings → Integrations → Developer |
| Persistence          | JSON cache file in `vim.fn.stdpath('cache')/todoist-tui/` |
| Testing              | plenary.nvim `busted`-style specs (`tests/`) |
| Distribution          | lazy.nvim / packer spec, semver tags, `doc/todoist-tui.txt` help file |

## 3. Module architecture

```
lua/todoist-tui/
  init.lua              -- setup(opts), user commands (:Todoist, :TodoistSync)
  config.lua             -- defaults, merges user opts, resolves token
  health.lua              -- :checkhealth todoist-tui (token present, plenary found, curl reachable)
  api/
    client.lua           -- low-level HTTP wrapper around plenary.curl, retry/backoff on 429
    sync.lua             -- full + incremental sync, sync_token persistence
    commands.lua          -- builds batched command payloads (item_add, item_complete, item_update, ...)
  state.lua               -- central in-memory store + pub/sub for UI re-render
  cache.lua               -- read/write JSON snapshot to disk for instant reopen
  ui/
    layout.lua            -- window/buffer scaffolding, panel registry, focus cycling
    projects_panel.lua     -- sidebar: projects, favorites, Today/Upcoming filters
    tasks_panel.lua         -- main panel: task list for current selection
    detail_panel.lua        -- bottom panel: description, due date, labels, subtasks
    footer.lua               -- keybind cheatsheet, sync status indicator
    input.lua                 -- add/edit task popup (nui.Input or raw floating buffer)
  actions.lua                -- complete/add/edit/delete/reschedule/reprioritize,
                                  optimistic state mutation + rollback on error
  keymaps.lua                 -- default keymap table, remappable via config
  util.lua                     -- date formatting, priority/color mapping, debounce
tests/
  api_spec.lua
  state_spec.lua
  actions_spec.lua
doc/
  todoist-tui.txt
README.md
LICENSE
```

## 4. Data model (in-memory state)

```lua
state = {
  sync_token = "*",
  auth = { token = nil },       -- resolved from config/env, never logged
  projects = { [id] = { id, name, color, parent_id, is_favorite, child_order } },
  sections = { [id] = { id, name, project_id } },
  tasks    = { [id] = { id, content, project_id, section_id, priority,
                          due, labels, is_completed, parent_id } },
  ui = {
    focused_panel = "projects" | "tasks" | "detail",
    selected_project_id = nil,     -- nil = "Today" virtual view
    selected_task_id = nil,
    filter = nil,                  -- e.g. "today", "overdue", freeform query
  },
  pending = {},   -- uuid -> {command, optimistic_undo} awaiting server ack
}
```

State mutations always go through `state.lua` setters that notify subscribed
UI panels (simple event bus, no reactive framework needed at this scale).

## 5. API integration plan

- **Auth resolution order:** `config.token` → `$TODOIST_API_TOKEN` env var →
  prompt once via `vim.ui.input` and offer to save to a gitignored token file.
  Never commit or print the token; mask it in `:checkhealth`.
- **Initial load:** `POST /api/v1/sync` with `sync_token=*`,
  `resource_types=["projects","items","sections","labels"]`. Populate state,
  persist `sync_token` + snapshot to `cache.lua`.
- **Reopen:** load cache snapshot instantly (perceived zero-latency open),
  then fire an incremental sync in the background using the stored
  `sync_token` and reconcile.
- **Writes:** every user action builds a `sync` command
  (`item_add`, `item_complete`, `item_uncomplete`, `item_update`,
  `item_delete`, `item_move`) with a fresh `uuid`. Apply the mutation to
  local state immediately (optimistic), send the command, and:
  - on `"ok"` — clear from `pending`, done.
  - on error object — revert the optimistic mutation, surface via
    `vim.notify(..., vim.log.levels.ERROR)`.
- **Batching:** actions performed in quick succession (e.g. multi-select
  complete) are coalesced into a single `/sync` call via a short debounce
  queue in `api/commands.lua`, matching Todoist's documented batching
  pattern.
- **Rate limits:** on `429`, read `Retry-After` / `error_extra.retry_after`
  and back off; queue writes rather than dropping them.

## 6. UI/UX plan

**Layout:** three stacked/side-by-side floating windows built from
`vim.api.nvim_open_win`, no external UI framework required for the panels
themselves (only for the add/edit input popup, where nui.nvim earns its
keep).

```
┌ Projects ┐┌ Tasks ─────────────┐
│          ││                    │
└──────────┘└────────────────────┘
┌ Detail ─────────────────────────┐
└──────────────────────────────────┘
 keybind footer
```

**Default keymaps** (all remappable in `setup()`):

| Key | Action |
|-----|--------|
| `<Tab>` / `<S-Tab>` | cycle panel focus |
| `j` / `k` | move selection |
| `<CR>` | open/focus detail for selected task |
| `a` | add task (quick-add input, supports Todoist natural-language due dates) |
| `c` | toggle complete |
| `e` | edit content |
| `dd` | delete task (confirm) |
| `p` | cycle priority p1–p4 |
| `r` | reschedule (input popup) |
| `/` | filter/search current panel |
| `R` | manual full resync |
| `q` / `<Esc>` | close TUI |
| `g?` | toggle keybind help |

**Virtual views:** "Today", "Upcoming", "Overdue" appear in the projects
panel above real projects, computed client-side from `due` dates in state
— no separate API calls needed beyond the initial sync.

## 7. Build phases

**Phase 0 — Scaffold**
Repo skeleton, `config.lua` with defaults, `health.lua`, plugin spec for
lazy.nvim, CI workflow (luacheck + plenary tests), empty `:Todoist` command
that opens/closes a blank floating window.

**Phase 1 — Read-only core**
`api/client.lua` + `api/sync.lua` full sync, `state.lua`, projects + tasks
panels rendering real data, panel focus cycling, `q` to close. No writes yet.

**Phase 2 — Core actions**
`actions.lua`: complete/uncomplete, priority cycle, delete — all optimistic
with rollback. Detail panel wired to selection.

**Phase 3 — Create & edit**
Add-task and edit-task input popups, natural-language due date parsing
(Todoist parses `due.string` server-side, so just pass the raw string
through), reschedule action.

**Phase 4 — Polish**
Disk cache for instant reopen, incremental sync reconciliation, search/
filter (`/`), Today/Upcoming/Overdue virtual views, sync status indicator
in footer, error toasts, `:checkhealth` coverage.

**Phase 5 — Distribution**
`doc/todoist-tui.txt` (`:help todoist-tui`), README with GIFs, semver
tag, submit to lazy.nvim-compatible plugin listings if desired.

## 8. Testing strategy

- `api/*` — unit tests against a stubbed `plenary.curl` (record/replay
  fixture JSON for `/sync` responses).
- `state.lua` — pure Lua table mutation tests, no Neovim API needed.
- `actions.lua` — test optimistic-apply + rollback-on-error paths
  explicitly, since that's the highest-risk logic for state corruption.
- Manual: a `scripts/dev_reload.lua` for fast iterate-and-reload during
  UI work.

## 9. Open decisions to make before/while building

1. nui.nvim as a real dependency, or hand-roll the one input popup you
   need and stay zero-dependency beyond plenary?
2. Multi-select (visual mode bulk-complete) in v1 scope, or defer to
   Phase 4+?
3. Offline queue durability — if Neovim closes with `pending` commands
   unsent, do you persist and retry on next open, or drop with a warning?
