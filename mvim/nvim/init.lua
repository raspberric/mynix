vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "
vim.g.netrw_liststyle = 3

require("blink").setup()
require("mini_config").setup()
require("snacks_config").setup()
require("formatter").setup()
require("lsp").setup()
require("treesitter").setup()

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
})
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
