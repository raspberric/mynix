local M = {}

function M.setup()
  local keyset = vim.keymap.set

  -- Dynamic Java Configuration
  if nixCats("runtimeChecks.IS_JAVA") then
    vim.fn["coc#config"]("java", {
      enabled = true,
      saveActions = {
        organizeImports = true,
      },
      completion = {
        enabled = true,
        importOrder = { "java", "javax", "com", "org" },
      },
      format = {
        enabled = true,
      },
    })
  end

  local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
  keyset("i", "<C-j>", [[coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"]], opts)
  keyset("i", "<C-k>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"]], opts)
  keyset("i", "<C-n>", [[coc#pum#visible() ? coc#pum#info() : coc#refresh()]], opts)
  keyset("i", "<C-y>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-y>"]], opts)

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

  -- Scroll Documentation
  local scroll_opts = { silent = true, nowait = true, expr = true, replace_keycodes = false }
  keyset("n", "<C-h>", [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-h>"]], scroll_opts)
  keyset("n", "<C-l>", [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-l>"]], scroll_opts)
  keyset("i", "<C-h>", [[coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<C-h>"]], scroll_opts)
  keyset("i", "<C-l>", [[coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<C-l>"]], scroll_opts)
  keyset("v", "<C-h>", [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-h>"]], scroll_opts)
  keyset("v", "<C-l>", [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-l>"]], scroll_opts)

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

  vim.api.nvim_create_augroup("CocGroup", { clear = true })
  vim.api.nvim_create_autocmd("CursorHold", {
    group = "CocGroup",
    command = "silent call CocActionAsync('highlight')",
    desc = "Highlight symbol under cursor on CursorHold",
  })
  vim.api.nvim_set_hl(0, "CocHighlightText", { bg = "#4F4040" }) -- Example: adjust color as needed

  -- Vim options
  vim.opt.backup = false
  vim.opt.writebackup = false
end

return M
