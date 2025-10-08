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

    vim.lsp.config("lua_ls", {
      capabilities = lspCapabilities,
      settings = {
        Lua = {
          workspace = {
            -- Tell the language server to scan for plugin files
            library = vim.api.nvim_get_runtime_file("", true),
          },
          diagnostics = {
            -- Make the server aware of the 'vim' global and other globals
            globals = { "vim", "opts" },
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    require("nvim-ts-autotag").setup()
  end,
}
