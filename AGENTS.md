# NixOS & Flake Guidelines for Agents

This document contains important rules and learned lessons to avoid breaking the NixOS rebuild and flake evaluation for this project.

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