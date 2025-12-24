local M = {}

function M.setup()
  local keyset = vim.keymap.set

  -- Dynamic Java Configuration
  ---@diagnostic disable-next-line: undefined-global
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

  -- Autocomplete Logic
  local autocomplete_opts = { silent = true, noremap = true, expr = true, replace_keycodes = true }

  keyset({ "n", "i" }, "<C-j>", function()
    if vim.fn["coc#pum#visible"]() == 1 then
      vim.fn["coc#pum#next"](1)
      return ""
    end
    return "<C-j>"
  end, autocomplete_opts)

  keyset({ "n", "i" }, "<C-k>", function()
    if vim.fn["coc#pum#visible"]() == 1 then
      vim.fn["coc#pum#prev"](1)
      return ""
    end
    return "<C-k>"
  end, autocomplete_opts)

  keyset({ "n", "i" }, "<C-n>", function()
    if vim.fn["coc#pum#visible"]() == 1 then
      vim.fn["coc#pum#info"]()
      return ""
    else
      if vim.api.nvim_get_mode().mode == "n" then
        return "i<C-r>=coc#refresh()<CR>"
      else
        return "<C-r>=coc#refresh()<CR>"
      end
    end
  end, autocomplete_opts)

  keyset({ "n", "i" }, "<C-y>", function()
    if vim.fn["coc#pum#visible"]() == 1 then
      vim.fn["coc#pum#confirm"]()
      return ""
    end
    return "<C-y>"
  end, autocomplete_opts)

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

  -- Scroll Documentation
  local scroll_opts = { silent = true, nowait = true, expr = true, replace_keycodes = true }

  keyset({ "n", "i", "v" }, "<C-h>", function()
    if vim.fn["coc#float#has_scroll"]() == 1 then
      if vim.api.nvim_get_mode().mode == "i" then
        return "<C-r>=coc#float#scroll(0)<CR>"
      else
        vim.fn["coc#float#scroll"](0)
        return ""
      end
    end
    return "<C-h>"
  end, scroll_opts)

  keyset({ "n", "i", "v" }, "<C-l>", function()
    if vim.fn["coc#float#has_scroll"]() == 1 then
      if vim.api.nvim_get_mode().mode == "i" then
        return "<C-r>=coc#float#scroll(1)<CR>"
      else
        vim.fn["coc#float#scroll"](1)
        return ""
      end
    end
    return "<C-l>"
  end, scroll_opts)

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
  vim.api.nvim_set_hl(0, "CocHighlightText", { bg = "#4F4040" })

  -- Vim options
  vim.opt.backup = false
  vim.opt.writebackup = false
end

return M
