vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = ' '

require('which-key').setup()
require('mini_config').setup()
require('snacks_config').setup()
require('lsp').setup()

-- local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
