local jdtls = require("jdtls")

-- On NixOS, the jdtls binary is in the path if you added it to symlinkJoin
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name

local bundles = {}
local java_debug_path = nixCats.get("java_debug_path")
if java_debug_path then
  local java_debug_bundle = vim.split(
    -- handle different java versions in jar nam
    vim.fn.glob(
      java_debug_path
        .. "/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar"
    ),
    "\n"
  )
  if java_debug_bundle[1] ~= "" then
    vim.list_extend(bundles, java_debug_bundle)
  end
end

-- Configuration for the server
local config = {
  init_options = {
    bundles = bundles,
  },
  on_attach = function(client, bufnr)
    require("jdtls").setup_dap({ hotcodereplace = "auto" })
  end,
  cmd = {
    "jdtls",
    "-data",
    workspace_dir,
    -- Add Spring Boot specific JVM args if needed
    "--jvm-arg=-Xmx1G",
  },
  root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),

  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
    },
  },
}

-- Start the language server
jdtls.start_or_attach(config)
