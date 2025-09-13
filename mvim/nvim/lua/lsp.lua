return {
  setup = function()
    local blink = require("blink.cmp")
    local lspconfig = require("lspconfig")
    -- vim.lsp.enable("astro")

    lspconfig.nixd.setup({
      capabilities = blink.get_lsp_capabilities(),
    })
    lspconfig.ts_ls.setup({
      capabilities = blink.get_lsp_capabilities(),
    })
    lspconfig.html.setup({
      cmd = { "vscode-html-language-server" },
    })
    lspconfig.jsonls.setup({
      cmd = { "vscode-json-language-server" },
    })
    lspconfig.astro.setup({})

    lspconfig.lua_ls.setup({
      capabilities = blink.get_lsp_capabilities(),
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
  end,
}
