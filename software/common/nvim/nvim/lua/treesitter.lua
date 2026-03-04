return {
  setup = function()
    require("nvim-treesitter.configs").setup({
      sync_install = false,
      auto_install = false,
      ensure_installed = {},
      ignore_install = {},
      modules = {},

      highlight = {
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

    vim.treesitter.query.set(
      "typescript",
      "injections",
      [[
	  ; extends
	  (call_expression
	    function: (identifier) @_tag (#eq? @_tag "css")
	    arguments: (template_string (string_fragment) @injection.content)
	    (#set! injection.language "css")
	  )
	]]
    )
  end,
}
