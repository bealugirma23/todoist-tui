# Project Init Prompt

Use this first, in an empty directory, to scaffold the repo before any
feature work starts. Paste into Claude Code (or similar).

---

You are scaffolding a new Neovim plugin called `todoist-tui.nvim`. This is
Phase 0 only — no Todoist API calls, no real UI logic yet. The goal is a
clean, conventional Neovim plugin skeleton that boots cleanly and passes CI.

Create the following:

1. **Directory structure**
   ```
   lua/todoist-tui/init.lua
   lua/todoist-tui/config.lua
   lua/todoist-tui/health.lua
   lua/todoist-tui/ui/layout.lua
   plugin/todoist-tui.lua
   doc/todoist-tui.txt
   tests/minimal_init.lua
   tests/config_spec.lua
   .luacheckrc
   .github/workflows/ci.yml
   README.md
   LICENSE (MIT)
   ```

2. **`lua/todoist-tui/config.lua`**
   - `M.defaults` table with: `token = nil`, `token_env = "TODOIST_API_TOKEN"`,
     `keymaps = {}` (empty for now, filled in later phases),
     `layout = { width = 0.85, height = 0.85 }`.
   - `M.setup(opts)` that deep-merges user opts over defaults using
     `vim.tbl_deep_extend("force", ...)` and stores the result in `M.options`.
   - `M.get_token()` that resolves token from `M.options.token`, then
     `os.getenv(M.options.token_env)`, returning `nil, err_message` if
     neither is set. Never error() here — callers decide how to handle a
     missing token.

3. **`lua/todoist-tui/health.lua`**
   - Implements `M.check()` using `vim.health` (or the legacy `health#`
     shim if targeting <0.10) reporting:
     - Neovim version OK/warn
     - `plenary.nvim` found (ok) / not found (error, with install hint)
     - token resolvable (ok) / missing (warn, with setup hint, do not
       print the token value itself)

4. **`lua/todoist-tui/init.lua`**
   - `M.setup(opts)` delegates to `config.setup(opts)`.
   - `M.open()` — for now, just opens a blank centered floating window via
     `ui/layout.lua` with a placeholder buffer showing "todoist-tui: phase 0
     scaffold — no data wired up yet". Sets a buffer-local keymap `q` /
     `<Esc>` to close it.
   - `M.close()` closes it if open, no-op otherwise.
   - `M.toggle()`.

5. **`lua/todoist-tui/ui/layout.lua`**
   - `M.open_centered(opts)` — generic helper: creates a scratch buffer
     (`buftype=nofile`, `bufhidden=wipe`, `swapfile=false`) and a floating
     window sized as a fraction of `&columns`/`&lines` per `opts.width`/
     `opts.height` (default from config), rounded border. Returns
     `{ buf, win }`. This will be reused by real panels later, so keep it
     generic (accept content lines, don't hardcode "phase 0" text inside
     this module).

6. **`plugin/todoist-tui.lua`**
   - Guards against double-load.
   - Defines user command `:Todoist` → `require("todoist-tui").toggle()`.
   - Does NOT call `setup()` automatically — that's the user's job in their
     config, per Neovim plugin convention.

7. **`doc/todoist-tui.txt`**
   - Minimal valid Neovim help file: `*todoist-tui.txt*` header, a CONTENTS
     section, an INTRO section describing the plugin in 2-3 sentences, a
     COMMANDS section documenting `:Todoist`, and a `vim:tw=78:ts=8:ft=help`
     modeline at the end.

8. **`.luacheckrc`**
   - Standard Neovim plugin luacheck config: `globals = {"vim"}`, ignore
     line-length rule, `std = "luajit"`.

9. **`.github/workflows/ci.yml`**
   - Job 1: `luacheck lua/` on push/PR.
   - Job 2: run `tests/` via `plenary.nvim`'s test harness against a
     minimal init (`tests/minimal_init.lua` should bootstrap plenary from
     a pinned commit and run `PlenaryBustedDirectory tests/`).

10. **`tests/config_spec.lua`**
    - Test `config.setup()` merges user opts over defaults correctly.
    - Test `config.get_token()` resolution order (explicit opt wins over
      env var; returns nil+message when neither set — mock
      `os.getenv`/reset `M.options.token` between cases).

11. **`README.md`**
    - Title, one-line description, install snippet for `lazy.nvim`:
      ```lua
      {
        "yourname/todoist-tui.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Todoist",
        opts = {},
      }
      ```
    - "Status: early scaffold, not yet functional" note (remove in later
      phases).

Constraints:
- No Todoist API code yet — that's Phase 1, out of scope here.
- No nui.nvim dependency yet — only `plenary.nvim`, since Phase 0 only
  needs its test harness, not HTTP.
- Everything must load without error on a clean `nvim --clean -u
  tests/minimal_init.lua` and `:Todoist` must open and close the
  placeholder window without traceback.

When done, show me the full file tree and run luacheck + the test suite
so I can see it passes before we move to Phase 1 (real Todoist sync).
