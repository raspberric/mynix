{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { self, nixpkgs, nixCats, ... }@inputs: let
    inherit (nixCats) utils;
    luaPath = ./nvim;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      # allowUnfree = true;
    };
    dependencyOverlays = /* (import ./overlays inputs) ++ */ [
      # This overlay grabs all the inputs named in the format
      # `plugins-<pluginName>`
      # Once we add this overlay to our nixpkgs, we are able to
      # use `pkgs.neovimPlugins`, which is a set of our plugins.
      (utils.standardPluginOverlay inputs)
      # add any other flake overlays here.

      # when other people mess up their overlays by wrapping them with system,
      # you may instead call this function on their overlay.
      # it will check if it has the system in the set, and if so return the desired overlay
      # (utils.fixSystemizedOverlay inputs.codeium.overlays
      #   (system: inputs.codeium.overlays.${system}.default)
      # )
    ];

    categoryDefinitions = { pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: {
      # Will be available to PATH within neovim terminal
      lspsAndRuntimeDeps = {
        general = with pkgs; [
        ];
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        gitPlugins = with pkgs.vimPlugins; [
		gitsigns-nvim
	];
        general = with pkgs.vimPlugins; [ ];
      };

      # use with packadd and an autocommand in config to achieve lazy loading
      optionalPlugins = {
        general = with pkgs.vimPlugins; [ ];
      };

      # shared libraries to be added to LD_LIBRARY_PATH
      sharedLibraries = {
        general = with pkgs; [
          # libgit2
        ];
      };

      # available at RUN TIME for plugins. Will be available to path within neovim terminal
      environmentVariables = {
        test = {
          CATTESTVAR = "It worked!";
        };
      };

      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      extraWrapperArgs = {
        test = [
          '' --set CATTESTVAR2 "It worked again!"''
        ];
      };

      # lists of the functions you would have passed to
      # python.withPackages or lua.withPackages
      # do not forget to set `hosts.python3.enable` in package settings

      # get the path to this python environment
      # in your lua config via
      # vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      python3.libraries = {
        test = (_:[]);
      };
      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {
        test = [ (_:[]) ];
      };
    };

    packageDefinitions = {
      mvim = {pkgs , name, ... }: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = false;
	  unwrappedCfgPath = "/home/xpo/Projects/flakes/mvim/nvim";
          # IMPORTANT:
          # your alias may not conflict with your other packages.
          aliases = [ "vim" ];
          # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
        };
        categories = {
          general = true;
          gitPlugins = true;
          customPlugins = true;
          test = true;
          example = {
            youCan = "add more than just booleans";
            toThisSet = [
              "and the contents of this categories set"
              "will be accessible to your lua with"
              "nixCats('path.to.value')"
              "see :help nixCats"
            ];
          };
        };
      };
    };
    defaultPackageName = "mvim";
  in


  forEachSystem (system: let
    nixCatsBuilder = utils.baseBuilder luaPath {
      inherit nixpkgs system dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions;
    defaultPackage = nixCatsBuilder defaultPackageName;
    # this is just for using utils such as pkgs.mkShell
    # The one used to build neovim is resolved inside the builder
    # and is passed to our categoryDefinitions and packageDefinitions
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages = utils.mkAllWithDefault defaultPackage;

    devShells = {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [ defaultPackage ];
        inputsFrom = [ ];
        shellHook = ''
        '';
      };
    };

  }) // (let
    # we also export a nixos module to allow reconfiguration from configuration.nix
    nixosModule = utils.mkNixosModules {
      moduleNamespace = [ defaultPackageName ];
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
    # and the same for home manager
    homeModule = utils.mkHomeModules {
      moduleNamespace = [ defaultPackageName ];
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
  in {

    # these outputs will be NOT wrapped with ${system}

    # this will make an overlay out of each of the packageDefinitions defined above
    # and set the default overlay to the one named here.
    overlays = utils.makeOverlays luaPath {
      inherit nixpkgs dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions defaultPackageName;

    nixosModules.default = nixosModule;
    homeModules.default = homeModule;

    inherit utils nixosModule homeModule;
    inherit (utils) templates;
  });

}
