{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    "plugins-opencode" = {
      url = "github:sudo-tee/opencode.nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = ./nvim;
    unwrappedCfgPath = "/home/xpo/config/software/common/nvim/nvim";
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      # allowUnfree = true;
    };
    dependencyOverlays = [
      # This overlay grabs all the inputs named in the format
      # `plugins-<pluginName>`
      # Once we add this overlay to our nixpkgs, we are able to
      # use `pkgs.neovimPlugins`, which is a set of our plugins.
      (utils.standardPluginOverlay inputs)
    ];

    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkPlugin,
      ...
    } @ packageDef: {
      # Will be available to PATH within neovim terminal
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          # mini deps
          curl
          gnutar
        ];
        config = with pkgs; [
          lua-language-server
          nixd
          stylua
          alejandra
        ];
        frontend = with pkgs; [
          typescript-language-server
          astro-language-server
          angular-language-server
          vscode-langservers-extracted
          tailwindcss-language-server
          vscode-js-debug
          # add prettier
        ];
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        gitPlugins = with pkgs.vimPlugins; [
          gitsigns-nvim
        ];
        general = with pkgs.vimPlugins; [
          nvim-treesitter-textobjects
          mini-nvim
          snacks-nvim
          conform-nvim
          tokyonight-nvim
          persistence-nvim
          trouble-nvim
          flash-nvim
          markview-nvim
        ];
        config = with pkgs; [
          (nvim-treesitter.withPlugins (p: [
            p.nix
            p.lua
          ]))
          nvim-lspconfig
          blink-cmp
          lazydev-nvim
          nvim-lspconfig
        ];
        frontend = with pkgs; [
          (nvim-treesitter.withPlugins (p: [
            p.typescript
            p.astro
            p.css
            p.html
          ]))
          pkgs.neovimPlugins.opencode
          coc-nvim
          # coc-css
          # coc-html
          # coc-pairs
          # coc-tsserver
          # coc-lists
          # coc-diagnostics
          # coc-explorer
          # coc-markdownlint
          # coc-tailwindcss
          coc-json
          ccc-nvim
          nvim-treesitter-parsers.angular
          nvim-ts-autotag
          nvim-dap
          nvim-dap-ui
          # refactoring-nvim
        ];
      };

      # use with packadd and an autocommand in config to achieve lazy loading
      optionalPlugins = {};

      # shared libraries to be added to LD_LIBRARY_PATH
      sharedLibraries = {};

      # available at RUN TIME for plugins. Will be available to path within neovim terminal
      environmentVariables = {};

      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      extraWrapperArgs = {};

      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {};
    };

    packageDefinitions = {
      mvim = {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = false;
          inherit unwrappedCfgPath;
          # IMPORTANT:
          # your alias may not conflict with your other packages.
          aliases = ["nvim"];
        };
        categories = {
          general = true;
          gitPlugins = true;
          config = true;
          runtimeChecks = {
            IS_LUA = true;
            IS_NIX = true;
          };
        };
      };

      fedev = {pkgs}: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = false;
          inherit unwrappedCfgPath;
        };
        categories = {
          general = true;
          gitPlugins = true;
          frontend = true;
          vscode_debug_path = pkgs.vscode-js-debug;
          runtimeChecks = {
            IS_FRONTEND = true;
          };
        };
      };
    };

    defaultPackageName = "mvim";
  in
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
    in {
      packages = utils.mkAllWithDefault defaultPackage;
    });
}
