# Agent Guidelines for NixOS Configuration Repository

This repository uses [Nix Flakes](https://nixos.wiki/wiki/Flakes) for reproducible and declarative system configuration. Understanding Nix basics is crucial for managing packages and system settings.

## Neovim Configuration

The Neovim configuration, located in `software/common/nvim/nvim`, utilizes [NixCats](https://nixcats.org/nixCats_format.html) for a structured and modular approach. Neovim serves as the primary editor, mainly for frontend development tasks.

## Configuration Ambiguity

If any configuration options or their implications are unclear or ambiguous, please prompt the user to trigger a web search. This will enable you to gather more precise information before making any changes.
Do not use `nix search` command. Use [ nixpgs search ](https://search.nixos.org/packages?channel=25.05) instead.
