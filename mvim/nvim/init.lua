vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

require('mini_config').setup()
require('which-key').setup()

require('snacks').setup({
	opts = {
		explorer = {
			enabled = true,
			replace_netrw = true,
		},
		notifier = {
			enabled = true
		}, 
	}
})
vim.keymap.set('n', '<leader>e', Snacks.explorer.reveal, { desc = 'Reveal current file in explorer' })

-- local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
