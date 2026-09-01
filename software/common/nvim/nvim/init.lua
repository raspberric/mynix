vim.opt.relativenumber = true

if vim.env.HERDR_ENV == "1" then
  local osc52_copy = require("vim.ui.clipboard.osc52").copy("+")
  local clipboard_cache = { lines = {}, regtype = "v" }

  local function copy(lines, regtype)
    clipboard_cache.lines = vim.list_extend({}, lines)
    clipboard_cache.regtype = regtype
    osc52_copy(lines)
  end

  local function paste()
    return { clipboard_cache.lines, clipboard_cache.regtype }
  end

  vim.g.clipboard = {
    name = "OSC 52 (Herdr)",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "
vim.g.netrw_liststyle = 3
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300

-- folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false -- Fold everything when opening a file? (false = open)
vim.opt.foldcolumn = "1" -- Show a small column on the left indicating folds
vim.opt.fillchars = { fold = " ", foldopen = "", foldsep = " ", foldclose = "" }
-- toggle wrap
vim.keymap.set("n", "<leader>w", ":set wrap!<CR>", { desc = "Toggle Wrap" })

require("tokyonight").setup({
  style = "night",
  light_style = "day",
})
vim.cmd("colorscheme tokyonight")
require("mini_config").setup()
require("snacks_config").setup()
require("treesitter").setup()
require("persistence_config").setup()
require("trouble_config").setup()
require("diffview").setup()
require("flash_config").setup()
require("opencode").setup()
require("debug_config").setup()
require("bookmarks").setup()
require("tabs").setup()
require("hydra_config").setup()

if nixCats("runtimeChecks.IS_DB") then
  require("db").setup()
end

if nixCats("runtimeChecks.IS_FRONTEND") then
  require("frontend.ccc_config").setup()
  require("nvim-ts-autotag").setup()
  require("better-ts-errors").setup()
end

require("lsp").setup()
require("blink").setup()
require("formatter").setup()

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<C-n>", vim.lsp.buf.hover, { desc = "Show hover documentation" })

vim.keymap.set("n", "<leader>ci", function()
  vim.lsp.buf.execute_command({
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = "",
  })
end, { desc = "Organize Imports" })

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
})
-- escape terminal on esc
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
