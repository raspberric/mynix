local M = {}

function M.setup ()
	require('nvim-treesitter.configs').setup({
	  -- A list of parser names, or "all"
	  ensure_installed = { "javascript", "typescript", "nix" },

	  auto_install = false,

	  -- Enable highlighting
	  highlight = {
	    enable = true,
	  },

	  -- Enable indentation
	  indent = {
	    enable = true,
	  },

	  -- Configure treesitter-textobjects
	  textobjects = {
	    select = {
	      enable = true,
	      lookahead = true,
	      keymaps = {
		['af'] = '@function.outer',
		['if'] = '@function.inner',
		['ac'] = '@class.outer',
		['ic'] = '@class.inner',
	      },
	    },
	  },
	})

	local lspconfig = require('lspconfig')

	-- This block is required to start the tsserver
	lspconfig.ts_ls.setup({})

	require('blink.cmp').setup({
	  sources = {
	    -- Define the order of sources
	    default = { 'lsp', 'path', 'buffer', 'snippets' },
	    -- Configure providers with specific options
	    providers = {
	      lsp = {
		-- Set the priority of the LSP source
		score_offset = 1,
	      },
	    },
	  },
	})
end

return M
