local config = require("todoist-tui.config")

describe("config", function()
  before_each(function()
    -- Reset config state
    config.options = vim.deepcopy(config.defaults)
    vim.env.TODOIST_API_TOKEN = nil

    -- Clear saved token
    local token_file = vim.fn.stdpath("data") .. "/todoist-tui-token"
    os.remove(token_file)
  end)

  describe("setup", function()
    it("merges user options over defaults", function()
      config.setup({
        token_env = "MY_CUSTOM_TOKEN_ENV",
      })

      assert.are.same("MY_CUSTOM_TOKEN_ENV", config.options.token_env)
      assert.are.same(config.defaults.icons.project, config.options.icons.project)
    end)

    it("deep extends with force semantics for nested tables", function()
      config.setup({
        icons = {
          project = "X",
        }
      })

      -- vim.tbl_deep_extend("force") replaces the nested table entirely if it's provided?
      -- Wait, tbl_deep_extend actually merges nested tables, but replaces non-tables.
      -- Let's test the merge behavior correctly.
      assert.are.same("X", config.options.icons.project)
      assert.are.same(config.defaults.icons.inbox, config.options.icons.inbox)
    end)
  end)

  describe("get_token", function()
    it("returns nil when neither token nor env is set", function()
      local token = config.get_token()
      assert.is_nil(token)
    end)

    it("resolves from environment variable when option is not set", function()
      vim.env.TODOIST_API_TOKEN = "env-token"
      local token = config.get_token()
      assert.are.same("env-token", token)
    end)

    it("prioritizes explicit option over environment variable", function()
      vim.env.TODOIST_API_TOKEN = "env-token"
      config.setup({ token = "explicit-token" })
      local token = config.get_token()
      assert.are.same("explicit-token", token)
    end)

    it("respects custom token_env setting", function()
      config.setup({ token_env = "CUSTOM_API_ENV" })
      vim.env.CUSTOM_API_ENV = "custom-env-token"
      local token = config.get_token()
      assert.are.same("custom-env-token", token)

      -- Cleanup
      vim.env.CUSTOM_API_ENV = nil
    end)
  end)
end)
