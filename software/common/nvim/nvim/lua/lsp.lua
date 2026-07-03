local function find_tsdk(start)
  local uv = vim.uv or vim.loop
  local dir = start
  while dir and dir ~= "" do
    local tsdk = dir .. "/node_modules/typescript/lib"
    if uv.fs_stat(tsdk) then
      return tsdk
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      return nil
    end
    dir = parent
  end
end

return {
  setup = function()
    require("lazydev").setup()
    local lspCapabilities = require("blink.cmp").get_lsp_capabilities()
    vim.lsp.config("nixd", { capabilities = lspCapabilities })
    vim.lsp.config("ts_ls", {
      capabilities = lspCapabilities,
      -- fixes pnpm workspace monrepo ts issues where ts_ls can't find tsc in packages/ui
      before_init = function(params, config)
        local root = (params.rootUri and vim.uri_to_fname(params.rootUri)) or params.rootPath or vim.fn.getcwd()
        local tsdk = find_tsdk(root)
        if tsdk then
          params.initializationOptions = params.initializationOptions or {}
          params.initializationOptions.tsserver = params.initializationOptions.tsserver or {}
          params.initializationOptions.tsserver.path = tsdk
        end
      end,
    })
    vim.lsp.config("jsonls", { capabilities = lspCapabilities })
    vim.lsp.config("html", {
      filetypes = { "html" },
      root_dir = function(bufnr)
        -- do not attach inside Angular projects
        local root = vim.fs.root(bufnr, { "angular.json" })
        return root == nil and vim.fs.root(bufnr, { "package.json" })
      end,
      capabilities = lspCapabilities,
    })
    vim.lsp.config("cssls", { capabilities = lspCapabilities })
    vim.lsp.config("tailwindcss", { capabilities = lspCapabilities })
    vim.lsp.config("angularls", {
      capabilities = lspCapabilities,
      root_dir = function(bufnr)
        return vim.fs.root(bufnr, { "angular.json", "project.json" })
      end,
    })
    vim.lsp.config("astro", {
      init_options = {
        typescript = {
          autoImports = true,
          suggest = {
            autoImports = true,
          },
        },
      },
    })
    vim.lsp.config("lua_ls", {
      capabilities = lspCapabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "nixCats" },
          },
        },
      },
    })
    vim.lsp.config("gopls", {
      capabilities = lspCapabilities,
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
          usePlaceholders = true,
          completeUnimported = true,
          directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
        },
      },
    })
    local util = require("lspconfig.util")
    vim.lsp.config("pyright", {
      capabilities = lspCapabilities,
      root_dir = function(bufnr, on_dir)
        local uv = vim.uv or vim.loop
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local dir = vim.fs.dirname(fname)
        -- Walk up looking for a dir with pyproject.toml (or pyrightconfig.json)
        -- AND a .venv/venv next to it. This lets us pick the correct sub-project
        -- in a uv/poetry workspace where each package has its own venv.
        local best_with_venv, best_project = nil, nil
        while dir and dir ~= "" do
          local has_project = uv.fs_stat(dir .. "/pyrightconfig.json")
            or uv.fs_stat(dir .. "/pyproject.toml")
            or uv.fs_stat(dir .. "/setup.py")
            or uv.fs_stat(dir .. "/setup.cfg")
            or uv.fs_stat(dir .. "/requirements.txt")
          if has_project then
            best_project = best_project or dir
            if uv.fs_stat(dir .. "/.venv/bin/python") or uv.fs_stat(dir .. "/venv/bin/python") then
              best_with_venv = dir
              break
            end
          end
          local parent = vim.fs.dirname(dir)
          if parent == dir then
            break
          end
          dir = parent
        end
        on_dir(best_with_venv or best_project or util.find_git_ancestor(fname))
      end,
      before_init = function(_, config)
        local uv = vim.uv or vim.loop
        local root = config.root_dir
        if root then
          for _, venv in ipairs({ ".venv", "venv" }) do
            local python = root .. "/" .. venv .. "/bin/python"
            if uv.fs_stat(python) then
              config.settings = config.settings or {}
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = python
              config.settings.python.venvPath = root
              config.settings.python.venv = venv
              break
            end
          end
        end
      end,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
          },
        },
      },
    })

    vim.lsp.config("ruff", {
      capabilities = lspCapabilities,
    })

    vim.lsp.enable("lua_ls")
    if nixCats("runtimeChecks.IS_NIX") then
      vim.lsp.enable("nixd")
    end
    if nixCats("runtimeChecks.IS_FRONTEND") then
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("jsonls")
      vim.lsp.enable("html")
      vim.lsp.enable("cssls")
      vim.lsp.enable("astro")
      vim.lsp.enable("angularls")
      vim.lsp.enable("tailwindcss")
    end
    if nixCats("runtimeChecks.IS_GO") then
      vim.lsp.enable("gopls")
    end
    if nixCats("runtimeChecks.IS_PYTHON") then
      vim.lsp.enable("pyright")
      vim.lsp.enable("ruff")
    end
  end,
}
