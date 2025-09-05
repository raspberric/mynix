vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

require("which-key").setup({})
require("mini_config").setup()
require("snacks_config").setup()
require("lsp").setup()

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
})
vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, { desc = 'Code Action' })

-- local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
