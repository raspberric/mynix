return {
	setup = function ()
	require("nvim-treesitter.configs").setup({
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
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
		},
	})
end
}
