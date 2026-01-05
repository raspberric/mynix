return {
  setup = function()
    local dap = require("dap")
    local dap_view = require("dap-view")

    dap_view.setup()

    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>dt", dap_view.toggle, { desc = "Debug: Toggle View" })
    vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Continue" })
    vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Debug: Run to cursor" })

    local js_debug_path = nixCats.get("vscode_debug_path")
    dap.adapters["pwa-chrome"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      command = "node",
      args = {
        js_debug_path .. "/lib/node_modules/js-debug/dist/src/dapDebugServer.js",
      },
    }

    for _, language in ipairs({ "typescript", "javascript", "astro" }) do
      dap.configurations[language] = {
        {
          name = "Attach to chrome",
          type = "pwa-chrome",
          url = "172.23.221.208:4321",
          request = "attach",
          sourceMaps = true,
          protocol = "inspector",
          port = 9222,
          webRoot = "${workspaceFolder}/src",
          skipFiles = { "**/node_modules/**" },
          -- cwd = vim.fn.getcwd(),
        },
      }
    end
  end,
}
