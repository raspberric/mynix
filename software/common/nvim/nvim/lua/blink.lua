local M = {}

function M.setup()
  require("blink.cmp").setup({
    sources = {
      default = { "lsp", "path", "lazydev", "snippets", "buffer" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
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
      ["<C-k>"] = { "select_prev", "show_signature", "hide_signature" },

      ["<C-h>"] = { "scroll_documentation_up" },
      ["<C-l>"] = { "scroll_documentation_down" },
    },
    cmdline = {
      enabled = true,
      keymap = {
        preset = "inherit",
      },
      completion = { menu = { auto_show = true } },
    },
    completion = {
      ghost_text = { enabled = true },
      menu = {
        draw = {
          columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", "source_name", gap = 1 } },
        },
      },
    },
  })
end

return M
