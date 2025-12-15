local M = {}

M.setup = function()
  local flash = require("flash")
  flash.setup()

  vim.keymap.set({ "n" }, "s", function()
    flash.jump()
  end, { desc = "Flash jump" })

  --   flash.treesitter()
  -- end, { desc = "Flash treesitter jump" })
  -- vim.keymap.set({ "n" }, "R", function()
  --   flash.remote()
  -- end, { desc = "Flash remote jump" })
end

return M
