{
  inputs = {
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devlib = {
      url = "github:shikanime-studio/devlib";
      inputs = {
        devenv.follows = "devenv";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cachix.cachix.org"
      "https://devenv.cachix.org"
      "https://shikanime.cachix.org"
      "https://shikanime-studio.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "shikanime.cachix.org-1:OrpjVTH6RzYf2R97IqcTWdLRejF6+XbpFNNZJxKG8Ts="
      "shikanime-studio.cachix.org-1:KxV6aDFU81wzoR9u6pF1uq0dQbUuKbodOSP8/EJHXO0="
    ];
  };

  outputs =
    inputs@{
      devenv,
      devlib,
      flake-parts,
      git-hooks,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devenv.flakeModule
        devlib.flakeModule
        git-hooks.flakeModule
        treefmt-nix.flakeModule
      ];
      perSystem =
        { lib, pkgs, ... }:
        with lib;
        {
          devenv.shells = {
            cloud-pi-native = {
              containers = mkForce { };

              packages = [
                pkgs.age
                pkgs.ansible
                pkgs.crc
                pkgs.docker
                pkgs.gnutar
                pkgs.kubectl
                pkgs.kubernetes-helm
                pkgs.nodejs_24
                pkgs.pnpm
                pkgs.ruby
                pkgs.teleport
                pkgs.uv
                pkgs.yq
              ];
            };
            default.imports = [
              inputs.devlib.devenvModules.git
              inputs.devlib.devenvModules.github
              inputs.devlib.devenvModules.nix
              inputs.devlib.devenvModules.shell
              inputs.devlib.devenvModules.shikanime
            ];

            jj-vcs = {
              containers = mkForce { };

              languages.rust.enable = true;

              packages = [
                pkgs.libiconv
              ];
            };
            linux = {
              containers = mkForce { };

              languages.c.enable = true;

              packages = [
                pkgs.bc
                pkgs.bison
                pkgs.flex
                pkgs.gcc
                pkgs.gnumake
                pkgs.ncurses
                pkgs.openssl
                pkgs.pkg-config
                pkgs.python3
                pkgs.zlib
              ]
              ++ optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.elfutils) pkgs.elfutils
              ++ optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.pahole) pkgs.pahole;
            };
            longhorn = {
              containers = mkForce { };

              git-hooks.hooks = {
                golangci-lint.enable = true;
                gotest.enable = true;
              };

              languages.go.enable = true;

              packages = [
                pkgs.docker
                pkgs.gnumake
                pkgs.kubectl
                pkgs.kustomize
              ];
            };
            nixos = {
              containers = mkForce { };

              packages = [
                pkgs.nixpkgs-review
              ];
            };
          };
        };
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
