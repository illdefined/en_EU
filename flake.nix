{
  description = "Custom locale";
  outputs = { self, ... }: {
    nixosModules.default = { config, lib, pkgs, ... }: {
      i18n.defaultLocale = lib.mkDefault "en_EU.UTF-8";

      i18n.glibcLocales = (pkgs.glibcLocales.overrideAttrs (base: {
        postPatch = base.postPatch + ''
          cp ${lib.escapeShellArg ./en_EU} localedata/locales/en_EU
          echo 'en_EU.UTF-8/UTF-8 \' >>localedata/SUPPORTED
        '';
      })).override {
        allLocales = builtins.any (x: x == "all")
          config.i18n.supportedLocales;

        locales = config.i18n.supportedLocales;
      };
    };
  };
}
