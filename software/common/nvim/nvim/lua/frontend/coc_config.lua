local M = {}

function M.setup()
  local keyset = vim.keymap.set

  -- Dynamic Java Configuration
  ---@diagnostic disable-next-line: undefined-global
  if nixCats("runtimeChecks.IS_JAVA") then
    -- Disable coc-java extension to prevent conflicts
    vim.fn["coc#config"]("java", {
      enabled = false,
    })

    -- Configure generic language server using jdtls binary
    vim.fn["coc#config"]("languageserver", {
      java = {
        command = "jdtls",
        args = {
          "-javaagent:" .. nixCats("runtimeChecks.LOMBOK_JAR"),
        },
        rootPatterns = { "mvnw", "gradlew", "pom.xml", "build.gradle" },
        filetypes = { "java" },
        initializationOptions = {
          bundles = {},
          extendedClientCapabilities = {
            progressReportProvider = false,
            classFileContentsSupport = true,
            overrideMethodsPromptSupport = true,
            hashCodeEqualsPromptSupport = true,
            advancedOrganizeImportsSupport = true,
            generateToStringPromptSupport = true,
            advancedGenerateAccessorsSupport = true,
            generateConstructorsPromptSupport = true,
            selectionRangeSupport = true,
          },
          settings = {
            java = {
              home = nixCats("runtimeChecks.JAVA_HOME"),
              eclipse = {
                downloadSources = true,
              },
              maven = {
                downloadSources = true,
              },
              implementationsCodeLens = {
                enabled = true,
              },
              referencesCodeLens = {
                enabled = true,
              },
              references = {
                includeDecompiledSources = true,
              },
              inlayHints = {
                parameterNames = {
                  enabled = "all",
                },
              },
              completion = {
                enabled = true,
                importOrder = { "java", "javax", "com", "org" },
                guessMethodArguments = true,
              },
              configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                  {
                    name = "JavaSE-21",
                    path = nixCats("runtimeChecks.JAVA_HOME"),
                    default = true,
                  },
                },
              },
            },
          },
        },
      },
    })
  end

  -- Autocomplete Logic
  local opts = { silent = true, noremap = true, expr = true, replace_keycodes = true }

  -- Next/Prev in list
  keyset("i", "<C-j>", [[coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"]], opts)
  keyset("i", "<C-k>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"]], opts)

  -- Fallback to window nav in normal mode if no PUM
  -- keyset("n", "<C-j>", [[coc#pum#visible() ? coc#pum#next(1) : "\<C-w>j"]], opts)
  -- keyset("n", "<C-k>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-w>k"]], opts)

  -- <C-n> Logic:
  -- Normal Mode: Show documentation (hover)
  -- Insert Mode:
  --   If PUM visible: Show info (docs for selected item)
  --   If PUM NOT visible: Trigger refresh (show autocomplete)

  -- Insert Mode <C-n>
  keyset("i", "<C-n>", function()
    if vim.fn["coc#pum#visible"]() == 1 then
      return vim.fn["coc#pum#info"]()
    else
      return vim.fn["coc#refresh"]()
    end
  end, opts)

  -- Normal Mode <C-n> - Show Documentation
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
  vim.keymap.set("n", "<C-n>", "<CMD>lua _G.show_docs()<CR>", { silent = true, desc = "Show Documentation" })

  -- Confirm selection
  keyset({ "n", "i" }, "<C-y>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-y>"]], opts)

  -- Escape to close PUM/Float
  keyset("i", "<Esc>", [[coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"]], opts)
  keyset("n", "<Esc>", [[coc#float#has_float() ? coc#float#close_all() : "\<Esc>"]], opts)

  -- Navigation
  keyset("n", "gd", "<Plug>(coc-definition)", { silent = true, remap = true, desc = "Goto Definition" })
  keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true, remap = true, desc = "Goto Type Definition" })
  keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true, remap = true, desc = "Goto Implementation" })
  keyset("n", "gr", "<Plug>(coc-references)", { silent = true, remap = true, desc = "Goto References" })
  keyset("n", "grr", "<Plug>(coc-references)", { silent = true, remap = true, desc = "Goto References" })
  keyset("n", "gri", "<Plug>(coc-implementation)", { silent = true, remap = true, desc = "Goto Implementation" })
  keyset("n", "grn", "<Plug>(coc-rename)", { silent = true, remap = true, desc = "Rename Symbol" })
  keyset("n", "gra", "<Plug>(coc-codeaction-cursor)", { silent = true, remap = true, desc = "Code Action" })

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
  keyset("n", "<C-h>", [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-w>h"]], scroll_opts)
  keyset("n", "<C-l>", [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-w>l"]], scroll_opts)
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
  vim.api.nvim_set_hl(0, "CocHighlightText", { bg = "#4F4040" })

  -- Vim options
  vim.opt.backup = false
  vim.opt.writebackup = false
end

return M
