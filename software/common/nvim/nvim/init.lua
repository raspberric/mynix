vim.opt.relativenumber = true
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

vim.cmd("colorscheme tokyonight-storm")
require("mini_config").setup()
require("snacks_config").setup()
require("treesitter").setup()
require("persistence_config").setup()
require("trouble_config").setup()
require("flash_config").setup()
require("opencode").setup()

if nixCats("runtimeChecks.IS_FRONTEND") then
  require("frontend.ccc_config").setup()
  require("debug_config").setup()
  require("nvim-ts-autotag").setup()
  require("better-ts-errors")
end

require("lsp").setup()
require("blink").setup()
require("formatter").setup()

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<C-n>", vim.lsp.buf.hover, { desc = "Show hover documentation" })

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
})
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>%bd|e#<CR>", { desc = "Delete other buffers" })

vim.keymap.set("n", "<leader>td", "<cmd>tabclose<CR>", { desc = "close tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "new tab" })
vim.keymap.set("n", "<leader>tl", "<cmd>tabnext<CR>", { desc = "new tab" })
vim.keymap.set("n", "<leader>th", "<cmd>tabprev<CR>", { desc = "previous tab" })
-- escape terminal on esc
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
