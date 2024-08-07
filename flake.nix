{
  description = "Custom locale";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    inherit (nixpkgs) lib;
    stateVersion = lib.versions.majorMinor lib.version;
    patchLocales = pkgs: args:
      let glibcLocales =
          if pkgs.glibcLocales == null
          then pkgs.callPackage
            (pkgs.path + "/pkgs/development/libraries/glibc/locales.nix") args
          else pkgs.glibcLocales.override args;
      in glibcLocales.overrideAttrs (base: {
        postPatch = base.postPatch + ''
          cp ${./en_EU} localedata/locales/en_EU
          echo 'en_EU.UTF-8/UTF-8 \' >>localedata/SUPPORTED
        '';
      });
  in {
    nixosModules.default = { config, lib, pkgs, ... }: {
      i18n.defaultLocale = lib.mkDefault "en_EU.UTF-8";
      i18n.glibcLocales = patchLocales pkgs {
        allLocales = builtins.any (x: x == "all")
          config.i18n.supportedLocales;

        locales = config.i18n.supportedLocales;
      };
    };

    homeModules.default = { lib, pkgs, ... }: {
      home.language.base = lib.mkDefault "en_EU.UTF-8";
      i18n.glibcLocales = patchLocales pkgs {
        allLocales = false;
        locales = [ "en_EU.UTF-8/UTF-8" ];
      };
    };

    checks = lib.genAttrs lib.systems.flakeExposed (system: {
      home = (home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            self.homeModules.default {
              home = {
                inherit stateVersion;
                username = "test";
                homeDirectory = "/home/test";
              };
            }
          ];
        }).activationPackage;
      } // lib.optionalAttrs (lib.hasSuffix "-linux" system) {
        nixos = (nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.default {
              boot.loader.grub.enable = false;
              fileSystems."/".device = "nodev";
              system.stateVersion = stateVersion;
            }
          ];
        }).config.system.build.toplevel;
      });

    hydraJobs.checks = {
      inherit (self.checks) x86_64-linux aarch64-linux riscv64-linux;
    };
  };
}
