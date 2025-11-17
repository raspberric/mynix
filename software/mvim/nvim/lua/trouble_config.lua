return {
  setup = function()
    require("trouble").setup({})

    local keys = {
      {
        "<leader>lt",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>ls",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>ll",
        "<cmd>Trouble lsp toggle focus=false win.position=right win.size=100<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>lc",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>lq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    }

    for _, key in ipairs(keys) do
      vim.api.nvim_set_keymap("n", key[1], key[2], { desc = key.desc })
    end
  end,
}
