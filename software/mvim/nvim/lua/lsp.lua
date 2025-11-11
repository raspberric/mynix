return {
  setup = function()
    local blink = require("blink.cmp")
    local lspCapabilities = blink.get_lsp_capabilities()

    vim.lsp.config("nixd", { capabilities = lspCapabilities })
    vim.lsp.enable("nixd")

    vim.lsp.config("ts_ls", { capabilities = lspCapabilities })
    vim.lsp.enable("ts_ls")

    vim.lsp.config("jsonls", { capabilities = lspCapabilities })
    vim.lsp.enable("jsonls")

    vim.lsp.config("html", { capabilities = lspCapabilities })
    vim.lsp.enable("html")

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
    vim.lsp.enable("astro")

    vim.lsp.config("tailwindcss", { capabilities = lspCapabilities })
    vim.lsp.enable("tailwindcss")

    local lazydev = require("lazydev")
    lazydev.setup()
    vim.lsp.config("lua_ls", {
      capabilities = lspCapabilities,
    })
    vim.lsp.enable("lua_ls")

    require("nvim-ts-autotag").setup()
  end,
}
