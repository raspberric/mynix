local M = {}

function M.setup()
  local keyset = vim.keymap.set
  -- Autocomplete
  function _G.check_back_space()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
  end

  local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
  keyset("i", "<C-j>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
  keyset("i", "<C-k>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
  keyset("i", "<TAB>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
  keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

  -- Navigation
  keyset("n", "<leader>cd", "<Plug>(coc-definition)", { silent = true, remap = true, desc = "Goto Definition" })
  keyset(
    "n",
    "<leader>ct",
    "<Plug>(coc-type-definition)",
    { silent = true, remap = true, desc = "Goto Type Definition" }
  )
  keyset("n", "<leader>ci", "<Plug>(coc-implementation)", { silent = true, remap = true, desc = "Goto Implementation" })
  keyset("n", "<leader>cr", "<Plug>(coc-references)", { silent = true, remap = true, desc = "Goto References" })

  -- Documentation
  function _G.show_docs()
    local cw = vim.fn.expand("<cword>")
    if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
      vim.api.nvim_command("h " .. cw)
    elseif vim.api.nvim_eval("coc#rpc#ready()") then
      vim.fn.CocActionAsync("doHover")
    else
      vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
    end
  end
  keyset("n", "<C-n>", "<CMD>lua _G.show_docs()<CR>", { silent = true, desc = "Show Documentation" })

  -- Rename
  keyset("n", "<leader>cR", "<Plug>(coc-rename)", { silent = true, remap = true, desc = "Rename Symbol" })

  -- Formatting
  keyset("n", "<leader>cf", ":CocCommand prettier.formatFile<CR>", { silent = true, desc = "Format File (Prettier)" })

  -- Code Action
  keyset("n", "<leader>ca", "<Plug>(coc-codeaction-cursor)", { silent = true, remap = true, desc = "Code Action" })
  keyset("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", { silent = true, remap = true, desc = "Code Action" })
  keyset("n", "<leader>cc", "<Plug>(coc-codeaction)", { silent = true, remap = true, desc = "Code Action (Source)" })

  -- Autofix
  keyset("n", "<leader>cq", "<Plug>(coc-fix-current)", { silent = true, remap = true, desc = "Quickfix" })

  -- Vim options
  vim.opt.backup = false
  vim.opt.writebackup = false
end

return M
