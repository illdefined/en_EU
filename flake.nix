{
  description = "Custom locale";
  outputs = { self, nixpkgs, ... }:
  let
    patchLocales = pkgs: ovr:
      (pkgs.glibcLocales.overrideAttrs (base: {
        postPatch = base.postPatch + ''
          cp ${./en_EU} localedata/locales/en_EU
          echo 'en_EU.UTF-8/UTF-8 \' >>localedata/SUPPORTED
        '';
      })).override ovr;
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
      home.sessionVariables.LANG = lib.mkDefault "en_EU.UTF-8";
      i18n.glibcLocales = patchLocales pkgs {
        allLocales = false;
        locales = [ "en_EU.UTF-8/UTF-8" ];
      };
    };
  };
}
