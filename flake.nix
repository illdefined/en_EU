{
  description = "Custom locale";
  outputs = { self, ... }:
  let patchLocales = pkgs: args:
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
  };
}
