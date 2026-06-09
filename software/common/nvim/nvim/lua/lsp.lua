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
          config.init_options = config.init_options or {}
          config.init_options.tsserver = config.init_options.tsserver or {}
          config.init_options.tsserver.path = tsdk
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
  end,
}
