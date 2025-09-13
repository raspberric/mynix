local M = {}

-- Installs mini deps manager if not there
function check_and_install()
  local path_package = vim.fn.stdpath("data") .. "/site"
  local mini_path = path_package .. "/pack/deps/start/mini.nvim"
  if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
      "git",
      "clone",
      "--filter=blob:none",
      -- Uncomment next line to use 'stable' branch
      -- '--branch', 'stable',
      "https://github.com/nvim-mini/mini.nvim",
      mini_path,
    }
    vim.fn.system(clone_cmd)
    vim.cmd("packadd mini.nvim | helptags ALL")
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
  end
end

function M.setup()
  require("mini.deps").setup({ path = { package = path_package } })
  -- local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

  require("mini.basics").setup({
    mappings = {
      windows = true,
      move_with_alt = true,
    },
  })
  require("mini.move").setup()
  require("mini.jump").setup({
    delay = {
      idle_stop = 1000,
    },
  })
  require("mini.indentscope").setup()
  require("mini.notify").setup()
  require("mini.git").setup()
  require("mini.diff").setup({
    view = {
      style = "sign",
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
  require("mini.surround").setup()
  require("mini.clue").setup()
end

return M
