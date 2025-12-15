return {
  setup = function()
    require("lazydev").setup()
    local lspCapabilities = require("blink.cmp").get_lsp_capabilities()
    vim.lsp.config("nixd", { capabilities = lspCapabilities })
    vim.lsp.config("ts_ls", { capabilities = lspCapabilities })
    vim.lsp.config("jsonls", { capabilities = lspCapabilities })
    vim.lsp.config("html", { capabilities = lspCapabilities })
    vim.lsp.config("tailwindcss", { capabilities = lspCapabilities })
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
    vim.lsp.enable("astro")
    vim.lsp.enable("tailwindcss")

    require("nvim-ts-autotag").setup()
  end,
}
