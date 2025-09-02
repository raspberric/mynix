local M = {}

-- Installs mini deps manager if not there
function check_and_install()
	local path_package = vim.fn.stdpath('data') .. '/site'
	local mini_path = path_package .. '/pack/deps/start/mini.nvim'
	if not vim.loop.fs_stat(mini_path) then
	  vim.cmd('echo "Installing `mini.nvim`" | redraw')
	  local clone_cmd = {
	    'git', 'clone', '--filter=blob:none',
	    -- Uncomment next line to use 'stable' branch
	    -- '--branch', 'stable',
	    'https://github.com/nvim-mini/mini.nvim', mini_path
	  }
	  vim.fn.system(clone_cmd)
	  vim.cmd('packadd mini.nvim | helptags ALL')
	  vim.cmd('echo "Installed `mini.nvim`" | redraw')
	end
end

function M.setup ()
	require('mini.deps').setup({ path = { package = path_package } })
	-- local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

	require('mini.basics').setup({
		mappings = {
			windows = true,
			move_with_alt = true,
		},
	})
	require('mini.pairs').setup()
	require('mini.move').setup()
	require('mini.jump').setup()
	require('mini.indentscope').setup()
	require('mini.notify').setup()
	require('mini.git').setup()
	require('mini.diff').setup({
		view = {
			style = 'sign'
		}
	})
	require('mini.statusline').setup()
	require('mini.surround').setup()
	require('mini.icons').setup()
end

return M
