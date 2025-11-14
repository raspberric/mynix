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
      ["<C-n>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-q>"] = { "hide" },
      ["<C-y>"] = { "accept", "fallback" },

      ["<C-j>"] = { "select_next" },
      ["<C-k>"] = { "select_prev" },

      ["<C-h>"] = { "scroll_documentation_up" },
      ["<C-l>"] = { "scroll_documentation_down" },
    },
    cmdline = {
      keymap = {
        preset = "inherit",
      },
      completion = { menu = { auto_show = true } },
    },
    completion = {
      ghost_text = { enabled = true },
      menu = {
        draw = {
          columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", "source_name" } },
          -- components = {
          -- kind_icon = {
          --   text = function(ctx)
          --     local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
          --     return kind_icon
          --   end,
          --   -- (optional) use highlights from mini.icons
          --   highlight = function(ctx)
          --     local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
          --     return hl
          --   end,
          -- },
          -- kind = {
          --
          --   -- (optional) use highlights from mini.icons
          --   highlight = function(ctx)
          --     local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
          --     return hl
          --   end,
          -- },
          -- },
        },
      },
    },
  })
end

return M
