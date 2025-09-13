local M = {}

function M.setup()
  require("blink.cmp").setup({
    sources = {
      default = { "lsp", "path", "snippets" },
      providers = {
        lsp = {
          score_offset = 1,
        },
      },
    },
    signature = {
      enabled = true,
    },
    keymap = {
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-Esc>"] = { "hide" },
      ["<CR>"] = { "accept", "fallback" },

      ["<C-k>"] = { "select_prev" },
      ["<C-j>"] = { "select_next" },

      ["<C-h>"] = { "scroll_documentation_up" },
      ["<C-l>"] = { "scroll_documentation_down" },

      ["<C-S-l>"] = { "snippet_forward", "fallback" },
      ["<C-S-h>"] = { "snippet_backward", "fallback" },

      ["<C-S-K>"] = { "show_signature" },
    },
    completion = {
      menu = {
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                return kind_icon
              end,
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
            kind = {
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
          },
        },
      },
    },
  })
end

return M
