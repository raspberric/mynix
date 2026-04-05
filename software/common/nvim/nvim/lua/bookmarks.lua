return {
  setup = function()
    -- 1. Prevent the plugin from creating its own 'm' mappings
    vim.g.bookmark_no_default_key_mappings = 1

    -- Bookmarks Group
    vim.keymap.set("n", "mm", "<Plug>BookmarkToggle", { desc = "Toggle Bookmark" })
    vim.keymap.set("n", "mi", "<Plug>BookmarkAnnotate", { desc = "Annotate Bookmark" })
    vim.keymap.set("n", "ma", "<Plug>BookmarkShowAll", { desc = "Show All Bookmarks" })
    vim.keymap.set("n", "mj", "<Plug>BookmarkNext", { desc = "Next Bookmark" })
    vim.keymap.set("n", "mk", "<Plug>BookmarkPrev", { desc = "Prev Bookmark" })
    vim.keymap.set("n", "mc", "<Plug>BookmarkClear", { desc = "Clear Buffer Bookmarks" })
    vim.keymap.set("n", "mx", "<Plug>BookmarkClearAll", { desc = "Clear All Bookmarks" })

    vim.keymap.set("n", "mkk", "<Plug>BookmarkMoveUp", { desc = "Move Bookmark Up", remap = true })
    vim.keymap.set("n", "mjj", "<Plug>BookmarkMoveDown", { desc = "Move Bookmark Down", remap = true })
    vim.keymap.set("n", "mg", ":BookmarkMoveToLine ", { desc = "Move Bookmark to Line" })
    vim.keymap.set("n", "ms", ":BookmarkSave ", { desc = "Save Bookmarks to File" })
    vim.keymap.set("n", "ml", ":BookmarkLoad ", { desc = "Load Bookmarks from File" })
  end,
}
