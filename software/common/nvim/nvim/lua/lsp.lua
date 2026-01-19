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
    vim.lsp.config("angularls", { capabilities = lspCapabilities })
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
  end,
}
