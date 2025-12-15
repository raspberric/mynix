return {
  setup = function()
    local persistence = require("persistence")
    persistence.setup()

    vim.keymap.set("n", "<leader>ps", function()
      persistence.load()
    end, { desc = "load the session for the current directory" })
    vim.keymap.set("n", "<leader>pS", function()
      persistence.select()
    end, { desc = "select a session to load" })
    vim.keymap.set("n", "<leader>pl", function()
      persistence.load({ last = true })
    end, { desc = "load the last session" })
    vim.keymap.set("n", "<leader>pd", function()
      persistence.stop()
    end, { desc = "stop Persistence => session won't be saved on exit" })
  end,
}
