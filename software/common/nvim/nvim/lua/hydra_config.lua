local M = {}

local function command(cmd)
  return function()
    vim.cmd(cmd)
  end
end

function M.setup()
  local Hydra = require("hydra")

  Hydra({
    name = "Window resize",
    mode = "n",
    body = "<C-w>",
    config = {
      color = "red",
      hint = {
        type = "window",
        position = "bottom",
        border = "rounded",
      },
    },
    hint = [[
Window resize
_+_: taller     _-_: shorter
_>_: wider      _<_: narrower
_=_: equal      _|_: max width
_q_: quit       _: max height
]],
    heads = {
      { "+", command("resize +2"), { desc = "taller" } },
      { "-", command("resize -2"), { desc = "shorter" } },
      { ">", command("vertical resize +4"), { desc = "wider" } },
      { "<", command("vertical resize -4"), { desc = "narrower" } },
      { "=", command("wincmd ="), { desc = "equal" } },
      { "|", command("vertical resize 9999"), { desc = "max width" } },
      { "_", command("resize 9999"), { desc = false } },
      { "q", nil, { exit = true, desc = "quit" } },
      { "<Esc>", nil, { exit = true, desc = false } },
    },
  })

  Hydra({
    name = "Side scroll",
    mode = "n",
    body = "z",
    config = {
      color = "red",
      hint = {
        type = "window",
        position = "bottom",
        border = "rounded",
      },
    },
    hint = [[
Side scroll
_h_: left 5 cols        _l_: right 5 cols
_H_: left half-screen   _L_: right half-screen
_q_: quit
]],
    heads = {
      { "h", "5zh", { desc = "left 5 cols" } },
      { "l", "5zl", { desc = "right 5 cols" } },
      { "H", "zH", { desc = "left half-screen" } },
      { "L", "zL", { desc = "right half-screen" } },
      { "q", nil, { exit = true, desc = "quit" } },
      { "<Esc>", nil, { exit = true, desc = false } },
    },
  })
end

return M
