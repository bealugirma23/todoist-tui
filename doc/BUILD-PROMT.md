# Build Prompt

Use this after `01-PROJECT-INIT-PROMPT.md` has produced a working scaffold.
Paste `PLAN.md` into context alongside this (or point the agent at the file
if it can read the repo). Run phases one at a time — don't ask for all five
in one shot, review and commit between each.

---

You are implementing `todoist-tui.nvim`, a lazygit-style floating-window
Neovim TUI for Todoist, per the attached `PLAN.md`. The repo already has the
Phase 0 scaffold (`config.lua`, `health.lua`, `init.lua`, `ui/layout.lua`,
tests, CI). Implement **one phase at a time**, in order, and stop after each
phase for review rather than continuing to the next.

## Ground rules for every phase

- Follow the module boundaries in `PLAN.md` section 3 exactly — don't
  collapse `api/client.lua`, `api/sync.lua`, and `api/commands.lua` into one
  file, don't put HTTP calls inside `ui/*.lua`.
- Everything that touches the network must be async (`plenary.curl`'s
  callback form or `plenary.async`), never block the UI thread.
- All state mutation goes through `state.lua` setters, never direct table
  writes from `ui/*` or `actions.lua`. UI panels re-render by subscribing
  to state change events, not by polling.
- Never log, print, or commit the API token. `:checkhealth` masks it.
- Every new module gets a matching spec in `tests/`, following the
  patterns in `PLAN.md` section 8.
- Match the keymap table in `PLAN.md` section 6 exactly unless I say
  otherwise; keep it overridable via `config.setup({ keymaps = {...} })`.

## Phase 1 — Read-only core

Implement:

- `api/client.lua`: thin wrapper over `plenary.curl.post`/`get` against
  `https://api.todoist.com/api/v1/`, injects `Authorization: Bearer
<token>` from `config.get_token()`, JSON-decodes responses, surfaces
  HTTP/network errors via a consistent `{ ok, data|err }` return shape.
- `api/sync.lua`: `M.full_sync(callback)` posts to `/sync` with
  `sync_token=*` and `resource_types=["projects","items","sections","labels"]`,
  stores the returned `sync_token`, and calls back with normalized
  `{ projects, items, sections, labels }`.
- `state.lua`: the shape from `PLAN.md` section 4, plus a minimal pub/sub
  (`state.on_change(fn)`, `state.notify()`).
- `ui/projects_panel.lua` and `ui/tasks_panel.lua`: render real project
  names (indented by `parent_id` depth) and, for the selected project,
  its tasks (checkbox glyph + priority color + content). No editing yet.
- Wire `<Tab>`/`<S-Tab>` panel focus cycling and `j`/`k` selection movement
  in `ui/layout.lua`.
- `M.open()` in `init.lua` now triggers `sync.full_sync` on first open and
  shows a "syncing…" placeholder until data arrives.

Stop here. Show me it working against a real token before continuing.

## Phase 2 — Core actions

Implement `actions.lua` and `api/commands.lua`:

- `complete_task(id)` / `uncomplete_task(id)`, `cycle_priority(id)`,
  `delete_task(id)` (confirm via `vim.ui.select` or a `y/n` prompt in the
  footer, don't use `vim.fn.confirm` blocking dialog).
- Every action: mutate `state` immediately, push a command with a fresh
  `uuid` via `api/commands.lua`, reconcile or roll back on the response
  per `PLAN.md` section 5.
- `ui/detail_panel.lua` shows the selected task's due date, priority,
  project, and description; updates reactively via the state pub/sub.
- Bind `c`, `p`, `dd` per the keymap table.

Stop here for review.

## Phase 3 — Create & edit

- `ui/input.lua`: a floating input (raw buffer-based is fine; use
  nui.nvim's `Input` only if it meaningfully reduces code — note the
  tradeoff either way for me before deciding).
- `add_task(content, project_id)`: pass raw text straight through to
  Todoist's `item_add` — don't attempt client-side natural-language date
  parsing, the API does it server-side via `due.string`.
- `edit_task_content(id, new_content)`, `reschedule_task(id, due_string)`.
- Bind `a`, `e`, `r`.

Stop here for review.

## Phase 4 — Polish

- `cache.lua`: write a JSON snapshot of `state` to
  `vim.fn.stdpath('cache')/todoist-tui/snapshot.json` after every
  successful sync; on `M.open()`, load the snapshot synchronously for
  instant paint, then kick off an incremental sync (stored `sync_token`,
  not `*`) in the background and reconcile.
- Virtual "Today" / "Upcoming" / "Overdue" entries at the top of
  `ui/projects_panel.lua`, computed client-side from `state.tasks[*].due`.
- `/` search/filter within the focused panel.
- Footer sync-status indicator (`ui/footer.lua`): idle / syncing / error,
  plus the keybind cheatsheet, plus `g?` to toggle an expanded help view.
- Rate-limit handling in `api/client.lua`: on 429, read `Retry-After`,
  requeue instead of dropping.

Stop here for review.

## Phase 5 — Distribution

- Fill out `doc/todoist-tui.txt` with full command/keymap/config
  reference.
- README: install snippet, config options table, screenshots/GIF
  placeholders, contribution notes.
- Confirm `:checkhealth todoist-tui` covers every failure mode a new
  user could hit (missing token, missing plenary, network unreachable).
- Tag `v0.1.0`.

After each phase, run luacheck and the full test suite and paste the
output before I review.
