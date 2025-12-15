return {
  setup = function()
    require("lazydev").setup()
    local lspCapabilities = require("blink.cmp").get_lsp_capabilities()
    vim.lsp.config("nixd", { capabilities = lspCapabilities })
    vim.lsp.config("ts_ls", { capabilities = lspCapabilities })
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
      cmd = {
        "ngserver",
        "--stdio",
        "--tsProbeLocations",
        "",
        "--ngProbeLocations",
        "",
      },
      before_init = function(params, config)
        local root = config.root_dir
        config.cmd = {
          "ngserver",
          "--stdio",
          "--tsProbeLocations",
          root .. "/node_modules",
          "--ngProbeLocations",
          root .. "/node_modules",
        }
      end,
      filetypes = { "typescript", "html", "typescriptreact" },
      root_dir = vim.fs.root(0, {
        "angular.json",
        "package.json",
      }),
      capabilities = lspCapabilities,
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
    })

    vim.lsp.enable("lua_ls")
    vim.lsp.enable("nixd")
    vim.lsp.enable("ts_ls")
    vim.lsp.enable("jsonls")
    vim.lsp.enable("html")
    vim.lsp.enable("cssls")
    vim.lsp.enable("astro")
    vim.lsp.enable("angularls")
    vim.lsp.enable("tailwindcss")

    require("nvim-ts-autotag").setup()
  end,
}
