local M = {}

function M.setup()
  require("dev-tools").setup({})
  require("refactoring").setup({})
end

return M
