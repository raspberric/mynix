local M = {}

function M.setup()
  local keyset = vim.keymap.set
  -- Autocomplete
  function _G.check_back_space()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
  end

  local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
  keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
  keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
  keyset("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

  -- Navigation
  keyset("n", "gd", "<Plug>(coc-definition)", { silent = true, remap = true })
  keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true, remap = true })
  keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true, remap = true })
  keyset("n", "gr", "<Plug>(coc-references)", { silent = true, remap = true })

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
  keyset("n", "K", "<CMD>lua _G.show_docs()<CR>", { silent = true })

  -- Rename
  keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true, remap = true })

  -- Formatting
  keyset("n", "<leader>f", "<Plug>(coc-format-selected)", { silent = true, remap = true })
  keyset("x", "<leader>f", "<Plug>(coc-format-selected)", { silent = true, remap = true })

  -- Code Action
  keyset("n", "<leader>ca", "<Plug>(coc-codeaction-cursor)", { silent = true, remap = true })
  keyset("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", { silent = true, remap = true })
  keyset("n", "<leader>ac", "<Plug>(coc-codeaction)", { silent = true, remap = true }) -- adding source action as backup/variant

  -- Autofix
  keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", { silent = true, remap = true })

  -- Vim options
  vim.opt.backup = false
  vim.opt.writebackup = false
  vim.opt.updatetime = 300
  vim.opt.signcolumn = "yes"

  -- Language Server Configurations
  local languageserver = {
    angular = {
      command = "ngserver",
      args = { "--stdio", "--tsProbeLocations", "", "--ngProbeLocations", "" },
      filetypes = { "html", "typescript", "typescriptreact", "angular" },
      rootPatterns = { "angular.json", "project.json" },
    },
    astro = {
      command = "astro-ls",
      args = { "--stdio" },
      filetypes = { "astro" },
      rootPatterns = { "astro.config.mjs", "package.json", ".git" },
    },
  }
  vim.fn["coc#config"]("languageserver", languageserver)

  -- Extension Configurations
  vim.fn["coc#config"]("tsserver", {
    enable = true,
    useLocalTsdk = true,
  })

  vim.fn["coc#config"]("html", {
    suggest = { angular1 = false },
    validate = { scripts = false, styles = false },
    format = { enable = true },
  })

  vim.fn["coc#config"]("css", {
    validate = { enable = true },
  })
end

return M
