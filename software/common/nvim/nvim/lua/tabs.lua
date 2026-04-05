return {
  setup = function()
    require("barbar").setup({
      icons = { pinned = { button = "", filename = true } },
    })

    local map = vim.api.nvim_set_keymap

    -- vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
    -- vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })

    map("n", "<leader>td", "<cmd>tabclose<CR>", { desc = "close tab" })
    map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "new tab" })
    map("n", "<leader>tl", "<cmd>tabnext<CR>", { desc = "new tab" })
    map("n", "<leader>th", "<cmd>tabprev<CR>", { desc = "previous tab" })

    -- Move to previous/next
    map("n", "<S-Tab>", "<Cmd>BufferPrevious<CR>", { desc = "go to previous buffer" })
    map("n", "<Tab>", "<Cmd>BufferNext<CR>", { desc = "go to next buffer" })

    -- Re-order to previous/next
    map("n", "<leader>bh", "<Cmd>BufferMovePrevious<CR>", { desc = "move buffer left" })
    map("n", "<leader>bl", "<Cmd>BufferMoveNext<CR>", { desc = "move buffer right" })

    map("n", "<leader>bp", "<Cmd>BufferPin<CR>", { desc = "pin buffer" })
    map("n", "<leader>bd", "<Cmd>BufferClose<CR>", { desc = "close buffer" })
    map("n", "<leader>bb", "<Cmd>BufferPick<CR>", { desc = "pick buffer by letter" })
    map("n", "<leader>br", "<Cmd>BufferPickDelete<CR>", { desc = "delete buffer by letter" })
    map("n", "<leader>bo", "<Cmd>BufferCloseAllButCurrentOrPinned<CR>", { desc = "close all but current or pinned" })

    map("n", "<leader>bn", "<Cmd>BufferOrderByName<CR>", { desc = "sort buffers by name" })
    map("n", "<leader>bs", "<Cmd>BufferOrderByDirectory<CR>", { desc = "sort buffers by directory" })
    -- Goto buffer in position...
    -- map("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", opts)
    -- map("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", opts)
    -- map("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", opts)
    -- map("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", opts)
    -- map("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", opts)
    -- map("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", opts)
    -- map("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", opts)
    -- map("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", opts)
    -- map("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", opts)
    -- map("n", "<A-0>", "<Cmd>BufferLast<CR>", opts)

    -- Pin/unpin buffer

    -- Goto pinned/unpinned buffer
    --                 :BufferGotoPinned
    --                 :BufferGotoUnpinned

    -- Close buffer

    -- Wipeout buffer
    --                 :BufferWipeout

    -- Close commands
    --                 :BufferCloseAllButCurrent
    --                 :BufferCloseAllButPinned
    --                 :BufferCloseBuffersLeft
    --                 :BufferCloseBuffersRight

    -- Magic buffer-picking mode

    -- Sort automatically by...

    -- Other:
    -- :BarbarEnable - enables barbar (enabled by default)
    -- :BarbarDisable - very bad command, should never be used
  end,
}
