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
    })
    vim.keymap.set({ "n" }, "<leader>cf", function()
      conform.format()
      vim.notify("Formatted!", "info")
    end, { desc = "Format file" })
  end,
}
