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
___: max height _q_: quit
]],
    heads = {
      { "+", command("resize +2"), { desc = "taller" } },
      { "-", command("resize -2"), { desc = "shorter" } },
      { ">", command("vertical resize +4"), { desc = "wider" } },
      { "<", command("vertical resize -4"), { desc = "narrower" } },
      { "=", command("wincmd ="), { desc = "equal" } },
      { "|", command("vertical resize 9999"), { desc = "max width" } },
      { "_", command("resize 9999"), { desc = "max height" } },
      { "q", nil, { exit = true, desc = "quit" } },
      { "<Esc>", nil, { exit = true, desc = false } },
    },
  })
end

return M
