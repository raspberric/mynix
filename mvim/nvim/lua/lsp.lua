local M = {}

function M.setup ()
	require('nvim-treesitter.configs').setup({

		sync_install = false,
		auto_install = false,
		ensure_installed = {},
		ignore_install = {},
		modules = {},



	  highlight = {
	    enable = true,
	  },
	  indent = {
	    enable = true,
	  },
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

	local blink = require('blink.cmp')
	local lspconfig = require('lspconfig')
	lspconfig.nixd.setup({
		capabilities = blink.get_lsp_capabilities(),
	})
	lspconfig.ts_ls.setup({
		capabilities = blink.get_lsp_capabilities(),
	})
	lspconfig.lua_ls.setup({
		capabilities = blink.get_lsp_capabilities(),
		settings = {
		    Lua = {
		      workspace = {
			-- Tell the language server to scan for plugin files
			library = vim.api.nvim_get_runtime_file("", true),
		      },
		      diagnostics = {
			-- Make the server aware of the 'vim' global and other globals
			globals = { 'vim', "opts" },
		      },
		    },
		  },
	})

	blink.setup({
	  sources = {
	    default = { 'lsp', 'path', 'snippets' },
	    providers = {
	      lsp = {
		score_offset = 1,
	      },
	    },
	  },
	  signature = {
			enabled = true
		},
  	  keymap = {
		['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
		['<C-Esc>'] = { 'hide' },
		['<CR>'] = { 'accept', 'fallback' },

		['<C-k>'] = { 'select_prev' },
		['<C-j>'] = { 'select_next' },

		['<C-h>'] = { 'scroll_documentation_up' },
		['<C-l>'] = { 'scroll_documentation_down' },

		['<C-S-l>'] = { 'snippet_forward', 'fallback' },
		['<C-S-h>'] = { 'snippet_backward', 'fallback' },

		['<C-q>'] = { 'show_signature' },
	  },
	completion = {
	  menu = {
	    draw = {
	      components = {
		kind_icon = {
		  text = function(ctx)
		    local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
		    return kind_icon
		  end,
		  -- (optional) use highlights from mini.icons
		  highlight = function(ctx)
		    local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
		    return hl
		  end,
		},
		kind = {
		  -- (optional) use highlights from mini.icons
		  highlight = function(ctx)
		    local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
		    return hl
		  end,
		}
	      }
	    }
	  }
	}
	})

	require('conform').setup({
		formatters_by_fy = {
			lua = {'stylelua'},
			nix = {'alejandra'},
			javascript = {'prettier'},
			typescript = {'prettier'},
		}
	})
end

return M
