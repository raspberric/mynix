--- 
name: working-with-nix
description: Use when working with .nix files, nixos modules and flakes.
compatibility: .nix files and config repository.
---

# Working with Nix files and Nixos configurations
Use this skill when user asks to do something on the nix system or nixos configuration.

## Rules
- Make sure you read the use the user's nixpkgs version before suggesting packages.
- Take the user's nixpkgs version when looking up package documentation to make sure the right package version supports discussed features or has suspected issues.
- Don't assume package names, use `https://search.nixos.org/packages?channel=<nixpkgs version>&query=<package name>` to discover packages. Make sure you include discovered packages version.
- Don't run test builds without user asking.
- When configuring system and package options make sure you refer to documentation instead of guessing. Make sure the configuration options exist on user's nixpkgs version.
