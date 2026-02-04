{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    "plugins-opencode" = {
      url = "github:sudo-tee/opencode.nvim/6094564e935b034c9ec6088d8333cd45553dc34e";
      flake = false;
    };
    "plugins-better-ts-errors" = {
      url = "github:/OlegGulevskyy/better-ts-errors.nvim";
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
      (import ./overlays/angular.nix)
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
          fd
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
        java = with pkgs; [
          jdt-language-server
          jdk21
          vscode-extensions.vscjava.vscode-java-debug
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
          plenary-nvim
          pkgs.neovimPlugins.opencode
          lazydev-nvim
          nvim-dap
          nvim-dap-view
        ];
        config = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [
            p.nix
            p.lua
          ]))
          blink-cmp
          nvim-lspconfig
        ];
        frontend = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [
            p.typescript
            p.javascript
            p.tsx
            p.astro
            p.css
            p.html
            p.angular
            p.java
          ]))
          ccc-nvim
          nvim-ts-autotag
          # dependency for better-ts-errors
          pkgs.neovimPlugins.better-ts-errors
          nui-nvim
        ];

        java = with pkgs.vimPlugins; [
          nvim-jdtls
        ];
      };

      # use with packadd and an autocommand in config to achieve lazy loading
      optionalPlugins = {};

      # shared libraries to be added to LD_LIBRARY_PATH
      sharedLibraries = {};

      # available at RUN TIME for plugins. Will be available to path within neovim terminal
      environmentVariables = {
        frontend = {
          XDG_CONFIG_HOME = "/home/xpo/config/software/common/nvim";
        };
      };

      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      extraWrapperArgs = {};

      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {};
    };

    packageDefinitions = {
      mvim = {pkgs, ...}: {
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

      fedev = {pkgs, ...}: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = false;
          inherit unwrappedCfgPath;
        };
        categories = {
          general = true;
          config = true;
          gitPlugins = true;
          frontend = true;
          vscode_debug_path = pkgs.vscode-js-debug;
          runtimeChecks = {
            IS_FRONTEND = true;
          };
        };
      };

      rndev = {pkgs, ...}: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = false;
          inherit unwrappedCfgPath;
        };
        categories = {
          general = true;
          config = true;
          gitPlugins = true;
          frontend = true;
          vscode_debug_path = pkgs.vscode-js-debug;
          runtimeChecks = {
            IS_FRONTEND = true;
            IS_REACT_NATIVE = true;
          };
        };
      };

      jedev = {pkgs, ...}: {
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
          config = true;
          java = true;
          vscode_debug_path = pkgs.vscode-js-debug;
          java_debug_path = pkgs.vscode-extensions.vscjava.vscode-java-debug;
          runtimeChecks = {
            IS_FRONTEND = true;
            IS_JAVA = true;
            JAVA_HOME = pkgs.jdk21.home;
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
      packages = {
        default = defaultPackage;
        mvim = defaultPackage;
        fedev = nixCatsBuilder "fedev";
        jedev = nixCatsBuilder "jedev";
        rndev = nixCatsBuilder "rndev";
      };
    });
}
