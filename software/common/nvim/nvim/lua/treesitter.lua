return {
  setup = function()
    -- nvim-treesitter main uses a new API; the legacy configs module no longer exists.
    require("nvim-treesitter").setup()
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
    local function select(query)
      return function()
        select_textobject(query, "textobjects")
      end
    end

    vim.keymap.set({ "x", "o" }, "af", select("@function.outer"), { desc = "Select outer function" })
    vim.keymap.set({ "x", "o" }, "if", select("@function.inner"), { desc = "Select inner function" })
    vim.keymap.set({ "x", "o" }, "ac", select("@class.outer"), { desc = "Select outer class" })
    vim.keymap.set({ "x", "o" }, "ic", select("@class.inner"), { desc = "Select inner class" })

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

	  ; html`...`
	  (call_expression
	    function: (identifier) @_tag (#eq? @_tag "html")
	    arguments: (template_string (string_fragment) @injection.content)
	    (#set! injection.language "html")
	  )
	]]
    )
  end,
}
