local M = {}

local db_filetypes = { "sql", "mysql", "plsql" }

local function setup_globals()
  -- Keep connection secrets out of this repo. Use :DBUIAddConnection or DBUI env vars.
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_show_database_icon = 1
  vim.g.db_ui_winwidth = 40
  vim.g.db_ui_win_position = "left"
  vim.g.db_ui_execute_on_save = 0
  vim.g.db_ui_auto_execute_table_helpers = 0
  vim.g.db_ui_use_nvim_notify = 1
  vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod-ui"
  vim.g.db_ui_tmp_query_location = vim.fn.stdpath("state") .. "/dadbod-ui/tmp"
  vim.g.vim_dadbod_completion_mark = "DB"
end

local function setup_keymaps()
  local keymaps = {
    { "<leader>Du", "<cmd>DBUIToggle<CR>", "Toggle DB UI" },
    { "<leader>Da", "<cmd>DBUIAddConnection<CR>", "Add DB Connection" },
    { "<leader>Df", "<cmd>DBUIFindBuffer<CR>", "Find DB Buffer" },
    { "<leader>Dr", "<cmd>DBUIRenameBuffer<CR>", "Rename DB Buffer" },
    { "<leader>Di", "<cmd>DBUILastQueryInfo<CR>", "Last DB Query Info" },
  }

  for _, keymap in ipairs(keymaps) do
    vim.keymap.set("n", keymap[1], keymap[2], { desc = keymap[3] })
  end
end

local function setup_autocmds()
  local group = vim.api.nvim_create_augroup("DadbodConfig", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = db_filetypes,
    callback = function()
      vim.bo.omnifunc = "vim_dadbod_completion#omni"
    end,
  })
end

function M.setup()
  setup_globals()
  setup_keymaps()
  setup_autocmds()
end

return M
