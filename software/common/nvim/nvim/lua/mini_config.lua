local M = {}

function M.setup()
  require("mini.deps").setup({ path = { package = path_package } })
  -- local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

  require("mini.basics").setup({
    mappings = {
      windows = true,
      move_with_alt = true,
    },
  })
  require("mini.pairs").setup()
  require("mini.move").setup()
  require("mini.indentscope").setup()
  require("mini.notify").setup()
  require("mini.git").setup()
  require("mini.diff").setup({
    view = {
      style = "sign",
    },
    mappings = {
      apply = "<leader>ga",
      reset = "<leader>gr",
    },
    options = {
      indent_heuristic = true,
      algorithm = "histogram",
    },
  })
  vim.keymap.set("n", "<leader>gd", MiniDiff.toggle_overlay, { desc = "Toggle diff overlay" })
  vim.keymap.set("n", "<leader>gn", function()
    MiniDiff.goto_hunk("next")
  end, { desc = "Go to next hunk" })
  vim.keymap.set("n", "<leader>gN", function()
    MiniDiff.goto_hunk("prev")
  end, { desc = "Go to prev hunk" })

  require("mini.statusline").setup()
  require("mini.icons").setup()
  require("mini.tabline").setup({
    show_icons = true,
  })
  require("mini.surround").setup({
    mappings = {
      add = "sa",
      delete = "sd",
      replace = "sr",
      find = "sf",
      highlight = "sh",
    },
  })
  require("mini.cursorword").setup()
  local miniclue = require("mini.clue")
  miniclue.setup({
    window = { delay = 0, config = { width = 60 } },
    triggers = {
      -- Leader triggers
      { mode = "n", keys = "<Leader>" },
      { mode = "x", keys = "<Leader>" },

      -- `[` and `]` keys
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },

      -- Built-in completion
      { mode = "i", keys = "<C-x>" },

      -- `g` key
      { mode = "n", keys = "g" },
      { mode = "x", keys = "g" },

      -- Marks
      { mode = "n", keys = "'" },
      { mode = "n", keys = "`" },
      { mode = "x", keys = "'" },
      { mode = "x", keys = "`" },

      -- Registers
      { mode = "n", keys = '"' },
      { mode = "x", keys = '"' },
      { mode = "i", keys = "<C-r>" },
      { mode = "c", keys = "<C-r>" },

      -- Window commands
      { mode = "n", keys = "<C-w>" },

      -- `z` key
      { mode = "n", keys = "z" },
      { mode = "x", keys = "z" },
    },

    clues = {
      -- Enhance this by adding descriptions for <Leader> mapping groups
      { mode = "n", keys = "<Leader>s", desc = "+Search/Surround" },
      { mode = "x", keys = "<Leader>s", desc = "+Search/Surround" },
      -- miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers({ show_contents = true }),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
  })
end

return M
