local jdtls = require("jdtls")

-- On NixOS, the jdtls binary is in the path if you added it to symlinkJoin
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name

-- Configuration for the server
local config = {
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
