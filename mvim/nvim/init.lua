vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

local mini = require('mini_config')
mini.setup()

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
