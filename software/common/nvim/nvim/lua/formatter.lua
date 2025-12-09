return {
  setup = function()
    local conform = require("conform")
    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        nix = { "alejandra" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        astro = { "prettier" },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    })
    vim.keymap.set({ "n" }, "<leader>cf", function()
      conform.format()
      vim.notify("Formatted!", 2)
    end, { desc = "Format file" })
  end,
}
