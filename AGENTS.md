# NixOS & Flake Guidelines for Agents

This document contains important rules and learned lessons to avoid breaking the NixOS rebuild and flake evaluation for this project.

## Repository Summary

This is a NixOS system configuration repo managed with Nix Flakes. It targets `x86_64-linux` and defines two system configurations: a full **laptop** (GNOME desktop, Nvidia specialisation, Secure Boot via Lanzaboote) and a minimal **WSL** instance.

### Flake Architecture

The root `flake.nix` composes three sub-flakes:

- **`software/`** (`mySystem`) -- the main software flake. Builds two package bundles via `symlinkJoin`: `standardApps` (CLI tools) and `default` (CLI + GUI). Also exports `nixosModules` (e.g. podman) and `devShells`.
- **`software/common/nvim/`** (`mvim`) -- Neovim config using **NixCats**. Defines multiple "flavors" (package variants) with different LSPs/plugins per language: `mvim` (base Nix/Lua), `fedev` (frontend), `cdev` (C/ESP32), `godev` (Go), `jedev` (Java+frontend), `rndev` (React Native). All share `nvim/` Lua config at runtime (`wrapRc = false`).
- **`software/lanzaboote/`** -- Secure Boot setup via lanzaboote, exposed as a NixOS module.

### Directory Layout

```
flake.nix                          # Root: composes sub-flakes, defines nixosConfigurations
machines/laptop/
  configuration.nix                # GNOME, SSH, Tailscale, Nvidia specialisation, pcscd
  hardware.nix                     # Hardware-specific (auto-generated)
software/
  flake.nix                        # Main software flake: packages, devShells, nixosModules
  common/
    git.nix, tmux.nix, lazygit.nix # CLI tools wrapped with config via writeShellApplication
    sessionVariables.nix           # EDITOR, NPM paths (NixOS module)
    srb-id-pkcs11-chrome.nix       # Smart card / PKCS#11 for Chrome
    claude-code/                   # Claude Code wrapper + caveman skill
    opencode/                      # OpenCode wrapper + config + skills
    nvim/                          # NixCats neovim sub-flake
      flake.nix                    # Flavor definitions (mvim, fedev, cdev, godev, jedev, rndev)
      nvim/                        # Lua runtime config (init.lua, lua/*.lua, ftplugin/)
      overlays/                    # Custom nixpkgs overlays (angular LSP)
  devshells/
    c.nix                          # ESP32/C++ shell (ESP-IDF, EEZ Studio, cmake)
    go.nix                         # Go development shell
    react-native.nix               # React Native shell
    nix-ld.nix                     # nix-ld setup for dynamic linking
  gui/
    ghostty.nix, discord.nix       # GUI app wrappers
    gaming.nix                     # Steam + DualSense controller config (NixOS module)
    okular.nix                     # PDF viewer
  modules/podman.nix               # Podman NixOS module
  scripts/pkillOnPort.nix          # Utility script
  services/hermes.nix              # Hermes AI agent OCI container (NixOS module)
  lanzaboote/                      # Secure Boot sub-flake
```

### Patterns & Conventions

- **Wrapper pattern**: CLI tools (git, tmux, claude, opencode) are packaged with `writeShellApplication`, embedding config files and exec-ing the real binary. This avoids home-manager.
- **No home-manager**: All user config is done declaratively through Nix wrappers or NixOS modules.
- **NixCats categories**: Neovim plugins/LSPs are grouped into categories (`general`, `config`, `frontend`, `c`, `go`, `java`). Flavors enable specific category sets and set `runtimeChecks` flags that Lua config reads at runtime.
- **nixpkgs 25.11** across all sub-flakes, with `follows` to share a single nixpkgs.

## 1. Flake Outputs Arguments
When defining flake `outputs` or internal module functions (like NixCats definitions), always allow for additional arguments like `self` by including an ellipsis (`...`) or explicitly accepting `self`. 
**Bad:** 
```nix
outputs = { nixpkgs, mvim }: 
```
**Good:** 
```nix
outputs = { self, nixpkgs, mvim, ... }:
```
*Failing to do this results in `error: function 'outputs' called with unexpected argument 'self'`.*

## 2. Extending PATH in NixOS
Do NOT override or append to `PATH` using `environment.sessionVariables`. Depending on the Nixpkgs version, this can cause type-check errors when merged with other system configurations (as it expects either an absolute path or a list, but collisions happen).
Instead, use `environment.extraInit` to safely extend the path using standard shell syntax.

**Bad:**
```nix
environment.sessionVariables = {
  PATH = [ "$HOME/.npm-global/bin" ];
};
```
**Good:**
```nix
environment.extraInit = ''
  export PATH="$HOME/.npm-global/bin:$PATH"
'';
```

## 3. Flake Packages Output Structure
The `packages.${system}.<name>` output must point directly to a derivation, not a nested attribute set.

**Bad:**
```nix
packages.${system}.raspEnv = {
  default = myDerivation;
};
```
**Good:**
```nix
packages.${system} = {
  raspEnv = myDerivation;
  default = myDerivation; # if you want a default package
};
```
*Failing to do this results in `error: flake attribute 'packages.x86_64-linux.<name>' is not a derivation`.*

## 4. Git Commits
Always leave all git staging and committing to the user. You should only use read-only git commands like `git status` and `git diff` to inspect changes. If you finish modifying files, stop and inform the user the files are ready, allowing them to manually commit. Only execute `git commit` if the user's prompt explicitly contains the exact instruction "commit".